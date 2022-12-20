SceneBuilder
-
SceneBuilder is an AttractMode module designed to simplify the layout coding process and make the layout easier to maintain.

* [Why](#why)
* [How it works](#how)
* [Scenebuilder Code](#code)
* [Methods](#methods)
* [Scenes](#scenes)
* [Finding Objects](#find)
* [Props](#props)
* [States](#states)
* [Events and Triggers](#events)
* [Shaders and Shader Aliases](#shaders)
* [Registering Custom Stuff](#register)

<a name="why">Why</a>
-
Much of the code in an AttractMode layout file spends time dealing with object creation, object positioning, object animations or multiple aspect configurations. Some of the more advanced layouts have custom functions or custom screen configurations. Unfortunately, everyone handles this process differently, which can make understanding and modifying a layout somewhat difficult.

SceneBuilder is my attempt to simplify layout code creation, so you can focus on its appearance to the user.

Hopefully, you will be able to look at a SceneBuilder layout, and easily see the objects that are added, the scenes they are separated in, and what events and actions occur in the layout.

<a name="how">How it Works</a>
-
```
////////////////////////
THIS IS A SCENEBUILDER LAYOUT.
FOR MORE INFO, PLEASE VISIT:
https://github.com/liquid8d/am-extra/modules/scenebuilder

NOTE: If you are using SceneBuilder, please include this above your layout code.
////////////////////////

fe.load_module("scenebuilder");
SceneBuilder
    .layout({ width = 640, height = 480, preserve_aspect_ratio = true })
    .scene("My Scene")
        .add("text", { msg = "Welcome to SceneBuilder", x = 0, y = 0, width = fe.layout.width, height = 20 })
        .add("image", { file_name = "welcome.png", x = 0, y = 30, width = 400, height = 100 })
```
Load module. Set layout options. Add scene. Add objects to scene.

Easy.

If the code there doesn't scare you, you can skip on to [Using SceneBuilder Methods](#methods). Otherwise, read on to understand the formatting.

<a name="code">SceneBuilder Code</a>
-

SceneBuilder uses a process call *method chaining*.  This means you can combine multiple method calls since each call returns the same SceneBuilder instance.

In the example above, we start with the `SceneBuilder` object and call the first method: `scene()`. This method creates a new scene (aka. new surface). When that method returns, that 'scene' is now the current *context*, meaning subsequent method calls will relate to it. The next method, `options()` sets the options (properties) on that scene. Finally, the `add()` method is called - multiple times to add multiple objects. Each object is added to the scene that preceded it.

By chaining these methods, you should be able to quickly pick up the flow of creating a layout with relative ease.

*Chaining* methods with SceneBuilder is not a requirement, it is primarily for convenience. However, this also means that *it may be necessary to call some methods before others*.

Notice the spacing/tabbing in the example above. The spacing makes it easier to see what methods relate to which object. This is not required, but helps make it easier for everyone to "read the chain".

You'll also notice that many methods use the 'table' format as an argument to pass data to it. This may look confusing at first, but once you understand property tables, it should be easy enough. A table is just a data set, in the format of:
```
{
    key1 = value,
    key2 = value
}
```

Here's some other helpful chaining and formatting tips:

You don't have to chain all your methods, split them up by scenes:

```
SceneBuilder.scene("primary")
    .add(...)
    .add(...)

SceneBuilder.scene("secondary")
    .add(...)
```

Properties are a Squirrel "table", and don't have to be on a single line, you can split them on multiple lines to read them easier:

```
    .add("text", {
        x = 0,
        y = 0,
        width = fe.layout.width,
        height = 20
    })
```
Ideally, if you have a couple properties, you can include them in a single line, otherwise you should probably break them up.

NOTE: Tables in Squirrel can be formatted in two ways, with **quotes and semi-colons**, or **no quotes and equal signs**. If you need spaces in your property names, you'll need to use quotes, otherwise it's up to you:

```
    .add("text", {
        "x": 0,
        ...
    })

    .add("text", {
        x = 0
    })
```

<a name="methods">Using SceneBuilder Methods</a>
-
Sounds great! SceneBuilder.*what*??

|Method|Desc|
|:-|:-|
|`.debug()`|run in debug mode
|`.scene(name)`|start a new scene. A scene is just a fullscreen surface
|`.add(name, props)`|add an object. Supports text, image, artwork, listbox, clone, and surface. More will be added soon.
|`.layout(props)`|set fe.layout properties
|`.list(props)`|set fe.list properties
|`.shader(alias, props)`|add a shader alias (for adding custom params to shaders)
|`.shader(alias, func)`| register a new shader to SceneBuilder. See [#shaders Adding Shaders]
|`.add_state(name, props)`|add a state to an object ( i.e. "hide", { alpha = 0 } )
|`.add_states(table)`|add multiple states to an object ( i.e. { "hide": { alpha = 0 }, "show": { alpha = 255 }})
|`.state(name)`|set an object to a specific state
|`.on(event, func)`|register an event handler
|`.trigger(event, arg1, arg2, arg3)`|trigger an event
|`.find(name)`|find a SceneBuilderObject. you must give the object a 'name' property to find it!
|`.findRef(name)`|find the AM Object reference for a SceneBuilderObject. you must give the object a 'name' property to find it!
|`.register(type, name, props)`|register SceneBuilder modules - for more see [#modules SceneBuilder Modules]

...and some static helper functions, if you so choose to use them:

|Method|Desc|
|:-|:-|
|`merge_props(a, b)`|merge table b *into* table a ( overwriting existing values )
|`print_debug(msg, level)`|print a message in console, only in debug mode
|`print_msg(msg, level)`|print a message in console
|`object_to_string(obj)`|get a SceneBuilderObject as a string
|`props_to_string(props)`|get a props (table) as a string

Even More!
-
SceneBuilder is more than just creating the objects in a layout:

<a name="scenes">Scenes</a>
-
Rather than building one layout screen, we'll take advantage of surfaces as *scenes*. When you create a scene, it is added as a surface, which allows us to switch between or modify multiple surfaces individually. This means you can create multiple scenes and decide which one is shown at any given time.

<a name="find">Finding Objects</a>
-
Some objects you create never need to be referenced again in your code. If they do, though, all that is needed is to include the **name** property when you add the object. You can then use the **.find(name)** and **.findRef(name)** to get either a reference to the SceneBuilder object or the AM Object reference:
```
SceneBuilder
    .add("text", { name = "title", ... })

//to access the AM object directly
SceneBuilder.findRef("title").alpha = 0;

//to access the SceneBuilder object to do things such as setting its state
SceneBuilder.find("title").state("hide");

```

<a name="props">New and Improved Object Properties</a>
-
When setting object properties, you can use these custom properties as well for objects that support them:
|Custom Properties|
|:-|
|`rgb = [ 0, 0, 0 ]`|
|`rgba = [ 0, 0, 0, 100 ]`|
|`bg_rgb = [ 0, 0, 0 ]`|
|`bg_rgba = [ 0, 0, 0, 100 ]`|
|`sel_rgb = [ 0, 0, 0 ]`|
|`sel_rgba = [ 0, 0, 0, 100 ]`|
|`selbg_rgb = [ 0, 0, 0 ]`|
|`selbg_rgba = [ 0, 0, 0, 100 ]`|

<a name="states">States</a>
-
Many times you want to change some properties on an object when a certain state change has occured. By creating predefined states, we can easily switch between them at any given time.

States are just a list of properties (table) for an object at any given time. For example, you might want to hide or show an image. After we add the image, we can add predefined states:

```
    .add("image", { name = "logo", file_name = "logo.png" })
        .state("hide", {
            alpha = 0
        })
        .state("show", {
            alpha = 255
        })
```
When the 'event' occurs, you can call:

```
SceneBuilder.find("logo").state("hide");
```

<a name="events">Events and Triggers</a>
-
Speaking of events, aren't you tired of writing random functions all over the place and tracking them down?

**Events**
SceneBuilder provides you with an .on(event, func) method so you can register a function just for your events.

We want event handling to be standardized between SceneBuilder layouts, so they are easier to maintain and modify. You can hook up all your events using a chained list of .on() methods. Even the common AM "signal", "transition", and "tick" events are supported.

```
    .on("transition", function(ttype, var, ttime) {
        if ( ttype == "Transition.StartLayout" )
            print("SceneBuilder layout started");
    })
```

Supported Events:
- AM: signal, transition and tick
- SceneBuilder: TBD
- insert-your-event-here

**Trigger**
When you want to call them, just use the SceneBuilder.trigger(event) function.

Then, listen to triggers of your event through:

```
SceneBuilder.on("my-custom-event", function(props) {

});
```

<a name="shaders">Shaders and Shader Aliases</a>
-
Out of the box, SceneBuilder includes various shaders you can use and customize. To use a shader, simply pass its name as the shader property for your object:

```
    SceneBuilder
        .add("artwork", { label = "snap", shader = "crt-lottes" })
```

|Included shaders
|-
|`crt-lottes`
|`rounded-corners`
|`pixelate`

Even better, you can create *shader aliases* of these that use custom params:
```
    SceneBuilder
        .shader("my-crt", {
            shader = "crt-lottes",
            aperature = 1.0
        })
        .add("artwork", { label = "snap", shader = "my-crt" })
```
This means you can create multiple aliases for a single shader with different params to use on different objects.

NOTE: .shader() must be called before the shader name is referenced.

<a name="register">Registering Custom Stuff</a>
-

**Objects**

If you create your own objects, you can easily add them with SceneBuilder by registering them in the object module, like so:
```
SceneBuilder.register("object", {
    custom = {
        add = function(sb, obj) {
            //load any modules you need
            obj.props = merge_props({
                //default or required object properties, if not specified by the user
                required = obj.props.required || true
            }, obj.props );
            obj.ref = <ref to AM object instance>
        }
    }
});
```

**Shaders**

To add new shaders to SceneBuilder, they just need to be registered, which is similar to adding a normal shader in a function, but allows SceneBuilder to store and use it later:

```
    SceneBuilder.shader("shader-name", function(props) {
        local shader = fe.add_shader(Shader.VertexAndFragment, vert, frag);
        //use default params if none are specified by the user
        props = SceneBuilder.merge_props({
            param1 = 1.0
        }, props);
        shader.set_param("param1", props.param1);
        return SceneBuilderShader(shader, props);
    })
```

NOTE: Shaders must be registered before being used (of course!)

**Events**

Developers can add register events that a user can listen to in their layout, like so:

```
SceneBuilder.register("event", {
    "my-custom-event": []
});
```


