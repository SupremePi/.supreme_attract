local BASE_PATH = FeConfigDirectory + "modules/scenebuilder/"

class ISceneBuilder {
    VERSION = 0.9;
    DEBUG = true;
    
    debug_bg = null;        //background ref for debug mode
    config = null;          //scenebuilder options (not yet)
    parentObject = null;    //the scene or surface context we are operating on in the chain
    currentObject = null;   //the object context we are operating on in the chain
    scenes = null;          //array of scenes
    modules = {
        object = {},        //object extension modules are stored here
        event = {           //event extension modules are stored here
            signal = [],     //signal event handlers are stored here
            transition = [], //transition event handlers are stored here
            tick = []        //tick event handlers are stored here
        },
        shader = {}         //shader extension modules are stored here
        shader_alias = {}   //a table of custom params as a shader alias (must include shader="shadername")
    }
    shaders = {}            //reference to created shaders are stored here
    
    //scenebuilder instance
    constructor(props = {}) {
        config = merge_props( config, props );
        scenes = [];
        ::fe.add_ticks_callback( this, "on_tick" );
        ::fe.add_transition_callback( this, "on_transition" );
        ::fe.add_signal_handler( this, "on_signal" );
        if ( DEBUG ) debug();
    }
    
    //enable debugging w/ background
    function debug() {
        DEBUG = true;
        if ( debug_bg == null ) debug_bg = ::fe.add_image(BASE_PATH + "debug.png", 0, 0, 1920, 1080);
        debug_bg.alpha = 100;
        return this;
    }
    
    //set fe.layout options
    function layout(props) {
        setProps( ::fe.layout, props );
        if ( parentObject ) print_msg("You should specify layout options first, before creating scenes and objects, and only once", "WARN");
        return this;
    }

    //set fe.list options
    function list(props) {
        setProps( ::fe.list, props );
        if ( parentObject ) print_msg("You should specify list options first, before creating scenes and objects, and only once", "WARN");
        return this;
    }

    function shader(name, props) {
        if ( typeof(props) == "table" ) {
            //store shader properties
            modules.shader_alias[name] <- props;
        } else if ( typeof(props) == "function" ) {
            //add new shader
            register("shader", name, props);
        } else {
            print_msg("shader() expects a table of shader properties or a function to register a new SceneBuilderShader instance");
        }
        return this;
    }

    //begin a scene parentObject
    function scene(name, props = {}) {
        props.name <- name;
        return add("scene", props);
    }
    
    //set scene config (optional, if they weren't specified when creating the scene)
    function options(props) {
        if ( parentObject ) {
            parentObject.props = merge_props(parentObject.props, props);
            setProps(parentObject.ref, parentObject.props);
        } else {
            print_msg("you must create a scene before specifying scene options");
        }
        return this;
    }

    //add objects to the current scene or surface
    function add(type, props) {
        if ( type in modules.object == true ) {
            //let the modules handle create the AM reference, with the given SceneObject
            currentObject = SceneObject(type, props);
            if ( "add" in modules.object[type] == true ) modules.object[type].add(currentObject);
            if ( "ref" in currentObject == true ) setProps(currentObject.ref, props);
            //keep references to child objects
            if ( type != "scene" ) parentObject.children.push(currentObject);
            print_debug("added " + type + ( ( "name" in currentObject == true && currentObject.name != null ) ? ": " + currentObject.name : ""));
        } else {
            //type is not registered in modules.object
            print_msg("unrecognized object: " + type);
        }
        return this;
    }
    
    //store object states
    function add_states(states) {
        if ( typeof(states) == "table" ) {
            foreach( key, val in states )
                add_state( key, val );
        } else {
            print_msg("add_states expects a table of states i.e. { state1 = { x = 0, y = 0 }, state2 = { x = 100, y = 100 }", "WARN");
        }
        return this;
    }
    
    //store object state
    function add_state(name, props) {
        if ( typeof(props) == "table" ) {
            if ( currentObject ) {
                currentObject.states[name] <- props;
                print_debug("added object state: " + name);
            } else {
                print_msg("you must add a scene or object before adding a state to it", "WARN");
            }
        } else {
            print_msg("you must provide some options to add state '" + name + "'");
        }
        return this;
    }
    
