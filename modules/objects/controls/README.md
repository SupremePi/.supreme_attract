Controls Module
-

The Controls module allows you to create a navigation UI with labels and buttons.
It consists of a Controls Manager (FeControls), which takes over control of AM using
a signal handler. You then add controls such as FeButton or FeLabel to the manager.

Each control can specify an action for up/down/left/right/select, either passing a 
control id to select it - or by running a function.

Usage:

All options are optional, and have defaults in place if nothing is provided for required options

Load module:
```
fe.load_module("objects/controls");
```

Setup control manager:
```
local manager = FeControls({
  enabled = true,                     //whether controls manager takes control
  selected = null,                    //selected control (you can set the default id here)
  clear_selection = true,             //clear selection on disable, restore selection on enable
  key_up = "up",                      //up key
  key_down = "down",                  //down key
  key_left = "left",                  //left key
  key_right = "right",                //right key
  key_select = "select"               //select key
});
```
Add labels:
```
manager.add(FeLabel("myLabel", 0, 0, 200, 30, {
  surface = surface_obj, //surface to put this label on, default uses ::fe
  up = "myButton",           //a string (control id to select) or a function
  down = "myButton",         //a string (control id to select) or a function
  left = "myButton",         //a string (control id to select) or a function
  right = "myButton",        //a string (control id to select) or a function
  state_default = {
     //properties applied to the control when in default state ( not selected )
     rgb = [ 50, 50, 50 ]
  },
  state_selected = {
     //properties applied to control when in selected state
     rgb = [ 0, 150, 0 ]
  }
}));
```
Add buttons:
```
manager.add(FeButton("myButton", 0, 0, 200, 30, {
  //same structure as label above for options
}));
```
Finally, initialize controls manager:
```
manager.init();
```

Notes:

- you can use manager.enabled = true or manager.enabled = false to enable or disable the
  signal handler used by the manager. 
- if you will be enabling and disabling the controls manager, you can set the clear_selection
  option to true if you want the selection cleared when the manager is not enabled or false if
  you want to maintain selection state on the selected control