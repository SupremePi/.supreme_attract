//Stored properties of SceneObject instances
class SceneObject {
    ref = null;
    children = null;
    name = null;
    type = null;
    props = null;
    states = null;
    currentState = "default";
    
    constructor( type, props ) {
        //store object name, if given
        if ( "name" in props == true ) {
            name = props.name;
            props.rawdelete("name");
        }
        this.type = type;
        this.props = props;
        this.children = [];
        this.states = {}
    }
    
    function state(s) {
        if ( s in states ) {
            SceneBuilder.print_debug("set-state for " + name, "DEBUG");
            SceneBuilder.setProps(ref, states[s]);
            currentState = s;
        }
    }
}

//Add predefined objects to SceneBuilder
SceneBuilder.register("object", {
    scene = {
        add = function(obj) {
            obj.props = SceneBuilder.merge_props( {
                width = ::fe.layout.width,
                height = ::fe.layout.height
            }, obj.props);
            obj.ref = ::fe.add_surface(obj.props.width, obj.props.height);
            SceneBuilder.scenes.push(obj);
            SceneBuilder.parentObject = SceneBuilder.scenes[SceneBuilder.scenes.len() - 1];
        }
    },
    surface = {
        add = function(obj) {
            obj.props = SceneBuilder.merge_props( {
                width = ::fe.layout.width,
                height = ::fe.layout.height
            }, obj.props);
            obj.ref = SceneBuilder.parentObject.ref.add_surface(obj.props.width, obj.props.height);
            SceneBuilder.parentObject = obj;
        }
    },
    "clone": {
        add = function(obj) {
            if ( "cloneid" in obj.props ) {
                local clone_obj = SceneBuilder.find(obj.props.cloneid);
                if ( clone_obj ) {
                    if ( clone_obj.type == "artwork" || clone_obj.type == "image" || clone_obj.type == "surface" ) {
                        print("adding clone to: " + SceneBuilder.parentObject.type);
                        SceneBuilder.parentObject.ref.add_clone(clone_obj.ref);
                    } else {
                        SceneBuilder.print_msg("you can only clone artwork, images or surfaces", "WARN");
                    }
                } else {
                    SceneBuilder.print_msg("unable to clone '" + obj.props.cloneid + "', can't find any object by that name", "WARN");
                }
            } else {
                print_msg("you must provide 'cloneid' with the name of the object you want to clone");
            }
        }
    }
    text = {
        add = function(obj) {
            obj.ref = SceneBuilder.parentObject.ref.add_text("", -1, -1, 1, 1);
        }
    },
    image = {
        add = function(obj) {
            obj.ref = SceneBuilder.parentObject.ref.add_image(obj.props.file_name, -1, -1, 1, 1);
        }
    },
    artwork = {
        add = function(obj) {
            obj.ref = SceneBuilder.parentObject.ref.add_artwork(obj.props.label, -1, -1, 1, 1);
        }
    },
    listbox = {
        add = function(obj) {
            obj.ref = SceneBuilder.parentObject.ref.add_listbox(-1, -1, 1, 1);
        }
    }
});