    //set object state
    function state(name) {
        if ( currentObject ) {
            currentObject.state(name);
        } else {
            print_msg("you must add a scene or object before setting a state");
        }
        return this;
    }
    
    //store event handlers in modules.event
    function on(event, func = null) {
        if ( typeof(event) == "table" ) {
            //register multiple events
            foreach(key, val in event) {
                if ( typeof(val) == "function" ) {
                    on_event(key, val);
                } else {
                    print_msg("on() with a single parameter expects a table of event->functions, i.e. { \"event1\": function() { ... }, \"event2\": function() { ... } }" );
                }
            }
        } else {
            //register single event
            return on_event(event, func);
        }
        return this;
    }
    
    function on_event(event, func) {
        if ( typeof(func) == "function" ) {
            if ( event in modules.event == false ) modules.event[event] <- [];
            print_debug("registered listener for event: " + event);
            modules.event[event].push(func);
        } else {
            print_msg("on(\"" + event + "\", ...) needs to be a function that will handle that event", "WARN");
        }
        return this;
    }

    //trigger an event
    function trigger(event, opt1 = null, opt2 = null, opt3 = null) {
        if ( event in modules.event ) {
            print_debug("triggered event: " + event, "DEBUG");
            for( local i = 0; i < modules.event[event].len(); i++ )
                if ( opt3 != null ) {
                    modules.event[event][i](opt1, opt2, opt3);
                } else if ( opt2 != null ) {
                    modules.event[event][i](opt1, opt2);
                } else if ( opt1 != null ) {
                    modules.event[event][i](opt1);
                } else {
                    modules.event[event][i]();
                }
        } else {
            print_msg("event '" + event + "' not recognized", "WARN");
        }
    }
    
    //on_tick, passed down to any event listeners
    function on_tick(ttime) {
        for ( local i = 0; i < modules.event.tick.len(); i++)
            modules.event.tick[i](ttime);
    }
    
    //on_transition, passed down to any event listeners
    function on_transition(ttype, var, ttime) {
        //print("ttype: " + ttype + ", notifing listeners: " + modules.les\n");
        for ( local i = 0; i < modules.event.transition.len(); i++) {
            local retVal = modules.event.transition[i](ttype, var, ttime);
            if ( retVal ) return true;
        }
        return false;
    }
    
    //on_signal, passed down to any event listeners
    function on_signal(str) {
        for ( local i = 0; i < modules.event.signal.len(); i++) {
             local retVal = modules.event.signal[i](str);
             if ( retVal ) return true;
        }
        return false;
    }
    
    //return a named SceneObject
    function find(name) {
        for ( local i = 0; i < scenes.len(); i++ ) {
            if ( scenes[i].name == name ) return scenes[i];
            for ( local x = 0; x < scenes[i].children.len(); x++ ) {
                if ( scenes[i].children[x].name == name ) return scenes[i].children[x];
            }
        }
        return null;
    }
    
    //return the object reference associated with a named SceneObject
    function findRef(name) {
        local sceneObject = find(name);
        if ( sceneObject ) return sceneObject.ref;
        return null;
    }
    
    //register individual or multiple modules, such as:
    //  register("object", funcMap)
    //  register("object", { "myModule" = funcMap1, "myModule2" = funcMap2 })
    function register( moduleType, key, props = {}) {
        if ( typeof(key) == "table" ) {
            //register multiple modules
            foreach( k,v in key ) {
                print_debug("registered " + moduleType + " module: " + k, "DEBUG");
                modules[moduleType][k] <- v;
            }
        } else {
            //register single module
            print_debug("registered " + moduleType + " module: " + key, "DEBUG");
            modules[moduleType][key] <- props;
        }
    }
    
    ///// Helper Functions /////
    
    //set properties on a object
    static function setProps(obj, props) {
        if ( obj == null ) return;
        foreach( key, val in props )
            try {
                //check for custom or modified properties
                if ( key == "rgb" ) {
                    obj.set_rgb(props[key][0], props[key][1], props[key][2]);
                } else if ( key == "rgba" ) {
                    obj.set_rgb(props[key][0], props[key][1], props[key][2]);
                    obj.alpha = props[key][3];
                } else if ( key == "bg_rgb" ) {
                    obj.set_bg_rgb(props[key][0], props[key][1], props[key][2]);
                } else if ( key == "bg_rgba" ) {
                    obj.set_bg_rgb(props[key][0], props[key][1], props[key][2]);
                    obj.bg_alpha = props[key][3];
                } else if ( key == "sel_rgb" ) {
                    obj.set_sel_rgb(props[key][0], props[key][1], props[key][2]);
                } else if ( key == "sel_rgba" ) {
                    obj.set_sel_rgb(props[key][0], props[key][1], props[key][2]);
                    obj.sel_alpha = props[key][3];
                } else if ( key == "selbg_rgb" ) {
                    obj.set_selbg_rgb(props[key][0], props[key][1], props[key][2]);
                } else if ( key == "selbg_rgba" ) {
                    obj.set_selbg_rgb(props[key][0], props[key][1], props[key][2]);
                } else if ( key == "label" ) {
                    //ignore it - this is for artwork - use file_name to change dynamically
                } else if ( key == "shader" && typeof(val) == "string" ) {
                    //use custom named shaders instead of setting shader directly
                    if ( val in modules.shader || val in modules.shader_alias ) {
                        //create the shader if it hasn't been created
                        if ( val in shaders == false ) {
                            if ( val in modules.shader_alias ) {
                                //use custom properties for an existing shader
                                if ( "shader" in modules.shader_alias[val] ) {
                                    shaders[val] <- modules.shader[modules.shader_alias[val].shader]( modules.shader_alias[val] );
                                } else {
                                    print_msg("you must specify the shader you are aliasing i.e shader = \"crt-lottes\"", "WARN");
                                }
                            } else {
                                //use default properties
                                shaders[val] <- modules.shader[val]();
                            }
                        }
                        obj.shader = shaders[val].shader;
                    } else {
                        print_msg("shader '" + val + "' does not exist", "WARN");
                    }
                } else {
                    obj[key] = val;
                }
            } catch(e) {
                print_debug("unable to set prop: " + key + " on " + obj + ": " + e);
            }
    }
    
    //merge one table into another ( 2nd table will overwrite any existing keys )
    static function merge_props(a, b) {
        foreach( key, value in b ) {
            if ( typeof(b[key]) == "table" )
                a[key] <- merge_props(a[key], b[key]);
            else
                a[key] <- b[key];
        }
        return a;
    }
    
    //print a debug msg
    static function print_debug(msg, level = "INFO") {
        if ( DEBUG ) print_msg(msg, level);
    }
    
    //print a msg
    static function print_msg(msg, level = "") {
        if ( level != "" ) level = level + " : ";
        print( "SceneBuilder: " + level + msg + "\n");
    }
    
    //print objects to console for debugging
    static function print_objects(objects, depth = 0) {
        local spaces = "";
        for ( local x = 0; x < depth; x++ )
            spaces += " ";
        for ( local i = 0; i < objects.len(); i++ ) {
            print_debug( spaces + object_to_string(objects[i]));
            if ( objects[i].children.len() > 0 ) {
                depth += 3;
                print_objects(objects[i].children, depth);
                depth -= 3;
            }
        }
    }
    
    //print object for debugging
    static function object_to_string(o) {
        return o.type + ": " + ( ( "name" in o == true && o.name != null ) ? o.name + " : " : "" ) + SceneBuilder.props_to_string(o.props)
    }
    
    //print object properties to console for debugging
    static function props_to_string(t) {
        local props = "{ ";
        foreach( key, value in t ) {
            if ( typeof(value) == "string" ) value = "\"" + value + "\"";
            if ( typeof(value) == "array" ) {
                local str = "[ ";
                for ( local i = 0; i < value.len(); i++ )
                    str += value[i] + ",";
                str = str.slice(0, str.len() - 1) + " ]";
                value = str;
            }
            props += "\"" + key + "\": " + value + ",";
        }
        props = props.slice(0, props.len() - 1) + " }";
        return props;
    }
}



//The SceneBuilder instance that will be used
SceneBuilder <- ISceneBuilder();

//load extensions
fe.do_nut( BASE_PATH + "object.nut");
fe.do_nut( BASE_PATH + "shader.nut");