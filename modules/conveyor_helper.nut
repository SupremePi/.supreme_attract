/* 
========================================================

CONVEYOUR_HELPER MODULE
------------------------

This is a tool to make the configuration of the converyour
easier to configure. It provides functionality to create
a spinwheel (ala Hyperspin), a horizontal, or vertical list
The list of games can be text, artwork, both, or either/or based
upon artwork availability. 

A demo theme has been included to show the possibiities of this
module

Coded by: ArcadeBliss
Idea provided by: verion

Intital Release: 19.10.2017

USAGE INSTRUCTIONS
------------------------

TODO (One Day)
------------------------
- Allow an item rotation for Linear Lists (once it is possible to change a fe.Text origin value)
- Fix linear lists to add appropiate buffer like the spinwheel fix 
	
=-=-=-=-=-=-=-=-=-=-=-=-=-	
SPECIAL NOTES FOR USE
=-=-=-=-=-=-=-=-=-=-=-=-=-

GAMELIST.ITEM.SCALING:  allows automatic size scaling of the gamelist items and content based upon the configured height and width of gamelist_item 
- The item furtherst from the selected item will use the "LOW" scaling option. (when list is horizontal = left side, when list is vertical = right side)
- The item closest to the current selected item will use the "HIGH" scaling option.
- The items in between will be calculated to be between HIGH and LOW. 
- The currently selected item will use "currentlySelected"
- remove all unused variables



=-=-=-=-=-=-=-=-=-=-=-=-=-=
Favorite indicators
=-=-=-=-=-=-=-=-=-=-=-=-=-=-
If you want to have an image shown when the gameitem is a "favorite" perform the following:
1. use the function: add_favoriteImage(filename,x,y,width,height);
a. filename = the location (complete path) and name of the file
b. x - coordinate begining with 0 using the item.width as a boundry
c. y - coordinate begining with 0 using the item.height as a boundry

=-=-=-=-=-=-=-=-=-=-=-=-=-=
CUSTOM GAME ITEM OBJECTS
=-=-=-=-=-=-=-=-=-=-=-=-=-=-
To add a custom game item that is defined from the layout do the following:
1. Initiate the Mygamelist object: ie. SpinwheelList = MyGameList();
2. Set game item type to custom: SpinwheelList.item.contentTemplate = ch.Custom
3. Set the width of your game item: e.g.: Spinwheel.item.width = 400;  
4. Set the hieght of your game item: e.g.: Spinwheel.item.height = 300;
5. Enter custom gameitem content in your layout:
a. add your artwork, images, and/or text using the function "add_custom GameItemContent(type, name,x,y,width,height)"
b. type = "artwork" or "image" or "text"
c. name = the filename and path to an image file, text if it is text, or an AttractMode label
d. configure extra settings using the fe.Image and fe.Text properties and methods
6. Repeat step 2 for the amount of objects that should be in the list.
7. If a "fallback" text object should only be shown incase artwork is not available, set the property "gi_textFallback" to true. E.g. SpinwheelList.gi_textFallback = true;
8. show you list e.g. SpinwheelList.show()

Tips
- To ensure the tool knows which artwork should be checked to determine if a "fallback" text object should be shown, add the "artwork" last.
if it is not possible to add the artwork last, set the property text_fallback_index = 2; and keep moving the number up until the fallback functionality works	
- if you have multiple "artwork" image types and the logic is checking the incorrect artwork to see if the "fallback" should been shown, you can adjust the property 
"artwork_test_index = 0" higher and higher until it works. 

=-=-=-=-=-=-=-=-=-=-=-=-=-=
CHANGE LOG:
=-=-=-=-=-=-=-=-=-=-=-=-=-=
2017.11.28
- [FEATURE]: added ch.Coverflow for coverflow lists and a new demo layout as an example
- [BUGFIX]: setting fade_afte_nav nolonger results in an endless loop
- [CHANGE]: refactored setLinearStops() (again) and LinearSlotItem.on_progress()  to match lessons learned with setSpinWheelStops all list types not work almost exactly the same simplifying code
- [CHANGE]: spinwheel gamelist items are now centered in the middle
- [CHANGE]: moved origin settings to setOriginSettings() based upon gamelist type and bend direction

2017.11.19
- [FEATURE]: added the ability to fade the wheel after navigating use: fade_after_nav, fade_delay, fade_selected and fade_speed
- [FEATURE]: added the ability to change the navigation speed of the gamelist see: ms_speed
- [BUGFIX]: corrected vertical lists text scrolling in the wrong direction
- [BUGFIX]: fixed fading of the fallback text object in setSlotItemClass()
- [BUGFIX]: Ensure correct game is selected when item.count is an even number see: "sel_game_offset"
- [CHANGE]: refactored setLinearStops to match lessons learned with setSpinWheelStops

2017.11.15 
- [BUGFIX]: Vertical lists now sort alphabetically from A to Z instead of Z to A - Thanks to BadFurDay for reporting this
- [CHANGE]: Updated all Demo Spinwheel layouts to start drawing from 90deg thus centering the selected item in the middle of the screen.

2017.11.14 
- [BUGFIX]: Spinwheel now sorts alphabetically from A to Z instead of Z to A

2017.11.10 
- [CHANGE]: moved the text from text only list out of the surface. Changes in: LinerSlotItem.constructor(), MyGameList.show(), setGameItemContent(), setSlotItemClass()
- [FEATURE]: added config item "text.word_wrap"
- [BUGFIX]: Spinwheel fixes. Selected game centered by default when selecting an odd number of items. Animation optimized

*/

fe.load_module( "conveyor" );

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Constants
//
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

ch <-  {
	Artwork = 1,
	Text = 2,
	Artwork_and_Text = 3,
	Artwork_or_Text = 4,
	Flyer_and_Artwork = 5,
	None = 6,
	Left = 7,
	Right = 8,
	Spinwheel = 9,
	Linear_Vertical = 10,
	Linear_Horizontal = 11,
	Item_Background = 12,
	Item_CurrentlySelected_Background = 13,
	Custom = 14,
	Color = 15,
	File = 16,
	Coverflow = 17
};


// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
// Classes
//
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	
	//	Spinwheel slot class to hold the wheel entries
class SpinwheelSlotItem extends ConveyorSlot
{
/*	Spinwheel list items are created using this class
	to ensure performance, the fuctions on_progress(), reset_index_offset(), swap(), and set_index_offset()
	are changed dynamically at runtime to ensure only a minimal of calculations are used to move the items
	along the conveyor.
*/	
	// gameitem settings used along the conveyor
	gi_x = null; // x-coordinate
	gi_y = null; // y-coordinate
	gi_w = null; // gameitem width
	gi_a = null; // gameitem alpha
	gi_h = null; // gameitem height
	gi_r = null; // gameitem rotation
	gi_oxmultiplier = null; // gameitem X origin multiplier value
	gi_oymultiplier = null; // gameitem Y origin multiplier value
	gi_text_size = null; // text size to use
	gi_text_red = null; // text color to use
	gi_text_green = null; // text color to use
	gi_text_blue = null; // text color to use
	gi_red = null; // gameitem background color
	gi_green = null; // gameitem background color
	gi_blue = null; // gameitem background color
	gl_stopPoints = null; // number of game list items
	surface = null; // Configured at runtime : holds the surface object for the slot
	slot_images = null; // Configured at runtime : holds the fe.Images objects located in the surface
	slot_text = null; // Configured at runtime : holds the fe.Text objects located in the surface
	gi_textFallback = null; // if true show text if the artwork is not available
	text_fallback_index = null; // holds the index of the gameName and fallback text item when artwork is not available
	artwork_test_name = null; // holds the name of the artwork label
	artwork_test_index = null;
	gi_sel_a = null; // alpha slot values for the selected game image 
	video_playing = [function(){foreach(value in slot_images) value.video_flags=Vid.Default; },	function(){foreach(value in slot_images) value.video_flags=Vid.NoAudio; }];
	video_status=null;
	
	constructor(setup_items, favFlag,...)
	{
		local temp = null;
		slot_images=[]; 
		slot_text=[];
		gi_textFallback = false;
		video_status=1;
		local zorder = 0;
		local useRuntimeContainer = (vargv.len() >0); // if a third or more parameters are passed to class set this to true
		local contentType = null;
		
	/*
		Use the runtime container as the object to ensure it is reused
		This will be invoked when the a third parameter (contents dont matter) is passed
		to this class.
	*/
				
		if (useRuntimeContainer)
		{
			surface = setup_items.surface.container;
			
			foreach (key,value in setup_items.surface.objects)
			{
				contentType = split(setup_items.surface.objectTypes[key], "|");		
				temp = setup_items.surface.objects[key];
				
				switch(contentType[0])
				{
					case "fe.Artwork":
					case "fe.Image":
						slot_images.push(temp);					
						break;	
						
					case "fe.Text":
						slot_text.push(temp);					
						break;
				}
				
				temp.zorder = zorder;
				zorder++;				
			}
				

		} else {
		
			// Parse setup_items and recreate the objects in the SpinwheelSlotItem surface
			surface = fe.add_surface(
				setup_items.surface.container.width,
				setup_items.surface.container.height
			);
			
			foreach (key,value in setup_items.surface.objects)
			{
				
				contentType = split(setup_items.surface.objectTypes[key], "|")
				switch(contentType[0])
				{
					case "fe.Artwork":
						temp = surface.add_artwork(
							contentType[1] + "",
							setup_items.surface.objects[key].x * 1,
							setup_items.surface.objects[key].y * 1,
							setup_items.surface.objects[key].width * 1,
							setup_items.surface.objects[key].height * 1
						);
						temp.pinch_x = setup_items.surface.objects[key].pinch_x * 1;
						temp.movie_enabled = (setup_items.surface.objects[key].movie_enabled)
						temp.green = setup_items.surface.objects[key].green * 1;
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.trigger = Transition.EndNavigation;
						temp.video_flags = setup_items.surface.objects[key].video_flags;
						temp.zorder = zorder;
						temp.preserve_aspect_ratio = (setup_items.surface.objects[key].preserve_aspect_ratio);
						temp.visible = (setup_items.surface.objects[key].visible);
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.skew_y = setup_items.surface.objects[key].skew_y * 1;
						temp.skew_x = setup_items.surface.objects[key].skew_x * 1;
						temp.shader = setup_items.surface.objects[key].shader
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.pinch_y = setup_items.surface.objects[key].pinch_y * 1;

						
						slot_images.push(temp);
						break;
						
					case "fe.Image":
						temp = surface.add_image(
							setup_items.surface.objects[key].file_name + "",
							setup_items.surface.objects[key].x * 1,
							setup_items.surface.objects[key].y * 1,
							setup_items.surface.objects[key].width * 1,
							setup_items.surface.objects[key].height * 1
						);
						temp.pinch_x = setup_items.surface.objects[key].pinch_x * 1;
						temp.movie_enabled = (setup_items.surface.objects[key].movie_enabled)
						temp.green = setup_items.surface.objects[key].green * 1;
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.trigger = Transition.EndNavigation;
						temp.video_flags = setup_items.surface.objects[key].video_flags;
						temp.zorder = zorder;
						temp.preserve_aspect_ratio = (setup_items.surface.objects[key].preserve_aspect_ratio);
						temp.visible = (setup_items.surface.objects[key].visible);
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.skew_y = setup_items.surface.objects[key].skew_y * 1;
						temp.skew_x = setup_items.surface.objects[key].skew_x * 1;
						temp.shader = setup_items.surface.objects[key].shader
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.pinch_y = setup_items.surface.objects[key].pinch_y * 1;	

						slot_images.push(temp);
						break;
						
					case "fe.Text":
						temp = surface.add_text(
							setup_items.surface.objects[key].msg,
							setup_items.surface.objects[key].x,
							setup_items.surface.objects[key].y,
							setup_items.surface.objects[key].width,
							setup_items.surface.objects[key].height
						);
						temp.zorder = zorder;
						temp.visible = (setup_items.surface.objects[key].visible)
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.style = setup_items.surface.objects[key].style
						temp.charsize = setup_items.surface.objects[key].charsize * 1;
						temp.word_wrap = (setup_items.surface.objects[key].word_wrap)
						temp.index_offset = setup_items.surface.objects[key].index_offset * 1;
						temp.align = setup_items.surface.objects[key].align * 1;
						temp.first_line_hint = setup_items.surface.objects[key].first_line_hint * 1;
						temp.bg_alpha = setup_items.surface.objects[key].bg_alpha * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.green = setup_items.surface.objects[key].green * 1;	
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.bg_red = setup_items.surface.objects[key].bg_red * 1;
						temp.bg_green = setup_items.surface.objects[key].bg_green * 1;
						temp.bg_blue = setup_items.surface.objects[key].bg_blue * 1;					
						temp.font = setup_items.surface.objects[key].font + "";
						temp.shader = setup_items.surface.objects[key].shader
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.bg_red = setup_items.surface.objects[key].bg_red * 1;
						temp.bg_blue = setup_items.surface.objects[key].bg_blue * 1;
						temp.bg_green = setup_items.surface.objects[key].bg_green * 1;
						temp.bg_alpha = setup_items.surface.objects[key].bg_alpha * 1;
						
						slot_text.push(temp);
						break;
				}
				
				zorder++;
			
			}
		}
		
		if (favFlag) {fe.add_transition_callback( this, "updateFavorite" )};
		base.constructor(surface);
	}
	
	//
	// These functions can be overridden for anything
	// more complicated (than a single Image object)
	//
	function swap( other )
	{

		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].swap( other.slot_images[key] );
		};
		
		if ( slot_text.len() > 0) {
			foreach (key,value in slot_text)
			{
				// fallback if swap doesn't exist
				local tmp = other.slot_text[key].index_offset;
				other.slot_text[key].index_offset = slot_text[key].index_offset;
				slot_text[key].index_offset = tmp;
			}
		}
	};

	// Set the index offset and trigger a redraw:
	function set_index_offset( io ) 
	{ 
		
		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].index_offset = io ;
		}
		
		if ( slot_text.len() > 0)
		{
			foreach (key,value in slot_text)
				slot_text[key].index_offset = io;
		}
	}

	// Reset the index offset, preferably without triggering a redraw:
	function reset_index_offset()
	{
		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].rawset_index_offset( m_base_io );
		}
		
		if ( slot_text.len() > 0)
		{
			foreach (key,value in slot_text)
				slot_text[key].index_offset = m_base_io ;
		}
		
	}
	
	function on_progress( progress, var )
	{
		
		local p = progress / (1.0 / gl_stopPoints);
		local slot = p.tointeger();
		p -= slot;
		
		if ( slot < 0 ) { slot = 0};
		if ( slot >= gl_stopPoints -1 ) { slot = gl_stopPoints -1 };
		
		local slot2 = slot+1;	
		// change positioning and sizes
		m_obj.x = gi_x[slot] + p * ( gi_x[slot2] - gi_x[slot] );
		m_obj.y = gi_y[slot] + p * ( gi_y[slot2] - gi_y[slot] );
		m_obj.width = gi_w[slot] + p * ( gi_w[slot2] - gi_w[slot] );
		m_obj.height = gi_h[slot] + p * ( gi_h[slot2] - gi_h[slot] );
		m_obj.rotation = gi_r[slot] + p * ( gi_r[slot2] - gi_r[slot] );
		m_obj.alpha = gi_a[slot] + p * ( gi_a[slot2] - gi_a[slot] );
		m_obj.origin_x = m_obj.width * gi_oxmultiplier;
		m_obj.origin_y = m_obj.height * gi_oymultiplier;
		
		fe.add_text(slot,m_obj.x,m_obj.y,m_obj.width,m_obj.height)
		
		// Fade selected image file
		slot_images[1].alpha =  gi_sel_a[slot] + p * ( gi_sel_a[slot2] - gi_sel_a[slot] );
		
		// change game name text properties
		slot_text[text_fallback_index].charsize = gi_text_size[slot] + p * ( gi_text_size[slot2] - gi_text_size[slot] );
		slot_text[text_fallback_index].red = gi_text_red[slot] + p * ( gi_text_red[slot2] - gi_text_red[slot] );
		slot_text[text_fallback_index].green =  gi_text_green[slot] + p * ( gi_text_green[slot2] - gi_text_green[slot] );
		slot_text[text_fallback_index].blue =  gi_text_blue[slot] + p * ( gi_text_blue[slot2] - gi_text_blue[slot] );
	
	/*
		Performance killing decision stuff
	*/

		(gi_textFallback) ? slot_text[text_fallback_index].visible = (fe.get_art( artwork_test_name, slot_images[artwork_test_index].index_offset ) =="")  : null; // hide text if artwork is available 
	// turn off video playing if the current game item is not the selected one. (test using the alpha channel for background selected image)
		video_playing[video_status].call(this);
	}
	
	
	function updateFavorite(ttype, var, ttime)
	{
		if (fe.game_info( Info.Favourite, slot_images[1].index_offset) == "1")
		{
			slot_images[slot_images.len()-1].visible = true;
		} else {
			slot_images[slot_images.len()-1].visible = false;
		}	
		return false;
	}

};

class CoverflowSlotItem extends ConveyorSlot
{
/*	Spinwheel list items are created using this class
	to ensure performance, the fuctions on_progress(), reset_index_offset(), swap(), and set_index_offset()
	are changed dynamically at runtime to ensure only a minimal of calculations are used to move the items
	along the conveyor.
*/	
	// gameitem settings used along the conveyor
	gi_x = null; // x-coordinate
	gi_y = null; // y-coordinate
	gi_w = null; // gameitem width
	gi_a = null; // gameitem alpha
	gi_h = null; // gameitem height
	gi_r = null; // gameitem rotation
	gi_px = null; // gameitem pinch_x
	gi_py = null; // gameitem pinch_y
	gi_oxmultiplier = null; // gameitem X origin multiplier value
	gi_oymultiplier = null; // gameitem Y origin multiplier value
	gi_text_size = null; // text size to use
	gi_text_red = null; // text color to use
	gi_text_green = null; // text color to use
	gi_text_blue = null; // text color to use
	gi_red = null; // gameitem background color
	gi_green = null; // gameitem background color
	gi_blue = null; // gameitem background color
	gl_stopPoints = null; // number of game list items
	surface = null; // Configured at runtime : holds the surface object for the slot
	slot_images = null; // Configured at runtime : holds the fe.Images objects located in the surface
	slot_text = null; // Configured at runtime : holds the fe.Text objects located in the surface
	gi_textFallback = null; // if true show text if the artwork is not available
	text_fallback_index = null; // holds the index of the gameName and fallback text item when artwork is not available
	artwork_test_name = null; // holds the name of the artwork label
	artwork_test_index = null;
	gi_sel_a = null; // alpha slot values for the selected game image 
	video_playing = [function(){foreach(value in slot_images) value.video_flags=Vid.Default; },	function(){foreach(value in slot_images) value.video_flags=Vid.NoAudio; }];
	video_status=null;
	
	constructor(setup_items, favFlag,...)
	{
		local temp = null;
		slot_images=[]; 
		slot_text=[];
		gi_textFallback = false;
		video_status=1;
		local zorder = 0;
		local useRuntimeContainer = (vargv.len() >0); // if a third or more parameters are passed to class set this to true
		local contentType = null;
		
	/*
		Use the runtime container as the object to ensure it is reused
		This will be invoked when the a third parameter (contents dont matter) is passed
		to this class.
	*/
				
		if (useRuntimeContainer)
		{
			surface = setup_items.surface.container;
			
			foreach (key,value in setup_items.surface.objects)
			{
				contentType = split(setup_items.surface.objectTypes[key], "|");		
				temp = setup_items.surface.objects[key];
				
				switch(contentType[0])
				{
					case "fe.Artwork":
					case "fe.Image":
						slot_images.push(temp);					
						break;	
						
					case "fe.Text":
						slot_text.push(temp);					
						break;
				}
				
				temp.zorder = zorder;
				zorder++;				
			}
				

		} else {
		
			// Parse setup_items and recreate the objects in the SpinwheelSlotItem surface
			surface = fe.add_surface(
				setup_items.surface.container.width,
				setup_items.surface.container.height
			);
			
			foreach (key,value in setup_items.surface.objects)
			{
				
				contentType = split(setup_items.surface.objectTypes[key], "|")
				switch(contentType[0])
				{
					case "fe.Artwork":
						temp = surface.add_artwork(
							contentType[1] + "",
							setup_items.surface.objects[key].x * 1,
							setup_items.surface.objects[key].y * 1,
							setup_items.surface.objects[key].width * 1,
							setup_items.surface.objects[key].height * 1
						);
						temp.pinch_x = setup_items.surface.objects[key].pinch_x * 1;
						temp.movie_enabled = (setup_items.surface.objects[key].movie_enabled)
						temp.green = setup_items.surface.objects[key].green * 1;
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.trigger = Transition.EndNavigation;
						temp.video_flags = setup_items.surface.objects[key].video_flags;
						temp.zorder = zorder;
						temp.preserve_aspect_ratio = (setup_items.surface.objects[key].preserve_aspect_ratio);
						temp.visible = (setup_items.surface.objects[key].visible);
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.skew_y = setup_items.surface.objects[key].skew_y * 1;
						temp.skew_x = setup_items.surface.objects[key].skew_x * 1;
						temp.shader = setup_items.surface.objects[key].shader
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.pinch_y = setup_items.surface.objects[key].pinch_y * 1;

						
						slot_images.push(temp);
						break;
						
					case "fe.Image":
						temp = surface.add_image(
							setup_items.surface.objects[key].file_name + "",
							setup_items.surface.objects[key].x * 1,
							setup_items.surface.objects[key].y * 1,
							setup_items.surface.objects[key].width * 1,
							setup_items.surface.objects[key].height * 1
						);
						temp.pinch_x = setup_items.surface.objects[key].pinch_x * 1;
						temp.movie_enabled = (setup_items.surface.objects[key].movie_enabled)
						temp.green = setup_items.surface.objects[key].green * 1;
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.trigger = Transition.EndNavigation;
						temp.video_flags = setup_items.surface.objects[key].video_flags;
						temp.zorder = zorder;
						temp.preserve_aspect_ratio = (setup_items.surface.objects[key].preserve_aspect_ratio);
						temp.visible = (setup_items.surface.objects[key].visible);
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.skew_y = setup_items.surface.objects[key].skew_y * 1;
						temp.skew_x = setup_items.surface.objects[key].skew_x * 1;
						temp.shader = setup_items.surface.objects[key].shader
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.pinch_y = setup_items.surface.objects[key].pinch_y * 1;	

						slot_images.push(temp);
						break;
						
					case "fe.Text":
						temp = surface.add_text(
							setup_items.surface.objects[key].msg,
							setup_items.surface.objects[key].x,
							setup_items.surface.objects[key].y,
							setup_items.surface.objects[key].width,
							setup_items.surface.objects[key].height
						);
						temp.zorder = zorder;
						temp.visible = (setup_items.surface.objects[key].visible)
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.style = setup_items.surface.objects[key].style
						temp.charsize = setup_items.surface.objects[key].charsize * 1;
						temp.word_wrap = (setup_items.surface.objects[key].word_wrap)
						temp.index_offset = setup_items.surface.objects[key].index_offset * 1;
						temp.align = setup_items.surface.objects[key].align * 1;
						temp.first_line_hint = setup_items.surface.objects[key].first_line_hint * 1;
						temp.bg_alpha = setup_items.surface.objects[key].bg_alpha * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.green = setup_items.surface.objects[key].green * 1;	
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.bg_red = setup_items.surface.objects[key].bg_red * 1;
						temp.bg_green = setup_items.surface.objects[key].bg_green * 1;
						temp.bg_blue = setup_items.surface.objects[key].bg_blue * 1;					
						temp.font = setup_items.surface.objects[key].font + "";
						temp.shader = setup_items.surface.objects[key].shader
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.bg_red = setup_items.surface.objects[key].bg_red * 1;
						temp.bg_blue = setup_items.surface.objects[key].bg_blue * 1;
						temp.bg_green = setup_items.surface.objects[key].bg_green * 1;
						temp.bg_alpha = setup_items.surface.objects[key].bg_alpha * 1;
						
						slot_text.push(temp);
						break;
				}
				
				zorder++;
			
			}
		}
		
		if (favFlag) {fe.add_transition_callback( this, "updateFavorite" )};
		base.constructor(surface);
	}
	
	//
	// These functions can be overridden for anything
	// more complicated (than a single Image object)
	//
	function swap( other )
	{

		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].swap( other.slot_images[key] );
		};
		
		if ( slot_text.len() > 0) {
			foreach (key,value in slot_text)
			{
				// fallback if swap doesn't exist
				local tmp = other.slot_text[key].index_offset;
				other.slot_text[key].index_offset = slot_text[key].index_offset;
				slot_text[key].index_offset = tmp;
			}
		}
	};

	// Set the index offset and trigger a redraw:
	function set_index_offset( io ) 
	{ 
		
		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].index_offset = io ;
		}
		
		if ( slot_text.len() > 0)
		{
			foreach (key,value in slot_text)
				slot_text[key].index_offset = io;
		}
	}

	// Reset the index offset, preferably without triggering a redraw:
	function reset_index_offset()
	{
		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].rawset_index_offset( m_base_io );
		}
		
		if ( slot_text.len() > 0)
		{
			foreach (key,value in slot_text)
				slot_text[key].index_offset = m_base_io ;
		}
		
	}
	
	function on_progress( progress, var )
	{
		
		local p = progress / (1.0 / gl_stopPoints);
		local slot = p.tointeger();
		p -= slot;
		
		if ( slot < 0 ) { slot = 0}
		if ( slot >= gl_stopPoints -1 ) { slot = gl_stopPoints -1 };
		
		local slot2 = slot+1;
		
		// change positioning and sizes
		m_obj.x = gi_x[slot] + p * ( gi_x[slot2] - gi_x[slot] );
		m_obj.y = gi_y[slot] + p * ( gi_y[slot2] - gi_y[slot] );
		m_obj.width = gi_w[slot] + p * ( gi_w[slot2] - gi_w[slot] );
		m_obj.height = gi_h[slot] + p * ( gi_h[slot2] - gi_h[slot] );
//		m_obj.rotation = gi_r[slot] + p * ( gi_r[slot2] - gi_r[slot] );
		m_obj.alpha = gi_a[slot] + p * ( gi_a[slot2] - gi_a[slot] );
		m_obj.origin_x = m_obj.width * gi_oxmultiplier;
		m_obj.origin_y = m_obj.height * gi_oymultiplier;
		m_obj.pinch_y = gi_py[slot] + p * ( gi_py[slot2] - gi_py[slot] );
		
		fe.add_text(slot,m_obj.x - m_obj.width/2,m_obj.y,m_obj.width,50)
		
		// Fade selected image file
		slot_images[1].alpha =  gi_sel_a[slot] + p * ( gi_sel_a[slot2] - gi_sel_a[slot] );
		
		// change game name text properties
		slot_text[text_fallback_index].charsize = gi_text_size[slot] + p * ( gi_text_size[slot2] - gi_text_size[slot] );
		slot_text[text_fallback_index].red = gi_text_red[slot] + p * ( gi_text_red[slot2] - gi_text_red[slot] );
		slot_text[text_fallback_index].green =  gi_text_green[slot] + p * ( gi_text_green[slot2] - gi_text_green[slot] );
		slot_text[text_fallback_index].blue =  gi_text_blue[slot] + p * ( gi_text_blue[slot2] - gi_text_blue[slot] );
	
	/*
		Performance killing decision stuff
	*/

		(gi_textFallback) ? slot_text[text_fallback_index].visible = (fe.get_art( artwork_test_name, slot_images[artwork_test_index].index_offset ) =="")  : null; // hide text if artwork is available 
	// turn off video playing if the current game item is not the selected one. (test using the alpha channel for background selected image)
		video_playing[video_status].call(this);
	}
	
	
	function updateFavorite(ttype, var, ttime)
	{
		if (fe.game_info( Info.Favourite, slot_images[1].index_offset) == "1")
		{
			slot_images[slot_images.len()-1].visible = true;
		} else {
			slot_images[slot_images.len()-1].visible = false;
		}	
		return false;
	}

};

class LinearSlotItem extends ConveyorSlot
{		
/*
	Linear and Horizontal lists are created using this class
	to ensure performance, the fuctions on_progress(), reset_index_offset(), swap(), and set_index_offset()
	are changed dynamically at runtime to ensure only a minimal of calculations are used to move the items
	along the conveyor.

*/
	// gameitem settings used along the conveyor
	gl_stopPoints = null; // total number of gameitems
	gi_x = null; // x-coordinate
	gi_y = null; // y-coordinate
	gi_w = null; // gameitem width
	gi_a = null; // gameitem alpha
	gi_h = null; // gameitem height
	gi_r = null; // gameitem rotation
	gi_oxmultiplier = null; // gameitem X origin multiplier value
	gi_oymultiplier = null; // gameitem Y origin multiplier value
	gi_text_size = null; // text size to use
	gi_text_red = null; // text color to use
	gi_text_green = null; // text color to use
	gi_text_blue = null; // text color to use
	gi_red = null; // gameitem background color
	gi_green = null; // gameitem background color
	gi_blue = null; // gameitem background color
	
	// gamelist settings (Linear List only settings)
	gl_type = null; // OPTIONS: "spinwheel" / "linear" - controls type of "on progress" to use
	gi_txt_width = null; //
	gi_txt_height = null; //
	gi_txt_x = null; //
	gi_txt_y = null; //

	
	surface = null; // Configured at runtime : holds the surface object for the slot
	slot_images = null; // Configured at runtime : holds the fe.Images objects located in the surface
	slot_text = null; // Configured at runtime : holds the fe.Text objects located in the surface
	gi_textFallback = null; // if true show text if the artwork is not available
	text_fallback_index = null; // holds the index of the gameName and fallback text item when artwork is not available
	artwork_test_name = null; // holds the name of the artwork label
	artwork_test_index = null;
	gi_sel_a = null;
	video_playing = [function(){foreach(value in slot_images) value.video_flags=Vid.Default; },	function(){foreach(value in slot_images) value.video_flags=Vid.NoAudio; }];
	video_status=null;
	
	//video_playing = null;
	
	constructor(setup_items, favFlag,contentTemplate,...)
	{
		local temp = null;
		video_status = 1;
		slot_images=[]; 
		slot_text=[];
		gi_textFallback = false;
		local zorder = 0;
		local contentType = null;
		local useRuntimeContainer = (vargv.len() >0); // if a third or more parameters are passed to class set this to true
		local textOnly = (contentTemplate == ch.Text); 

	/*
		Use the runtime container object to ensure it is reused and not lying around
		This will be invoked when a third parameter (contents dont matter) is passed
		to this class.
	*/
					
		
		if (useRuntimeContainer)
		{
			surface = setup_items.surface.container;
			
			foreach (key,value in setup_items.surface.objects)
			{
				contentType = split(setup_items.surface.objectTypes[key], "|");		
				temp = setup_items.surface.objects[key];
				switch(contentType[0])
				{
					case "fe.Artwork":
					case "fe.Image":
						slot_images.push(temp);					
						break;
						
					case "fe.Text":
						if (contentType.len() > 1 || textOnly )
						{

						/*
							Only add a new fe.text object if the fallback flag is active
						*/
	
							// create new text
							temp = fe.add_text(
								setup_items.surface.objects[key].msg,
								setup_items.surface.objects[key].x,
								setup_items.surface.objects[key].y,
								setup_items.surface.objects[key].width,
								setup_items.surface.objects[key].height
							);
							temp.zorder = zorder;
							temp.visible = (setup_items.surface.objects[key].visible);
							temp.rotation = setup_items.surface.objects[key].rotation * 1;
							temp.style = setup_items.surface.objects[key].style
							temp.charsize = setup_items.surface.objects[key].charsize * 1;
							temp.word_wrap = (setup_items.surface.objects[key].word_wrap)
							temp.index_offset = setup_items.surface.objects[key].index_offset * 1;
							temp.align = setup_items.surface.objects[key].align * 1;
							temp.first_line_hint = setup_items.surface.objects[key].first_line_hint * 1;
							temp.bg_alpha = setup_items.surface.objects[key].bg_alpha * 1;
							temp.red = setup_items.surface.objects[key].red * 1;
							temp.green = setup_items.surface.objects[key].green * 1;	
							temp.blue = setup_items.surface.objects[key].blue * 1;
							temp.bg_red = setup_items.surface.objects[key].bg_red * 1;
							temp.bg_green = setup_items.surface.objects[key].bg_green * 1;
							temp.bg_blue = setup_items.surface.objects[key].bg_blue * 1;					
							temp.font = setup_items.surface.objects[key].font + "";
							temp.shader = setup_items.surface.objects[key].shader
							temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
							temp.alpha = setup_items.surface.objects[key].alpha * 1; 
						}
						
						slot_text.push(temp);
						setup_items.surface.objects[key].visible = false; // hide the original text located in setup_items.surface.container
						break;
						
				}
				
				temp.zorder = zorder;
				zorder++;
				
			}
			
		} else {
			
			// Parse setup_items and recreate the objects in the SpinwheelSlotItem surface
			surface = fe.add_surface(
				setup_items.surface.container.width,
				setup_items.surface.container.height
			);
			
			foreach (key,value in setup_items.surface.objects)
			{
				contentType = split(setup_items.surface.objectTypes[key], "|")
				switch(contentType[0])
				{
					case "fe.Artwork":
						temp = surface.add_artwork(
							contentType[1],
							setup_items.surface.objects[key].x * 1,
							setup_items.surface.objects[key].y * 1,
							setup_items.surface.objects[key].width * 1,
							setup_items.surface.objects[key].height * 1
						);

						temp.pinch_x = setup_items.surface.objects[key].pinch_x * 1;
						temp.movie_enabled = (setup_items.surface.objects[key].movie_enabled)
						temp.green = setup_items.surface.objects[key].green * 1;
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.trigger = Transition.EndNavigation;
						temp.video_flags = setup_items.surface.objects[key].video_flags;
						temp.zorder = zorder;
						temp.preserve_aspect_ratio = (setup_items.surface.objects[key].preserve_aspect_ratio);
						temp.visible = (setup_items.surface.objects[key].visible);
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.skew_y = setup_items.surface.objects[key].skew_y * 1;
						temp.skew_x = setup_items.surface.objects[key].skew_x * 1;
						temp.shader = setup_items.surface.objects[key].shader
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.pinch_y = setup_items.surface.objects[key].pinch_y * 1;	

						slot_images.push(temp);					
						break;
						
					case "fe.Image":
						temp = surface.add_image(
							setup_items.surface.objects[key].file_name +"",
							setup_items.surface.objects[key].x * 1,
							setup_items.surface.objects[key].y * 1,
							setup_items.surface.objects[key].width * 1,
							setup_items.surface.objects[key].height * 1
						);
						temp.pinch_x = setup_items.surface.objects[key].pinch_x * 1;
						temp.movie_enabled = (setup_items.surface.objects[key].movie_enabled)
						temp.green = setup_items.surface.objects[key].green * 1;
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.trigger = Transition.EndNavigation;
						temp.video_flags = setup_items.surface.objects[key].video_flags;
						temp.zorder = zorder;
						temp.preserve_aspect_ratio = (setup_items.surface.objects[key].preserve_aspect_ratio);
						temp.visible = (setup_items.surface.objects[key].visible);
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.skew_y = setup_items.surface.objects[key].skew_y * 1;
						temp.skew_x = setup_items.surface.objects[key].skew_x * 1;
						temp.shader = setup_items.surface.objects[key].shader
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						temp.pinch_y = setup_items.surface.objects[key].pinch_y * 1;	
						
						slot_images.push(temp);
						break;
						
					case "fe.Text":
						if (contentType.len() > 1 || textOnly)
						{
							temp = fe.add_text(
								setup_items.surface.objects[key].msg,
								setup_items.surface.objects[key].x,
								setup_items.surface.objects[key].y,
								setup_items.surface.objects[key].width,
								setup_items.surface.objects[key].height								
							);
						} else {
							temp = surface.add_text(
								setup_items.surface.objects[key].msg,
								setup_items.surface.objects[key].x,
								setup_items.surface.objects[key].y,
								setup_items.surface.objects[key].width,
								setup_items.surface.objects[key].height
							);
						}
						
						temp.zorder = zorder;
						temp.visible = (setup_items.surface.objects[key].visible)
						temp.rotation = setup_items.surface.objects[key].rotation * 1;
						temp.style = setup_items.surface.objects[key].style
						temp.charsize = setup_items.surface.objects[key].charsize * 1;
						temp.word_wrap = (setup_items.surface.objects[key].word_wrap)
						temp.index_offset = setup_items.surface.objects[key].index_offset * 1;
						temp.align = setup_items.surface.objects[key].align * 1;
						temp.first_line_hint = setup_items.surface.objects[key].first_line_hint * 1;
						temp.bg_alpha = setup_items.surface.objects[key].bg_alpha * 1;
						temp.red = setup_items.surface.objects[key].red * 1;
						temp.green = setup_items.surface.objects[key].green * 1;	
						temp.blue = setup_items.surface.objects[key].blue * 1;
						temp.bg_red = setup_items.surface.objects[key].bg_red * 1;
						temp.bg_green = setup_items.surface.objects[key].bg_green * 1;
						temp.bg_blue = setup_items.surface.objects[key].bg_blue * 1;					
						temp.font = setup_items.surface.objects[key].font + "";
						temp.shader = setup_items.surface.objects[key].shader
						temp.filter_offset = setup_items.surface.objects[key].filter_offset * 1;
						temp.alpha = setup_items.surface.objects[key].alpha * 1;
						
						slot_text.push(temp);
						
						break;
				}
				zorder++;
			
			}
		}
	
		if (favFlag) {fe.add_transition_callback( this, "updateFavorite" )};
		

		base.constructor(surface);		
	}
	
	//
	// These functions can be overridden for anything
	// more complicated (than a single Image object)
	//
	function swap( other )
	{

		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].swap( other.slot_images[key] );
		};
		
		if ( slot_text.len() > 0) {
			foreach (key,value in slot_text)
			{
				// fallback if swap doesn't exist
				local tmp = other.slot_text[key].index_offset;
				other.slot_text[key].index_offset = slot_text[key].index_offset;
				slot_text[key].index_offset = tmp;
			}
		}
	};

	// Set the index offset and trigger a redraw:
	function set_index_offset( io ) 
	{ 
		
		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].index_offset = io ;
		}
		
		if ( slot_text.len() > 0)
		{
			foreach (key,value in slot_text)
				slot_text[key].index_offset = io;
		}
	}

	// Reset the index offset, preferably without triggering a redraw:
	function reset_index_offset()
	{
		if ( slot_images.len() > 0)
		{
			foreach (key,value in slot_images)
				slot_images[key].rawset_index_offset( m_base_io );
		}
		
		if ( slot_text.len() > 0)
		{
			foreach (key,value in slot_text)
				slot_text[key].index_offset = m_base_io ;
		}
		
	}
		
	function on_progress( progress, var )
	{
	
		local p = progress / (1.0 / gl_stopPoints);
		local slot = p.tointeger();
		p -= slot;
		
		if ( slot < 0 ) { slot = 0};
		if ( slot >= gl_stopPoints -1 ) { slot = gl_stopPoints -1 };
		local slot2 = slot+1;		
		
		// change positioning and sizes of the images
		m_obj.width = gi_w[slot] + p * ( gi_w[slot2] - gi_w[slot] );
		m_obj.height = gi_h[slot] + p * ( gi_h[slot2] - gi_h[slot] );
		m_obj.x = gi_x[slot] + p * ( gi_x[slot2] - gi_x[slot] );
		m_obj.y = gi_y[slot] + p * ( gi_y[slot2] - gi_y[slot] );
		m_obj.rotation = gi_r[slot] + p * ( gi_r[slot2] - gi_r[slot] );
		m_obj.alpha = gi_a[slot] + p * ( gi_a[slot2] - gi_a[slot] );
		m_obj.origin_x = m_obj.width * gi_oxmultiplier;
		m_obj.origin_y = m_obj.height * gi_oymultiplier;

		slot_images[1].alpha =  gi_sel_a[slot] + p * ( gi_sel_a[slot2] - gi_sel_a[slot] );

	//	change game name text properties (added dynamically in MyGameList.setSlotItemClass() )
		slot_text[text_fallback_index].width = gi_txt_width[slot] + p * ( gi_txt_width[slot2] - gi_txt_width[slot] );
		slot_text[text_fallback_index].height = gi_txt_height[slot] + p * ( gi_txt_height[slot2] - gi_txt_height[slot] ); 
		slot_text[text_fallback_index].x = gi_txt_x[slot] + p * ( gi_txt_x[slot2] - gi_txt_x[slot] );
		slot_text[text_fallback_index].y = gi_txt_y[slot] + p * ( gi_txt_y[slot2] - gi_txt_y[slot] ); 
		slot_text[text_fallback_index].rotation = m_obj.rotation; 
		slot_text[text_fallback_index].charsize = gi_text_size[slot] + p * ( gi_text_size[slot2] - gi_text_size[slot] );
		slot_text[text_fallback_index].red = gi_text_red[slot] + p * ( gi_text_red[slot2] - gi_text_red[slot] );
		slot_text[text_fallback_index].green =  gi_text_green[slot] + p * ( gi_text_green[slot2] - gi_text_green[slot] );
		slot_text[text_fallback_index].blue =  gi_text_blue[slot] + p * ( gi_text_blue[slot2] - gi_text_blue[slot] );	
		slot_text[text_fallback_index].alpha = m_obj.alpha;

//		fe.add_text(slot, m_obj.x,m_obj.y,m_obj.width,m_obj.height)
	/*
		Performance killing decision stuff
		These parts are indivalually added dynamically by MyGameList.setSlotItemClass()
		
	*/
	
	// hide text if artwork is available 
		(gi_textFallback) ? slot_text[text_fallback_index].visible = (slot_images[artwork_test_index].file_name =="")  : null;

	// turn off video playing if the current game item is not the selected one. (test using the alpha channel for background selected image)
		video_playing[video_status].call(this);
	};
	
	function newTextzorder()
	{
	/*
		Set the zorder of all text objects to be the highest on
		the fe.obj drawlist
	*/
		local test = null
		local highest = 0;
		test = fe.obj.len()
		foreach (key,value in fe.obj)
		{
			if (fe.obj[key].zorder > highest) highest = fe.obj[key].zorder;
		}
		
		foreach (key,value in slot_text)
		{
			slot_text[key].zorder = highest
		}
	
	};
	
	function updateFavorite(ttype, var, ttime)
	{
		if (fe.game_info( Info.Favourite, slot_images[1].index_offset) == "1")
		{
			slot_images[slot_images.len()-1].visible = true;
		} else {
			slot_images[slot_images.len()-1].visible = false;
		}	
		return false;
	}
	
};
	
class MyGameList
{

	// ----------- Spinwheel List Options -----------
	spinwheel = { shape = null, rotate_items = null, startDegree = null, effects = {x=1.00, y=1.00} };
	
	// ----------- Linear List Options -----------
	linear = {padding = 6};

	// ----------- List Item Bounding Box Options -----------
	item = {
		contentTemplate = null,
		count = null,
		sizeScaling = {low = null, high = null, currentlySelected = null},
		alphaScaling = {low = null, high = null, currentlySelected = null},	
		normal = { background = null,color = {red=0, green=0, blue=0} },
		currentlySelected = {  background = null, height = null, color = {red=0, green=0, blue=0} },
		margin = {left = null, right = null, top = null, bottom = null},
		toggle = {backgroundColor = false,
				  backgroundFile = false,
				  selectedBackgroundColor = false,
				  selectedBackgroundFile = false,
				  glossOverlay = false, 
				  borderOverlay = false}
		height = null,
		width = null,
		h_internal = null,
		w_internal = null
	};
	// ----------- List Item Content: Text -----------
	text = {
		message = null,
		alignment = null,
		word_wrap = null,
		normal = {font = null, size = null , color = {red=0, green=0, blue=0}},
		currentlySelected = {font = null, size = null, color = {red=0, green=0, blue=0}}
	};
	
	// ----------- List Item Content: Artwork -----------	
	artwork = {
		type = null,
		type2 = null,
		preserveAspect = null, 	
		height = null, 	
		favActive = false,
		favFile = null,
		favX = null,
		favY = null,
		favWidth = null,
		favHeight = null,
		favoriteImage = null,
	};
	
	// origin conveyor adjument value
	origin_multiplier = {x=null, y =null}
	
	// ------------ holds the game items configuration an objects stub -------------
	runtime = {
		surface = {
			container = null,
			objects = null, 
			objectTypes = null
		},
	};
	
	// ------------ holds custom user defined gameitem objects -------------
	customContent ={
		object = [],
		objectType = [],
		text = -1,
		images = 1

	}	
	
	// ------------ bend direction and radius for spinwheel ------------
	bend = { direction = null, gl_radius = null };
	
	// ------------ General game list settings ------------
	type = null; 
	height = null;
	width = null;
	x = null;
	y = null;
	ms_speed = null; // Sets the speed of the conveyor
	fade_after_nav = null;

	// ----------- Runtime non-user editable variables -----------
	amPath = null; // AttractMode Path
	conveyor_entries = null;	// array to hold the slot items in the conveyor
	gi_text_avaialble = null; // if true, the text portions of the conveyour will be added to on_progress
	gi_textFallback = null; // if true, the configured text object will be shown if artwork is not available
	text_fallback_index = null; // holds the index of the fallback object to display when artwork is not available
	artwork_test_index = null; // holds the index of the artwork to test when to determine the text fallback
	fade_active = false; // when > -1 then wheel fading is currently active
	fade_delay = 1500; // the amount of time in milliseconds before the fade should start
	fade_counter = 0; // who many times the fade has been perform for an interation
	fade_lastticktime = 0; // determines if the next fade step should occure
	fade_speed = 1; // the mulitplier controlling the speed of the fade
	fade_selected = false;	//	if gamelist fading is active, fade the selected if set to 	
	sel_game_offset = null;
	constructor()
	{
	
		// Setup Default Values
		
		// ----------- General List Options -----------	
		type = ch.Spinwheel; 					// OPTIONS: ch.Spinwheel / ch.Linear_Vertical / ch.Linear_Horizontal / ch.Coverflow
		bend.direction = ch.Right;  			// OPTIONS: ch.Left / ch.Right
		bend.gl_radius = fe.layout.height / 2;	// OPTIONS: radius of the spinwheel in pixels
		x = fe.layout.width / 2;				// OPTIONS: top left x-coordinate if gamelist is linear or the center x-coordinate if a Spinwheel or Coverflow
		y = fe.layout.height / 2;				// OPTIONS: top left y-coordinate if gamelist is linear or the center y-coordinate if a Spinwheel or Coverflow
		width = 270; 							// OPTIONS: linear game list total width in pixels
		height = 0; 							// OPTIONS: linear list's height in pixels
		ms_speed = 150;							// OPTIONS: in milliseconds, sets the speed of the conveyor
		fade_after_nav = 30;					// OPTIONS: 0-255 Fades the entire gamelist after navigation to this value. set to 255 to disable fading 
		fade_delay = 5000; 						// the amount of time in milliseconds before the fade should start
		fade_speed = 1; 						// the mulitplier controlling the speed of the fade
		fade_selected = false;					// OPTIONS: TRUE/FALSE fade selected game if gamelist fading is active
		
		// ----------- Spinwheel options -----------
		spinwheel.shape = 180; 						// OPTIONS: shape of the spinwheel arc in degrees eg: 270, 180, 360
		spinwheel.rotate_items = true;				// OPTIONS: true / false - Rotate the items along the spinwheel arc
		spinwheel.startDegree = 90;					// The degree on a circle to start drawing the spinwheel. From left to right 0= left, 90 = top, 180 = right, 270= bottom
		spinwheel.effects.x = 1.00;					// a number that changes the spinwheel algorithm to create cool effects
		spinwheel.effects.y = 1.00;					// a number that changes the spinwheel algorithm to create cool effects
		
		// ----------- Linear List options -----------
		linear.padding = 6;	// the amount of padding in pixels between each gamelist item

		
		// ----------- List Item  Options -----------
		item.contentTemplate = ch.Artwork_or_Text;		// OPTIONS: ch.Artwork / ch.Text / ch.Artwork_and_Text / ch.Artwork_or_Text / ch.Flyer_and_Artwork 
		item.count = 13; 							// OPTIONS: Total number of gamelist items to display

		item.sizeScaling.low = 0.20; 				// OPTIONS: 0-100 Scaling size percentage to use for the item furthest from the selected item 
		item.sizeScaling.high = 0.80; 				// OPTIONS: 0-100 Scaling size percentage to use for item closest to the selected item
		item.sizeScaling.currentlySelected = 1.0;	// OPTIONS: 0-100 Scaling size percentage to use for the currently selected item

		item.alphaScaling.low = 60; 				// OPTIONS: 0-100 Scaling size percentage to use for the item furthest from the selected item 
		item.alphaScaling.high = 210; 				// OPTIONS: 0-100 Scaling size percentage to use for item closest to the selected item
		item.alphaScaling.currentlySelected = 255;	// OPTIONS: 0-100 Scaling size percentage to use for the currently selected item

		item.height = 500; 							// OPTIONS: Height of each gameList item in pixels before scaling - dynamic with linear vertical lists
		item.width = 270 ;							// OPTIONS: Width of each gameList item in pixels before scaling - dynamic with linear horizontal lists
	
		item.margin.left = 10; 						// OPTION: bounding box left margin size for all images and text 
		item.margin.right = 10; 					// OPTION: bounding box right margin size for all images and text
		item.margin.top = 10;						// OPTION: bounding box top margin size for all images and text
		item.margin.bottom = 10;					// OPTION: bounding box bottom margin size for all images and text

		// ----------- List Item Content: borders / backgrounds / gloss / colors  -----------
		item.toggle.backgroundColor = false;			// if set to "TRUE" the game item background can be colored (use item.normal.color)
		item.toggle.backgroundFile = false;				// if set to "TRUE" the game item will use a file as the background (file: item_backgroundFile.png)
		item.toggle.selectedBackgroundColor = false; 	// if set to "TRUE" the selected game item background can be colored (use item.currentlySelected.color)
		item.toggle.selectedBackgroundFile = false;		// if set to "TRUE" the selected game item will use a file as the background (file: item_selectedBackgroundFile.png)
		item.toggle.glossOverlay = false;				// if set to "TRUE" will overlay the game item with a gloss file (file: item_glossOverlay.png)
		item.toggle.borderOverlay = false;				// if set to "TRUE" will overlay the game item with a boarder file (file: item_borderOverlay.png)
		
		item.normal.color.red = 128;					// OPTIONS: background red color channel 0 - 255
		item.normal.color.green = 0;                	// OPTIONS: background green color channel 0 - 255
		item.normal.color.blue = 128;                 	// OPTIONS: background blue color channel 0 - 255

		item.currentlySelected.color.red=0;				// OPTIONS: background red color channel 0 - 255
		item.currentlySelected.color.green=128;       	// OPTIONS: background green color channel 0 - 255
		item.currentlySelected.color.blue=128;        	// OPTIONS: background blue color channel 0 - 255

		
		// ----------- List Item Content: Text -----------
		text.message = "[Title]";
		text.alignment = Align.Centre;  			// OPTIONS:left/right/center
		text.word_wrap = true;						// OPTIONS: set word wrap for layouts with text
		text.normal.font = "Arial";
		text.normal.size = 16; 						// OPTIONS: text font size for every gameList item
		text.normal.color.red = 255;				// OPTIONS: text font red color channel 0 - 255
		text.normal.color.green = 255;				// OPTIONS: text font green color channel 0 - 255
		text.normal.color.blue = 128;				// OPTIONS: text font blue color channel 0 - 255
		
		text.currentlySelected.font = "Arial";
		text.currentlySelected.size = 18; 			// OPTIONS: text font size for every gameList item
		text.currentlySelected.color.red = 255;		// OPTIONS: text font red color channel 0 - 255
		text.currentlySelected.color.green = 255; 	// OPTIONS: text font green color channel 0 - 255
		text.currentlySelected.color.blue = 128;  	// OPTIONS: text font blue color channel 0 - 255

		// ----------- List Item Content: User Defined Artwork -----------	
		artwork.type = "wheel"; 		// OPTIONS: name of the artwork to use for the conveyour
		artwork.type2 = "snap";			// OPTIONS: name of the artwork to use for the conveyour setting "Flyer_and_Artwork"
		artwork.preserveAspect = false; // OPTIONS: true / false
		// add_favoriteImage(path,x,y,width,height); // add a favorite image to the game item. 
		
		// ------------ Options when creating custom gameitem objects -------------
		gi_textFallback = false; 	// When true, the game item will show the game name when no artwork is available
		text_fallback_index = -1;	// Only adjust if not working correctly. Set the index of the text object that should be shown when gi_textFallback=true
		artwork_test_index = -1;	// Only adjust if not working correctly. Set the index of the fe.image object which is to be tested when gi_textFallback = true		

		// Runtime variable configuration 
		runtime.surface.container = null;
		runtime.surface.objects = [1,2]; 		// holds the gamelist item object references
		runtime.surface.objectTypes = [1,2];	// holds the type of contents for later parsing
		amPath = fe.script_dir; 
		amPath = amPath.slice(0, amPath = amPath.find("layouts"));  // AttractMode Path
		gi_text_avaialble = false; // if true, the text portions of the conveyour will be added to on_progress
		gi_textFallback = false; // if true, the configured text object will be shown if artwork is not available
		text_fallback_index = -1; // holds the index of the fallback object to display when artwork is not available
		artwork_test_index = -1; // holds the index of the artwork to test when to determine the text fallback
		origin_multiplier.x = 0;
		origin_multiplier.y = 0;
	}
	function fileExist(filename)
	{
	
		local test = null;
		local result = false;
		try {
			test = file(filename, "r" );	
			test.close();
			result = true;
		} catch (e) {
			print(e);
		
		}
		
		return result;
	}
	function get_artworkTestName()
	{
	
		local test = null;
		local count_artwork = -1;
		local result = null;
		local content_type = null;
		
		// find the fallback artwork name
		foreach (key,value in runtime.surface.objectTypes)
		{
			content_type = split(value, "|");			
			if (content_type[0] != "fe.Text")
			{
				count_artwork++
				if (count_artwork == artwork_test_index)
				{
					result = content_type[1]
					break;
				}				
			}	
		}
		
		return result;
	}	
	
	function setSurfaceContainer(){
		
		if (runtime.surface.container == null) { runtime.surface.container = fe.add_surface(item.width, item.height)};
		return;
	}
	
	function setSlotItemClass(_stype="")
	{
	/* 
		This function dynamically changes the various function contained in the class
		"SpinwheelSlotItem" and "LinearSlotItem" optimizing the changing of artwork and text
		specifically for the artwork and text chosen. This ensures
		decision logic and operations are not in the conveyor
		that can lead to slow downs with resource intensive conveyor slots"
		
		Affected functions are on_progress(), swap(), reset_index_offset(), and set_index_offset()
	*/
	
		if (_stype == "") return; // cancel if type of slotitemclass to configure is empty
	
		local do_it = null;
		local tmp = null;
		local text_index = 0; // current text index
		local image_index = 0; // current image index
		local bg_index = 1; // index of the last background image
		
		// Configuration settings based upon the type of gamelist
		local slot_type = {
			spinwheel = { 
				on_progress_pre = "function SpinwheelSlotItem::on_progress( progress, var ) {local p = progress /"+(1.0 / item.count)+";local slot = p.tointeger();p -= slot;if ( slot < 0 ) { slot = 0};if ( slot >= gl_stopPoints -1 ) { slot = gl_stopPoints -1};local slot2 = slot+1;m_obj.x = gi_x[slot] + p * ( gi_x[slot2] - gi_x[slot] );m_obj.y = gi_y[slot] + p * ( gi_y[slot2] - gi_y[slot] );m_obj.width = gi_w[slot] + p * ( gi_w[slot2] - gi_w[slot] );m_obj.height = gi_h[slot] + p * ( gi_h[slot2] - gi_h[slot] );m_obj.rotation = gi_r[slot] + p * ( gi_r[slot2] - gi_r[slot] );m_obj.alpha = gi_a[slot] + p * ( gi_a[slot2] - gi_a[slot] );m_obj.origin_y = m_obj.height / 2;slot_images[1].alpha =  gi_sel_a[slot] + p * ( gi_sel_a[slot2] - gi_sel_a[slot] );",

				swap_pre = "function SpinwheelSlotItem::swap( other ){",
				set_index_offset_pre = "function SpinwheelSlotItem::set_index_offset( io ) {",
				reset_index_offset_pre = "function SpinwheelSlotItem::reset_index_offset() {",
				
				text_progress = "slot_text[" + text_fallback_index + "].alpha = m_obj.alpha;slot_text[" + text_fallback_index + "].charsize = gi_text_size[slot] + p * ( gi_text_size[slot2] - gi_text_size[slot] );slot_text[" + text_fallback_index + "].red = gi_text_red[slot] + p * ( gi_text_red[slot2] - gi_text_red[slot] );slot_text[" + text_fallback_index + "].green =  gi_text_green[slot] + p * ( gi_text_green[slot2] - gi_text_green[slot] );",
				updateFavorite_pre = "function SpinwheelSlotItem::updateFavorite(ttype, var, ttime){"
				set_video_pre = "SpinwheelSlotItem.video_playing <- ["
			},
			coverflow = { 
				on_progress_pre = "function CoverflowSlotItem::on_progress( progress, var ) {local p = progress /"+(1.0 / item.count)+";local slot = p.tointeger();p -= slot;if ( slot < 0 ) { slot = 0};if ( slot >= gl_stopPoints -1 ) { slot = gl_stopPoints -1};local slot2 = slot+1;m_obj.x = gi_x[slot] + p * ( gi_x[slot2] - gi_x[slot] );m_obj.y = gi_y[slot] + p * ( gi_y[slot2] - gi_y[slot] );m_obj.width = gi_w[slot] + p * ( gi_w[slot2] - gi_w[slot] );m_obj.height = gi_h[slot] + p * ( gi_h[slot2] - gi_h[slot] );m_obj.rotation = gi_r[slot] + p * ( gi_r[slot2] - gi_r[slot] );m_obj.alpha = gi_a[slot] + p * ( gi_a[slot2] - gi_a[slot] );m_obj.origin_y = m_obj.height / 2;slot_images[1].alpha =  gi_sel_a[slot] + p * ( gi_sel_a[slot2] - gi_sel_a[slot] );		m_obj.pinch_y = gi_py[slot] + p * ( gi_py[slot2] - gi_py[slot] );",
				swap_pre = "function CoverflowSlotItem::swap( other ){",
				set_index_offset_pre = "function CoverflowSlotItem::set_index_offset( io ) {",
				reset_index_offset_pre = "function CoverflowSlotItem::reset_index_offset() {",
				
				text_progress = "slot_text[" + text_fallback_index + "].alpha = m_obj.alpha;slot_text[" + text_fallback_index + "].charsize = gi_text_size[slot] + p * ( gi_text_size[slot2] - gi_text_size[slot] );slot_text[" + text_fallback_index + "].red = gi_text_red[slot] + p * ( gi_text_red[slot2] - gi_text_red[slot] );slot_text[" + text_fallback_index + "].green =  gi_text_green[slot] + p * ( gi_text_green[slot2] - gi_text_green[slot] );",
				updateFavorite_pre = "function CoverflowSlotItem::updateFavorite(ttype, var, ttime){"
				set_video_pre = "CoverflowSlotItem.video_playing <- ["
			},
			linear = {

				on_progress_pre = "function LinearSlotItem::on_progress( progress, var ) {local p = progress /"+(1.0 / item.count)+";local slot = p.tointeger();p -= slot;if ( slot < 0 ) { slot = 0};if ( slot >= gl_stopPoints -1 ) { slot = gl_stopPoints -1};local slot2 = slot+1;		m_obj.width = gi_w[slot] + p * ( gi_w[slot2] - gi_w[slot] );m_obj.height = gi_h[slot] + p * ( gi_h[slot2] - gi_h[slot] );m_obj.x = gi_x[slot] + p * ( gi_x[slot2] - gi_x[slot] );m_obj.y = gi_y[slot] + p * ( gi_y[slot2] - gi_y[slot] );m_obj.rotation = gi_r[slot] + p * ( gi_r[slot2] - gi_r[slot] );m_obj.alpha = gi_a[slot] + p * ( gi_a[slot2] - gi_a[slot] );",
				swap_pre = @"function LinearSlotItem::swap( other ){",
				set_index_offset_pre = "function LinearSlotItem::set_index_offset( io ) {",
				reset_index_offset_pre = "function LinearSlotItem::reset_index_offset() {",
				
				text_progress = "slot_text[" + text_fallback_index + "].alpha = m_obj.alpha;slot_text[" + text_fallback_index + "].width = gi_txt_width[slot] + p * ( gi_txt_width[slot2] - gi_txt_width[slot] );slot_text[" + text_fallback_index + "].height = gi_txt_height[slot] + p * ( gi_txt_height[slot2] - gi_txt_height[slot] );slot_text[" + text_fallback_index + "].x = gi_txt_x[slot] + p * ( gi_txt_x[slot2] - gi_txt_x[slot] );slot_text[" + text_fallback_index + "].y = gi_txt_y[slot] + p * ( gi_txt_y[slot2] - gi_txt_y[slot] ); slot_text[" + text_fallback_index + "].rotation = m_obj.rotation;slot_text[" + text_fallback_index + "].charsize = gi_text_size[slot] + p * ( gi_text_size[slot2] - gi_text_size[slot] );slot_text[" + text_fallback_index + "].red = gi_text_red[slot] + p * ( gi_text_red[slot2] - gi_text_red[slot] );slot_text[" + text_fallback_index + "].green =  gi_text_green[slot] + p * ( gi_text_green[slot2] - gi_text_green[slot] );slot_text[" + text_fallback_index + "].blue =  gi_text_blue[slot] + p * ( gi_text_blue[slot2] - gi_text_blue[slot] );",
				updateFavorite_pre = "function LinearSlotItem::updateFavorite(ttype, var, ttime){"
				set_video_pre = "LinearSlotItem.video_playing <- ["
			},
			
			because_my_editor_is_stupid ="}}}}}}}}}} and does not regonize that the above open brackets are enclosed in text and should not affect showing the function list correctly",
		};
		
		
	/* 
		load the static contents into strings
		- the "_var" variables contain the parts of the slotitem that can vary
		_pre, _var, and _post variables are combined and compiled at runtime
	*/ 
		//														 
		// Prepare Variable parts of the on_progress function
																											
		local text_handling = slot_type[_stype].text_progress;
		local text_fallback = "slot_text[" + text_fallback_index +"].visible = (slot_images["+artwork_test_index+"].file_name ==\"\");";
		local image_originx = (origin_multiplier.x == 1) ? "m_obj.origin_x = m_obj.width;" : "m_obj.origin_x = m_obj.width * gi_oxmultiplier;";
		local image_originy = (origin_multiplier.y == 1) ? "m_obj.origin_y = m_obj.height;" : "m_obj.origin_y = m_obj.height * gi_oymultiplier;";
		
		// on_progress()
		local on_progress_pre = slot_type[_stype].on_progress_pre
		local on_progress_var = "";
		local on_progress_post = "video_playing[video_status].call(this);};"
		
		// swap()
		local swap_pre = slot_type[_stype].swap_pre
		local swap_var = "";
		local swap_post = @"};";

		// set_index_offset()		
		local set_index_offset_pre = slot_type[_stype].set_index_offset_pre
		local set_index_offset_var ="";
		local set_index_offset_post	="};";
		
		// reset_index_offset()
		local reset_index_offset_pre = slot_type[_stype].reset_index_offset_pre
		local reset_index_offset_var="";
		local reset_index_offset_post="};";
		
		// updateFavorite()
		local updateFavorite_pre = slot_type[_stype].updateFavorite_pre
		local updateFavorite_var="";
		local updateFavorite_post="};";
		
		// video_playing variable
		local set_video_pre = slot_type[_stype].set_video_pre;
		local set_video_var = ""
		local set_video_post = "];"
		local set_video_on = "function(){";
		local set_video_off = "function(){";
		
	/*
		Configure on_progress() varabile additions
	
	*/ 
		
		// Add change origin
		on_progress_var = (origin_multiplier.x > 0) ? on_progress_var + image_originx : on_progress_var;
		on_progress_var = (origin_multiplier.y > 0) ? on_progress_var + image_originy : on_progress_var;
		
		// Add text handling
		on_progress_var = (gi_textFallback || item.contentTemplate == ch.Text) ? on_progress_var + text_handling : on_progress_var;
		
		// Add text fallback
		on_progress_var = (gi_textFallback) ? on_progress_var + text_fallback : on_progress_var;
		
		
	/*
		Configure reset_index_offset(), set_video,
		set_index_offset(), updateFavorite() 
		and swap() variable additions
	
	*/
		foreach (key,value in runtime.surface.objectTypes)
		{
			tmp = split(value, "|");
			
			if ( (tmp[0] == "fe.Image") || (tmp[0] == "fe.Artwork") )
			{
				if (image_index >= bg_index ) //skip processing if image is a background image 
				{
					swap_var = swap_var + "slot_images[" + image_index + "].swap( other.slot_images[" + image_index + "] );";
					set_index_offset_var = set_index_offset_var + "slot_images[" + image_index + "].index_offset = io;";
					reset_index_offset_var = reset_index_offset_var + "slot_images[" + image_index + "].rawset_index_offset( m_base_io );";
					
					if (tmp.len() > 1) {
						set_video_off = set_video_off + "slot_images[" + image_index + "].video_flags = Vid.NoAudio;"
						set_video_on = set_video_on + "slot_images[" + image_index + "].video_flags = Vid.Default;"
					}
					
				}
				image_index++;
			}
			
			if (tmp[0] == "fe.Text")
			{
				swap_var = swap_var + @"local tmp = other.slot_text[" + text_index + @"].index_offset;other.slot_text[" + text_index + @"].index_offset = slot_text[" + text_index + @"].index_offset;slot_text[" + text_index + "].index_offset = tmp;";
				set_index_offset_var = set_index_offset_var + "slot_text[" + text_index + "].index_offset = io;";;
				reset_index_offset_var = reset_index_offset_var + "slot_text[" + text_index + "].index_offset = m_base_io;";
				text_index++
			};
		};
		
	//	Configure set_video_var
		set_video_var = set_video_on + "}," + set_video_off + "}" ;
		
	/*
		Configure the updateFavorite()
		variable definitions
	*/
		if (artwork.favActive) {
			image_index--
			updateFavorite_var = "if (fe.game_info( Info.Favourite, slot_images["+ bg_index +"].index_offset) == \"1\"){slot_images[" + image_index + "].visible = true;} else {slot_images[" + image_index + "].visible = false;} return false;";
		
		}
		
	/*
			compile all strings
	*/
		local tmp = on_progress_pre + on_progress_var + on_progress_post;
		do_it = compilestring(tmp);
		do_it();
		
 		local tmp = swap_pre + swap_var + swap_post;
		do_it = compilestring(tmp);
		do_it();
		
		local tmp = set_index_offset_pre + set_index_offset_var + set_index_offset_post
		do_it = compilestring(tmp);
		do_it();


		local tmp = reset_index_offset_pre + reset_index_offset_var + reset_index_offset_post;
		do_it = compilestring(tmp);
		do_it();
		
		local tmp = set_video_pre + set_video_var + set_video_post;
		do_it = compilestring(tmp);
		do_it();
		
 		local tmp = updateFavorite_pre + updateFavorite_var + updateFavorite_post;
		do_it = compilestring(tmp);
		do_it();
		
	}; // End setSlotItemClass()
		
	//  
	function setGameItemContent()
	{
	/* 
		Create the configured gamelist item contents - text and artwork, borders, colors, etc.
		Templates are defined here e.g. ch.Artwork_and_Text to determine how to do the gameitem setup
		
		All images and settings are added to the object variables: runtime.surface.container,
		runtime.surface.objects, and runtime.surface.objectTypes. These variables are passed to the conveyor slot
		and used during the on_progress function.
		
		!! Every GameItem contains two background images (1)the normal selected background and (2)the selected game background

	*/
		
		// ensure runtime.surface.container has the correct width and height;
		setSurfaceContainer(); 
		
		// configure margins for artwork and other items
		local x = item.margin.left;
		local y = item.margin.top;
		local w = runtime.surface.container.width - item.margin.left - item.margin.right;
		local h = runtime.surface.container.height - item.margin.top - item.margin.bottom;
		local temp = null; // temp to configure item settings
		local filename = null;

		
		// Configure game item background and color
		if (item.toggle.backgroundFile) 
		{
		/*
			add normal game item background file 
			and optionally colorize it
		
		*/
			filename = fe.script_dir + "item_backgroundFile.png";
			filename = (fileExist(filename)) ? filename :  amPath + "modules/conveyour_helper/item_backgroundFile.png";
			temp = add_gameItemsContent("background",filename,x,y,w,h);
			
			if (item.toggle.backgroundColor)
			{
				temp.red = item.normal.color.red;
				temp.green = item.normal.color.green;
				temp.blue = item.normal.color.blue;
			}
		
		} else {
		/*
			just add a blank background and color it
			if a background file is not being used
		
		*/
			filename = amPath + "modules/conveyour_helper/ui_backgroundColor.png";
			temp = add_gameItemsContent("background",filename,x,y,w,h);
			temp.red = item.normal.color.red;
			temp.green = item.normal.color.green;
			temp.blue = item.normal.color.blue;
			temp.visible = (item.toggle.backgroundColor);
		
		}
		
		// Configure selected game item background and color
		if (item.toggle.selectedBackgroundFile) 
		{
		/*
			add selected game item background file 
			and optionally colorize it
		
		*/
			filename = fe.script_dir + "item_selectedBackgroundFile.png";
			filename = (fileExist(filename)) ? filename :  amPath + "modules/conveyour_helper/item_selectedBackgroundFile.png";
			temp = add_gameItemsContent("selected",filename,x,y,w,h);
			
			if (item.toggle.selectedBackgroundColor)
			{
				temp.red = item.currentlySelected.color.red;
				temp.green = item.currentlySelected.color.green;
				temp.blue = item.currentlySelected.color.blue;
			}
		
		} else {
		/*
			just add a blank background and color it
			if a background file is not being used
		
		*/
			filename = amPath + "modules/conveyour_helper/ui_backgroundColor.png";
			temp = add_gameItemsContent("selected",filename,x,y,w,h);
			temp.red = item.currentlySelected.color.red;
			temp.green = item.currentlySelected.color.green;
			temp.blue = item.currentlySelected.color.blue;
			temp.visible = (item.toggle.selectedBackgroundColor);
		}		
		

		
		switch(item.contentTemplate)
		{
		/*
			Template configuration is done here to determine
			how the gameitem's image, artwork, and text content
			should look
			
			=-=-=-=-=-=-
			Notes
			=-=-=-=-=-=-
			
			Game name text object
			-----------------------------
			Always ensure the gameName text index is set to ensure the conveyour changes the text colors correctly
			
			Template Names
			-----------------------------
			make sure to add the template name to the 'ch' constant
			
			Logic settings when defining a template
			---------------------------------------
			
			gi_textFallback = true; // if true, the configured text object will be shown if artwork is not available
			text_fallback_index = 0; // holds the index of textobject to show the game name when artwork is not available
			artwork_test_index = 2; // holds the index of the artwork that should be tested during text fallback
			artwork.type and artwork.type2 = holds the name of the artwork a user can configure
		
			IMPORTANT!!
			----------------------------------------
			for test_artwork count the number of from 0 the amount of images and artworks objects
			for text_fallback_index count from 0 the number of text objects
			
		*/			
			case ch.Artwork: // Artwork only template settings
				temp = add_gameItemsContent("artwork", artwork.type, x ,y ,w ,h );
				temp.preserve_aspect_ratio = artwork.preserveAspect;
				temp.visible = true;
				
				break;
				
			case ch.Text:	// Text only template
				temp = add_gameItemsContent("text",text.message, x, y, w, h);
				temp.font = text.normal.font;
				temp.charsize  = text.normal.size;
				temp.align = text.alignment;
				temp.set_rgb(text.normal.color.red, text.normal.color.green, text.normal.color.blue);
				temp.word_wrap = text.word_wrap;
				text_fallback_index = 0;
				
				break;
				
			case ch.Artwork_and_Text: // add text and artwork to do
				temp = add_gameItemsContent("artwork", artwork.type, x ,y ,w ,h * 0.65 );
				temp.preserve_aspect_ratio = artwork.preserveAspect;
				temp.trigger = Transition.EndNavigation;
				
				temp = add_gameItemsContent("text",text.message, x, h*0.83, w,0);
				temp.font = text.normal.font;
				temp.charsize  = text.normal.size;
				temp.align = text.alignment;
				temp.set_rgb(text.normal.color.red, text.normal.color.green, text.normal.color.blue);
				break;
				
			case ch.Artwork_or_Text:
				gi_textFallback = true;
				text_fallback_index = 0; // holds the index of textobject to show the game name when artwork is not available
				artwork_test_index = 2; // holds the index of the artwork to test when to determine the text fallback
				
				temp = add_gameItemsContent("artwork",artwork.type, x ,y ,w ,h );
				temp.preserve_aspect_ratio = artwork.preserveAspect;
				temp.trigger = Transition.EndNavigation;				
				
				temp = add_gameItemsContent("text",text.message, x, y, w, h);
				temp.font = text.normal.font;
				temp.charsize  = text.normal.size;
				temp.align = text.alignment;
				temp.set_rgb(text.normal.color.red, text.normal.color.green, text.normal.color.blue);
				temp.word_wrap=text.word_wrap;
				temp.visible = false;
				break;
			
			case ch.Flyer_and_Artwork: // adds flyer, text and artwork
				
				gi_textFallback = true;
				text_fallback_index = 0;
				artwork_test_index = 2;				
				
				temp = add_gameItemsContent("artwork", artwork.type, x + ( w * 0.4 ),y +( h * 0.1 ), w * 0.55,h * 0.80 );
				temp.preserve_aspect_ratio = artwork.preserveAspect;
				temp.trigger = Transition.EndNavigation;
				
				temp = add_gameItemsContent("text", text.message,    x + ( w * 0.4), y +( h * 0.1 ), w * 0.55, h * 0.80 );
				temp.font = text.normal.font;
				temp.charsize  = text.normal.size;
				temp.align = text.alignment;
				temp.set_rgb(text.normal.color.red, text.normal.color.green, text.normal.color.blue);
				
 				temp = add_gameItemsContent("artwork",artwork.type2, x + (w*0.04) ,y + (h*0.1) ,w*0.31 ,h * 0.80 );
				temp.preserve_aspect_ratio = artwork.preserveAspect;
				temp.trigger = Transition.EndNavigation;
				break;
			
			case ch.Custom:
				// nothing to do because it was already handled in add_customGameItemContent();
				null;
				
				
				if (gi_textFallback)
			/*
				both switches need to be above -1 to be valid
			*/
				{
					if ((text_fallback_index == -1) || (artwork_test_index == -1)) {gi_textFallback = false};
				}
				break;
		}
		
		
		if (item.toggle.glossOverlay)
		{
			filename = fe.script_dir + "item_glossOverlay.png"
			filename = (fileExist(filename)) ? filename :  amPath + "modules/conveyour_helper/item_glossOverlay.png"
			temp = add_gameItemsContent(
				"image",
				filename,					
				0,
				0,
				runtime.surface.container.width,
				runtime.surface.container.height
			);
		}
		
		if (item.toggle.borderOverlay)
		{
			filename = fe.script_dir + "item_borderOverlay.png";
			filename = (fileExist(filename)) ? filename :  amPath + "modules/conveyour_helper/item_borderOverlay.png";
			temp = add_gameItemsContent(
				"image",
				filename,					
				0,
				0,
				runtime.surface.container.width,
				runtime.surface.container.height
			);
		}
		
	
		if (artwork.favActive)
		{
			filename = artwork.favFile
			temp = add_gameItemsContent(
				"image",
				filename,					
				artwork.favX,
				artwork.favY,
				artwork.favWidth,
				artwork.favHeight
			);
		}
		
		
		
		
		
		return;
	} // End: createGameItemContent
	
	function setLinearStops()
	{
	/* 
		create Linear Conveyor stops  
	
	*/	
	
	// game list user settings from MyGameList.constructor()
		local gl_type = type; 	
		local gl_stopPoints = item.count;			
		local gl_topLeftX = x; 
		local gl_topLeftY = y;
		local gl_height = height.tofloat();
		local gl_width = width.tofloat();
		local gi_height = item.height.tofloat(); // height of the gameitem - is dynamic if gl_type == ch.Linear_Vertical
		local gi_width = item.width.tofloat(); // width of the gameitem - is dynamic if gl_type == ch.Linear_Horizontal
		local gi_x = 0 // x coordinate of the game item
		local gi_y = 0 // y coordinate of the game item		
		local gi_visible = item.count - 1; // total number of gameitems that should be visible
		local gi_padding = linear.padding; // gameitem padding for linear list
		local gi_alphaLow	= item.alphaScaling.low;
		local gi_alphaHigh = item.alphaScaling.high;
		local gi_alphaCurrentlySelected = item.alphaScaling.currentlySelected;
		local gi_scaleLow = item.sizeScaling.low;
		local gi_scaleHigh = item.sizeScaling.high;
		local gi_scaleCurrentlySelected = item.sizeScaling.currentlySelected;
		
	// function() game item x,y,width,height, alpha, and scaling processing variables
		local gi_angle = 0;			// gi_angle of the current coordinate in radians  
		local gi_alphaSlice = 0;	// size of each game item alpha step along the conveyor		
		local gi_scaleSlice = 0;	// size of each game item scaling step along the conveyor
		local gi_alpha = null;  // new game item alpha value after calculating the current conveyor stop
		local gi_sel_a = 0; // game item selected background alpha - 0 = game item is normal, 255= game item is selected
		local gi_widthNew = null; // new game item width value after calculating the current conveyor stop 
		local gi_heightNew = null;  // new game item height value after calculating the current conveyor stop 
		local gi_ox = null; 
		local gi_oy = null;
	
		local gi_txt_widthNew = null; // width of the fallback text object after resizing
		local gi_txt_heightNew = null; // height of the fallback text object after resizing
		local gi_txt_x = null; // x location of the fallback text object along the conveyour
		local gi_txt_y = null; // y location of the fallback text object along the conveyour
		local gi_txt_width = null; // width of the fallback text object along the conveyour
		local gi_txt_height = null; // height of the fallback text object along the conveyour
		local gi_txt_left_start = null; // starting x location of the fallback text object along the conveyour
		local gi_txt_top_start = null; // starting y location of the fallback text object along the conveyour
        local gi_txt_w_start = null; // starting width of the fallback text object along the conveyour
		local gi_txt_h_start = null; // starting height of the fallback text object along the conveyour
		local gi_type = "normal"; // "normal" or "currentlySelected". Index used to select the correct coloring for text

		local i = 0; // Loop variable
		
		local logicSwitchSelected = false; // logic switch game item calculation is for the selected game item
		local logicSwitchVertical = (gl_type == ch.Linear_Vertical); // logic switch game item calculation for a vertical list 
		local logicSwitchHigh = false; // logic switch game item calculation process game items to the left or above the selected item
		local logicSwitchLow = false; // logic switch game item calculation process game items to the right or below the selected item
		local logicSwitchEndNow = false; // logic switch, end the calculation of game item 
	
	/* 
		table containing all of the computed
		coordinates, gi_angles, color changes
		for use in the LinearSlotItem()
		
	*/
		local results = {			
				gl_x=0,	gl_y=0, 	// gamelist location
				gi_x=[], gi_y=[],	// game item location coordinates
				gi_r=[], gi_a=[],	// game item rotation and alpha settings
				gi_w=[], gi_h=[],	// game item dimensions
				gi_text_size=[],			// game item text size
				gi_text_red = [], gi_text_green =[], gi_text_blue = [], // game item text colors
				gi_red = [], gi_green = [], gi_blue = [], // game item background colors
				gl_stopPoints = 0,		// total number of gameitems
				gi_sel_a = [], // alpha slot values for the selected game image
				gi_txt_width=[],
				gi_txt_height=[],
				gi_txt_x=[], gi_txt_y=[],
				gi_ox = [], gi_oy =[]

		};
		
	// Setup Static values
		results.gl_stopPoints = gl_stopPoints;

			
	/*
		setup text defaults
		determine text fallback object x,y, 
		width, and height dimensions	
		also does this if ch.Text is active
	*/
		
		local fallback_index = runtime.surface.objectTypes.find("fe.Text|fallbackFlag");
		fallback_index = (item.contentTemplate == ch.Text) ? fallback_index = 2 : fallback_index;
		if (fallback_index != null)
		{
			gi_txt_left_start = runtime.surface.objects[fallback_index].x
			gi_txt_top_start = runtime.surface.objects[fallback_index].y
			gi_txt_w_start= runtime.surface.objects[fallback_index].width
			gi_txt_h_start= runtime.surface.objects[fallback_index].height

		} else {
			gi_txt_left_start = item.margin.left
			gi_txt_top_start = item.margin.top
			gi_txt_w_start= item.width - (item.margin.left + item.margin.right) 
			gi_txt_h_start=  item.height -(item.margin.top + item.margin.bottom)
		}

		// configure alpha and scale steps when stepping through the loop if num of item > 1
		gi_alphaSlice = (gi_alphaHigh - gi_alphaLow) / (gl_stopPoints.tofloat()/2);
		gi_scaleSlice = (gi_scaleHigh - gi_scaleLow) / (gl_stopPoints.tofloat()/2);		
		
		for ( i = -1; i < gl_stopPoints; i++)
		{
			// toggle logicSwitches
			
			if (i < gl_stopPoints /2 -1) { logicSwitchLow = true } else
			if (i > gl_stopPoints /2 -1) { logicSwitchHigh = true } else 
				{logicSwitchSelected = true}
			if (gl_stopPoints == 1) {logicSwitchSelected = true}

			if (logicSwitchVertical)
			{
				if (logicSwitchHigh)
				{
				/*
					configure the selected item width, height scaling and alpha settings
					for the game items above or to the left of the selected game item
				*/
					gi_alpha = ( gl_stopPoints - i -1 ) * gi_alphaSlice + gi_alphaLow ;
											 
					gi_widthNew = ((( gl_stopPoints - i ) * gi_scaleSlice ) + gi_scaleLow )*gi_width;
					gi_heightNew = gl_height / gi_visible - gi_padding;
					gi_x = gl_topLeftX;
					gi_y = gl_topLeftY * (gi_heightNew / gi_height) + ((gi_heightNew + gi_padding) * i); 
								
				}
					
				if ((logicSwitchLow))
				{
				/*
					configure the selected item width, height scaling and alpha settings
					for the game items below or to the right of the selected game item
				*/	
					gi_alpha = i * gi_alphaSlice + gi_alphaLow ;
					
					gi_widthNew = (((i+2) * gi_scaleSlice ) + gi_scaleLow ) * gi_width;
					gi_heightNew = gl_height / gi_visible - gi_padding;
					gi_x = gl_topLeftX;
					gi_y = gl_topLeftY * (gi_heightNew / gi_height) + ((gi_heightNew + gi_padding) * i);
				}
			
				if (logicSwitchSelected) 
				{
					
				/*
					configure the selected item width, height scaling and alpha settings
					for the selected game item
				*/
					
					gi_type = "currentlySelected";
					gi_sel_a = 255;
					gi_alpha = item.alphaScaling.currentlySelected;
					
				
					gi_widthNew = gi_scaleCurrentlySelected * gi_width;
					gi_heightNew = gl_height / gi_visible - gi_padding;
					gi_x = gl_topLeftX;
					gi_y = gl_topLeftY * (gi_heightNew / gi_height) + ((gi_heightNew + gi_padding) * i);
					
				// ensure even number list counts are symetrical when scaling
/* 
	Broken- needs to happen after all gi have been computed.
					if (gl_stopPoints % 2 !=0)
					{
						results.gi_w[i] = gi_widthNew;
						results.gi_h[i] = gi_heightNew;
						results.gi_txt_width[i] = gi_txt_w_start * (gi_widthNew / gi_width);
						results.gi_txt_height[i] = gi_txt_h_start * (gi_heightNew / gi_height);
					} 
					
 */
				} 

				gi_txt_x = (origin_multiplier.x != 0) ? gi_x - gi_widthNew + gi_txt_left_start : gi_x + gi_txt_left_start;
				gi_txt_y = 	gi_y + gi_txt_top_start;
				
			} // --> End Vertical Linear List
			
			if (!logicSwitchVertical) {
				if (logicSwitchHigh)
				{
				/*
					configure the selected item width, height scaling and alpha settings
					for the game items above or to the left of the selected game item
				*/
					gi_alpha = ( gl_stopPoints - i ) * gi_alphaSlice + gi_alphaHigh ;
					
					gi_widthNew = gl_width / gi_visible - gi_padding;
					gi_heightNew = ((( gl_stopPoints - i ) * gi_scaleSlice ) + gi_scaleHigh )* gi_height;
					gi_x = gl_topLeftX * (gi_widthNew / gi_width) + ((gi_widthNew + gi_padding) * i);
					gi_y = gl_topLeftY;
					
				}
					
				if ((logicSwitchLow))
				{
				/*
					configure the selected item width, height scaling and alpha settings
					for the game items below or to the right of the selected game item
				*/	
					gi_alpha = i * gi_alphaSlice + gi_alphaLow ;

					gi_widthNew = gl_width / gi_visible - gi_padding;
					gi_heightNew = ((i * gi_scaleSlice ) + gi_scaleLow ) * gi_height;
					gi_x = gl_topLeftX * (gi_widthNew / gi_width) + ((gi_widthNew + gi_padding) * i);
					gi_y = gl_topLeftY;
				}
							
				if (logicSwitchSelected) 
				{
				/*
					configure the selected item width, height scaling and alpha settings
					for the selected game item
				*/
					gi_type = "currentlySelected";
					gi_sel_a = 255;
					gi_alpha = item.alphaScaling.currentlySelected;
				
					gi_widthNew = gl_width / gi_visible - gi_padding;
					gi_heightNew = gi_scaleCurrentlySelected * gi_height; 	
					gi_x = gl_topLeftX * (gi_widthNew / gi_width) + ((gi_widthNew + gi_padding) * i);
					gi_y = gl_topLeftY;
				}

			gi_txt_x = gi_x + gi_txt_left_start;
			gi_txt_y = (origin_multiplier.y != 0) ? gi_y - gi_heightNew + gi_txt_top_start: gi_y + gi_txt_top_start;	
				
			}// --> End Horizontal Linear List
			
			// set the text info
			gi_txt_width =  gi_txt_w_start * (gi_widthNew / gi_width);
			gi_txt_height = gi_txt_h_start * (gi_heightNew / gi_height);
			
			// Push all settings into the array
			results.gi_x.push(gi_x)
			results.gi_y.push(gi_y)			
			results.gi_txt_x.push(gi_txt_x)
			results.gi_txt_y.push(gi_txt_y)
			results.gi_txt_width.push(gi_txt_width);
			results.gi_txt_height.push(gi_txt_height);
			results.gi_sel_a.push(gi_sel_a);
			results.gi_a.push(gi_alpha);
			results.gi_r.push(0);
			results.gi_w.push(gi_widthNew);
			results.gi_h.push(gi_heightNew);
			results.gi_text_size.push(text[gi_type].size);
			results.gi_text_red.push(text[gi_type].color.red);
			results.gi_text_green.push(text[gi_type].color.green);
			results.gi_text_blue.push(text[gi_type].color.blue);
			results.gi_red.push(item[gi_type].color.red);
			results.gi_green.push(item[gi_type].color.green);
			results.gi_blue.push(item[gi_type].color.blue);
			
			// Reset Logik Switches
			gi_type = "normal";
			gi_sel_a = 0;
			logicSwitchHigh = false;
			logicSwitchLow = false;
			logicSwitchSelected = false;
						
		}
			
		// if (logicSwitchVertical) {
//			results.gi_txt_x.reverse();
//			results.gi_txt_y.reverse();
			results.gi_txt_width.reverse();
			results.gi_txt_height.reverse();
			results.gi_sel_a.reverse();
			results.gi_a.reverse();
			results.gi_r.reverse();
			results.gi_w.reverse();
			results.gi_h.reverse();
			results.gi_text_size.reverse();
			results.gi_text_red.reverse();
			results.gi_text_green.reverse();
			results.gi_text_blue.reverse();
			results.gi_red.reverse();
			results.gi_green.reverse();
			results.gi_blue.reverse();
		// }
		
		
		return results;
	};
	
	function setCoverFlowStops()
	{
	/* 
		create spin wheel stops based
		upon calculation gl_stopPoints on an arc 
		
	*/	
		
		local gl_stopPoints = item.count; 		// total number of game list items
		local gl_radius = bend.gl_radius;				// gl_radius in pixels the circle should be
		local gl_w = width; //the total width of the game list
		local gl_x = x; // x-coordinate center of the game list 
		local gl_y = y; // y-coordinate center of the game list
		
		local gi_alphaLow = item.alphaScaling.low;
		local gi_alphaHigh = item.alphaScaling.high;
		local gi_alphaCurrentlySelected = item.alphaScaling.currentlySelected;
		local gi_scaleLow = item.sizeScaling.low;
		local gi_scaleHigh = item.sizeScaling.high;
		local gi_scaleCurrentlySelected = item.sizeScaling.currentlySelected;
		local gi_padding = linear.padding // negative number shrink the gamelist, positve expand it
		local gi_h = item.height; // game item height
		local gi_w = item.width;
		local gi_positionpoints = (gl_w / (gl_stopPoints) + (gi_padding * 2)) * 0.8 // determine the position points for the game items		
		local gi_alphaSlice = (gi_alphaHigh - gi_alphaLow) / (gl_stopPoints/2);
		local gi_scaleSlice = (gi_scaleHigh - gi_scaleLow) / (gl_stopPoints.tofloat()/2);
		local gi_p = gi_h * 0.20; // the percent of the height that is be pinched
		local gi_pinch_range = 0.04; // adjust the height pinching amount as it moves aways from the center image
		local gi_py = 0;
		local gi_x_offset = gl_x - (gi_positionpoints * (gl_stopPoints-2))/2 // ensure coverflow is centered in the area given by gl_x
		local gi_x_offset2 = null;
		local gi_x = gi_positionpoints;  // add "* current game item count"
		local gi_y = gl_y; // always the same

		local logicSwitchSelected = null;
		local logicSwitchHigh = false;
		local logicSwitchLow = false;
		local logicSwitchEndNow = false;
		local logicSwitchTextOnly = (item.contentTemplate == ch.Text);
		local gi_alpha = null;
		local gi_h_new = null;
		local gi_w_new = null;
		local gi_type = "normal";
		local gi_rotate = 0;
		local gi_sel_a = 0;
		local temp = null;
		local scaleslice = null;
		
		local results = {				// table containing all of the computed coordinates and gi_angles, color changes
			gl_h=[], gl_w=[],			// gamelist dimensions
			gi_x=[], gi_y=[],			// game item location coordinates
			gi_r=[], gi_a=[],			// game item rotation and alpha settings
			gi_w=[], gi_h=[],			// game item dimensions
			gi_text_size=[],			// game item text size
			gi_text_red = [], gi_text_green =[], gi_text_blue = [], // game item text colors
			gi_red = [], gi_green = [], gi_blue = [], // game item background colors
			gl_stopPoints = null,			// total number of gameitems
			gi_sel_a = [],
			gi_py = []
		};
		
		// set Static variables
		results.gl_stopPoints = gl_stopPoints;
		
		// draw loop 
		for (local i= -1; i< gl_stopPoints; i++)
		{
			if (i < gl_stopPoints /2 -1) { logicSwitchLow = true } else
			if (i > gl_stopPoints /2 -1) { logicSwitchHigh = true } else 
				{logicSwitchSelected = true}
			if (gl_stopPoints == 1) {logicSwitchSelected = true}
			
			
			// do left side
			if (logicSwitchLow)
			{
				scaleslice = ((i * gi_scaleSlice ) + gi_scaleLow );
				
				gi_x = (gi_positionpoints * 0.5 * i) + gi_x_offset;
				gi_y = gi_y;
				gi_w_new =  scaleslice * gi_w;
				gi_h_new = scaleslice * gi_h;
				gi_alpha = ( gl_stopPoints - i ) * gi_alphaSlice + gi_alphaLow;
				temp = (i < gl_stopPoints/2 -2) ? gi_p : gi_p - (gi_h * gi_pinch_range * i) ;
				gi_py = (temp < 0) ? gi_py : temp;
				gi_py = gi_py * scaleslice;
				gi_x_offset2 = (gi_positionpoints * (i+1) + gi_x_offset) - gi_x + (gi_positionpoints * (i+1) + gi_x_offset);
			}
			
			// do selected
			if (logicSwitchSelected)
			{
				gi_x = (gi_positionpoints * i) + gi_x_offset;
				gi_y = gi_y;
				gi_w_new = gi_scaleCurrentlySelected * (gi_w * 1.05);
				gi_h_new = gi_scaleCurrentlySelected * (gi_h * 1.05);
				gi_alpha = gi_alphaCurrentlySelected;
//				gi_py = 0 will be set below - ensures last value of gi_py is keep for the first "right side" game item
				gi_sel_a = 255; 
				gi_type = "currentlySelected";
			}
			
			// do right side
			if (logicSwitchHigh)
			{ 
				scaleslice = ((( gl_stopPoints - i -2) * gi_scaleSlice ) + gi_scaleLow );
				
				gi_x = (gi_positionpoints * 0.5 * (i - gl_stopPoints/2)) + gi_x_offset2;
				gi_y = gi_y;
				gi_w_new = scaleslice * gi_w;
				gi_alpha = ( gl_stopPoints - i ) * gi_alphaSlice + gi_alphaLow;
				temp = (i > gl_stopPoints/2 +0 ) ? 	gi_p  * -1 : (gi_p - (gi_h * gi_pinch_range * (gl_stopPoints - i - 2))) * -1 ;
				gi_py = (temp >= 0) ? abs(gi_py) * -1 : temp;
				gi_py = gi_py * scaleslice;
				gi_h_new = (scaleslice * gi_h)-(gi_py * 2 * -1);
			}
			
			// Push all settings into the array
			results.gi_sel_a.push(gi_sel_a);
			results.gi_x.push(gi_x);
			results.gi_y.push(gi_y);
			results.gi_a.push(gi_alpha);
			results.gi_w.push(gi_w_new);
			results.gi_h.push(gi_h_new);
			results.gi_r.push(0);
			results.gi_py.push((logicSwitchSelected) ? 0 : gi_py);
			results.gi_text_size.push(text[gi_type].size);
			results.gi_text_red.push(text[gi_type].color.red);
			results.gi_text_green.push(text[gi_type].color.green);
			results.gi_text_blue.push(text[gi_type].color.blue);
			results.gi_red.push(item[gi_type].color.red);
			results.gi_green.push(item[gi_type].color.green);
			results.gi_blue.push(item[gi_type].color.blue);
			
			// Reset Logik Switches
			gi_type = "normal";
			gi_sel_a = 0;
			logicSwitchHigh = false;
			logicSwitchLow = false;
			logicSwitchSelected = false;
			
		}
		
		// Ensure the wheel is sorted alphabetically
/*		results.gi_sel_a.reverse();
		results.gi_x.reverse();
		results.gi_y.reverse();
		results.gi_a.reverse();
		results.gi_w.reverse();
		results.gi_h.reverse();
		results.gi_r.reverse();
		results.gi_py.reverse();
		results.gi_text_size.reverse();
		results.gi_text_red.reverse();
		results.gi_text_green.reverse();
		results.gi_text_blue.reverse();
		results.gi_red.reverse();
		results.gi_green.reverse();
		results.gi_blue.reverse();
*/	
	return results;
	};
	
	function setSpinWheelStops()
	{
	/* 
		create spin wheel stops based 
		upon calculation gl_stopPoints on an arc 
		
	*/	
		

		local size = spinwheel.shape;				// the size of the circle in degrees
		local gl_stopPoints = item.count; 									// the amount of stops the spinwheel will have
		local gl_radius = bend.gl_radius;				// gl_radius in pixels the circle should be
		local centerX = x;
		local centerY= y;
		local gi_alphaLow	= item.alphaScaling.low;
		local gi_alphaHigh = item.alphaScaling.high;
		local gi_alphaCurrentlySelected = item.alphaScaling.currentlySelected;
		local gi_sizeHeight = item.height;
		local gi_sizeWidth = item.width;		  
		local gi_scaleLow = item.sizeScaling.low;
		local gi_scaleHigh = item.sizeScaling.high;
		local gi_scaleCurrentlySelected = item.sizeScaling.currentlySelected;
		local gi_angle = 0;									// gi_angle of the current coordinate in radians
		local gi_newX = null;									// X coordinate of the current gameitem
		local gi_newY = null;									// Y coordinate of the current gameitem
		local gi_angle_slice = (size * PI / 180) / gl_stopPoints; 	// create equal stops along the spinwheel as radians (radians = degrees × π / 180°)
		local gi_alphaSlice = null;
		local gi_scaleSlice = null;
		local direction = (bend.direction == ch.Right) // true = right | false = left
		local rotate = spinwheel.rotate_items
		local gi_startPoint = (spinwheel.startDegree) * PI / 180; // The degree on a circle to start drawing the spinwheel. From left to right 0= left, 90 = top, 180 = right, 270= bottom
		local gi_effectsX = spinwheel.effects.x;
		local gi_effectsY = spinwheel.effects.y;
		local logicSwitchSelected = null;
		local logicSwitchHigh = false;
		local logicSwitchLow = false;
		local logicSwitchEndNow = false;
		local logicSwitchTextOnly = (item.contentTemplate == ch.Text);
		local gi_alpha = null;
		local i = 0;
		local gi_widthNew = null;
		local gi_heightNew = null;
		local gi_type = "normal";
		local gi_rotate = 0;
		local gi_sel_a = 0;
		
		local results = {				// table containing all of the computed coordinates and gi_angles, color changes
			gl_h=[], gl_w=[],			// gamelist dimensions
			gi_x=[], gi_y=[],			// game item location coordinates
			gi_r=[], gi_a=[],			// game item rotation and alpha settings
			gi_w=[], gi_h=[],			// game item dimensions
			gi_text_size=[],			// game item text size
			gi_text_red = [], gi_text_green =[], gi_text_blue = [], // game item text colors
			gi_red = [], gi_green = [], gi_blue = [], // game item background colors
			gl_stopPoints = null,			// total number of gameitems
			gi_sel_a = [],
		};
		
		
		// Setup Static values
		results.gl_stopPoints = gl_stopPoints;
		gi_type ="normal";
		
			
		// configure alpha and scale steps when stepping through the loop if num of item > 1
		gi_alphaSlice = (gi_alphaHigh - gi_alphaLow) / (gl_stopPoints/2);
		gi_scaleSlice = (gi_scaleHigh - gi_scaleLow) / (gl_stopPoints/2);
		
		
		for (local i = -1; i <= gl_stopPoints ; i++)
		{		
		/*
			gl_stopPoints is set to +1 so that the last
			spinwheel item animates out instead of staying static
			on the wheel
		
		*/
		// toggle logicSwitches

			if (i < gl_stopPoints /2 || gl_stopPoints == 1) { logicSwitchLow = true } else
			if (i > gl_stopPoints /2) { logicSwitchHigh = true } else
				{ logicSwitchSelected = true } 			
			if (gl_stopPoints == 1) {logicSwitchSelected = true}

			if (direction) 
			{
			/*
				Configure the rotate, angle and positioning infos				
			*/
			
			// Right
				gi_angle = gi_startPoint - (gi_angle_slice * i) 
				gi_newX = centerX + (gl_radius) * cos(gi_angle)* gi_effectsX;
				gi_newY = centerY + (gl_radius) * sin(gi_angle) * gi_effectsY;
				gi_rotate = (rotate) ?  gi_angle * 180 / PI : 0 ;	
			
			} else {
			// Left
				gi_angle = gi_startPoint + ( gi_angle_slice * i );
				gi_newX = centerX + gl_radius * cos(gi_angle)* gi_effectsX;
				gi_newY = centerY + gl_radius * sin(gi_angle)* gi_effectsY;
				gi_rotate = (rotate) ?  (gi_angle * 180 / PI) + 180 : 0
			}

			// write the x,y, and rotation
			
			if (logicSwitchHigh)
			{
			/* 
				load the alpha channel, width, and height
				of the wheel image from lowest configured value 
				to heighest 
			*/	
				gi_alpha = ( gl_stopPoints - i + 1 ) * gi_alphaSlice + gi_alphaLow ;
				gi_widthNew =  ((( gl_stopPoints - i  ) * gi_scaleSlice ) + gi_scaleLow )* gi_sizeWidth ;
				gi_heightNew = ((( gl_stopPoints - i  ) * gi_scaleSlice ) + gi_scaleLow )* gi_sizeHeight;		
			}
						
			if (logicSwitchLow)
			{
			/*
				configure the selected item width, height scaling and alpha settings
				for the game items below or to the right of the selected game item
			*/	
				gi_alpha = i * gi_alphaSlice + gi_alphaLow ;
 				gi_widthNew =  ((i * gi_scaleSlice ) + gi_scaleLow ) * gi_sizeWidth ;
				gi_heightNew = ((i * gi_scaleSlice ) + gi_scaleLow ) * gi_sizeHeight ;
			}
			
			if (logicSwitchSelected) 
			{
			/*
				configure the selected item width, height scaling and alpha settings
				for the selected game item
			*/
				gi_type = "currentlySelected";
				gi_sel_a = 255;
				gi_alpha = gi_alphaCurrentlySelected ;
				gi_widthNew =  gi_scaleCurrentlySelected * gi_sizeWidth  ;
				gi_heightNew = gi_scaleCurrentlySelected * gi_sizeHeight ;								

			}			
			
			// Add the information to the results array
			results.gi_sel_a.push(gi_sel_a);
			results.gi_r.push(gi_rotate);
			results.gi_x.push(gi_newX);
			results.gi_y.push(gi_newY);
			results.gi_a.push(gi_alpha);
			results.gi_w.push(gi_widthNew);
			results.gi_h.push(gi_heightNew);
			results.gi_text_size.push(text[gi_type].size);
			results.gi_text_red.push(text[gi_type].color.red);
			results.gi_text_green.push(text[gi_type].color.green);
			results.gi_text_blue.push(text[gi_type].color.blue);
			results.gi_red.push(item[gi_type].color.red);
			results.gi_green.push(item[gi_type].color.green);
			results.gi_blue.push(item[gi_type].color.blue);
	
			// Reset Logik Switches	
			gi_type="normal";
			gi_sel_a = 0;
			logicSwitchHigh = false;
			logicSwitchLow = false;
			logicSwitchSelected = false;
			
		};
		
		// Ensure the wheel is sorted alphabetically
		results.gi_sel_a.reverse();
		results.gi_r.reverse();
		results.gi_x.reverse();
		results.gi_y.reverse();
		results.gi_a.reverse();
		results.gi_w.reverse();
		results.gi_h.reverse();
		results.gi_text_size.reverse();
		results.gi_text_red.reverse();
		results.gi_text_green.reverse();
		results.gi_text_blue.reverse();
		results.gi_red.reverse();
		results.gi_green.reverse();
		results.gi_blue.reverse();
		return results;
	};
	
	function setOriginSettings()
	{
		if (bend.direction == ch.Right)
		{
		// bend facing Right 
			if (type == ch.Spinwheel) {origin_multiplier.x = 0.5; origin_multiplier.y = 0.5;}
			
		} else {
		// bend facing Left
			if (type == ch.Linear_Vertical) {origin_multiplier.x = 1; origin_multiplier.y = 0;}
			if (type == ch.Linear_Horizontal) {origin_multiplier.x = 0; origin_multiplier.y = 1;}
			if (type == ch.Spinwheel) {origin_multiplier.x = 0.5; origin_multiplier.y = 0.5;}
			}

			if (type == ch.Coverflow) {origin_multiplier.x = 0.5; origin_multiplier.y = 0.5;}
		return;
	}
	
	function add_gameItemsContent(type = "", name = "snap",x = 0,y = 0,w = 0 , h = 0 )
	{
	/*
		add Content to GameItem surface

	*/
		local temp = null;
		local obType = null;
		local tmp = -1;
		switch (type)
		{
			case "artwork":
				temp = runtime.surface.container.add_artwork(name,x,y,w,h)
				obType = "fe.Artwork|" + name;
				break;
				
			case "text":
				temp = runtime.surface.container.add_text(name,x,y,w,h)
				obType = "fe.Text";
				gi_text_avaialble = true;
				break;
				
			case "image":
				temp = runtime.surface.container.add_image(name,x,y,w,h)
				obType = "fe.Image";
				break;
				
			case "background":
				temp = runtime.surface.container.add_image(name,x,y,w,h)
				obType = "fe.Image";
				runtime.surface.objects[0] = temp;
				runtime.surface.objectTypes[0] = obType
				return temp;
				break;
				
			case "selected":
				temp = runtime.surface.container.add_image(name,x,y,w,h)
				obType = "fe.Image";
				runtime.surface.objects[1] = temp;
				runtime.surface.objectTypes[1] = obType
				return temp;
				break;
		}
		
		runtime.surface.objects.push(temp);
		runtime.surface.objectTypes.push(obType);

	/*
		Add a value to fe.Text to let the SlotItem Class know about the fallback text object
	*/
		
		foreach (key,value in runtime.surface.objectTypes)
		{
			if (value == "fe.Text") tmp++
		}
		
 		if ( (text_fallback_index > -1 ) && (tmp == text_fallback_index) && (runtime.surface.objectTypes.top() == "fe.Text") ) 
		{
			runtime.surface.objectTypes[runtime.surface.objectTypes.len() -1] = "fe.Text|fallbackFlag"
		} 
		
		return temp;
	}	// End: add_gameItemsContent()
	
	function add_favoriteImage(tmp_file,x,y,width,height) 
	{ 
		local test = null;
		try {
			test = file(tmp_file, "r" );	
			artwork.favActive=true;
			artwork.favFile = tmp_file;
			artwork.favX = x;
			artwork.favY = y;
			artwork.favWidth = width;
			artwork.favHeight = height;
			test.close(); 
		} catch (e) {
			print(e);
		
		}
		
		return;
	};

	function add_customGameItemContent(type = "", name = "snap",x = 0,y = 0,w = 0 , h = 0)
	{
		local temp = null;
		local obType = null;
		local tmp = -1;
		setSurfaceContainer();
		if (item.contentTemplate == ch.Custom)
		{
			switch (type)
			{
				case "artwork":
					customContent.images++
					temp = runtime.surface.container.add_artwork(name,x,y,w,h);
					obType = "fe.Artwork|" + name;
					artwork_test_index = customContent.images;
					break;
					
				case "text":
					customContent.text++
					temp = runtime.surface.container.add_text(name,x,y,w,h);
					obType = "fe.Text";
					gi_text_avaialble = true;
					if ((name.find("[Title]") != null) || (name.find("[Name]") != null)){
						text_fallback_index = customContent.text;
					}
					break;
					
				case "image":
					customContent.images++
					temp = runtime.surface.container.add_image(name,x,y,w,h);
					obType = "fe.Image";
					if (name.find("[Title]") != null){
						artwork_test_index = customContent.images;
						obType = "fe.Image|Info.Title"
					}
					if (name.find("[Name]") != null){
						artwork_test_index = customContent.images;
						obType = "fe.Image|Info.Name"
					}
					break;
			}
			
			runtime.surface.objects.push(temp);
			runtime.surface.objectTypes.push(obType);
			
	
		/*
			Add a value to fe.Text to let the SlotItem Class know about the fallback text object
		*/
			foreach (key,value in runtime.surface.objectTypes)
			{
				if (value == "fe.Text") tmp++
			}
				
			if ((text_fallback_index > -1 ) && (tmp == text_fallback_index) && (runtime.surface.objectTypes.top() == "fe.Text")) 
			{
				runtime.surface.objectTypes[runtime.surface.objectTypes.len() -1] = "fe.Text|fallbackFlag"
			} 
		
		} else {
		
			error("ERROR: item.contentTemplate is not set to 'ch.Custom'. Do not use add_customGameItemContent() in your layout.nut\n");
		
		}
		
		
		return temp;
	}
function fade_gamelist(_ticktime)
{
	if (fade_active == false)
	{	
//	print("tick fade is active\n");
	// set the last tick time so the the fade_delay function works	
		fade_lastticktime = _ticktime + fade_delay;
	
	} else {	
	
		if (_ticktime > fade_lastticktime) {
		// fade the game items
			foreach(key, gi in conveyor_entries)
			{
				if (gi.m_obj.alpha > fade_after_nav) 
				{
					if (sel_game_offset == key && !fade_selected)
					{
						fade_counter += 1;
					
					} else {
					
						gi.m_obj.alpha = (gi.m_obj.alpha - fade_speed <= 0) ? 0 : gi.m_obj.alpha - fade_speed;
						(gi_textFallback || item.contentTemplate == ch.Text) ? gi.slot_text[text_fallback_index].alpha = gi.m_obj.alpha : null;
					
					}

				} else {
				// if the game item has already reached the target fade value
				// up the fade counter
					gi.m_obj.alpha = fade_after_nav;
					(gi_textFallback || item.contentTemplate == ch.Text) ? gi.slot_text[text_fallback_index].alpha = gi.m_obj.alpha : null;

					fade_counter += 1;
				}
			}
			if (fade_counter == conveyor_entries.len())
			{
			// if all game items have reached the fade value, stop fading reset values
				fade_active = false;
			}
			// reset fade_counter for next tick run
			fade_counter = 0;
		}
	}
}
	
//	Fade the gamelist after navigation if configured
	function on_transiton(ttype, var, ttime){
/*		

*/				
		if (( ttype != Transition.EndNavigation ))
			return false;
		
		if (fade_active) {
			fade_active = false;
			return true;
		}	

		fade_active = true;
	}
	
	
	function show()
	{
	/* 
		Configure the game list item according to the configured type.
		The settings will be saved in the vaiables runtime.surface.container,
		runtime.surface.objects, and runtime.surface.objectTypes. These will be
		passed to the conveyor and used in the on_progress function.
		
		ToDo:
		- turn this off when done: runtime.surface.container.visible = true;
		
	*/
		
	
		local results = null; 
		local remaining = null;
		local conveyor = null;

		
		// load the contents of the game item surface.
		setGameItemContent();			
		setOriginSettings();
		item.count++ // needed so you see the amount onscreen you configured
		
		// create the gamelist using the conveyor
		switch (type)
		{
			case ch.Spinwheel:
				setSlotItemClass("spinwheel");	// dynamically reconfigure SpinwheelSlotItem()		
				results = setSpinWheelStops(); // precalculate the stops along the conveyour		
				break;

			case ch.Coverflow:
				item.count = (item.count % 2 == 0 ) ? item.count : item.count +1
				setSlotItemClass("coverflow");	// dynamically reconfigure SpinwheelSlotItem()		
				results = setCoverFlowStops(); // precalculate the stops along the conveyour
				break;
				
			case ch.Linear_Horizontal:
			case ch.Linear_Vertical:
				setSlotItemClass("linear"); // dynamically reconfigure LinearSlotItem()
				results = setLinearStops(); // precalculate the stops along the conveyour
				break;
		}
		
		// ensure the correct game is selected when the item.count is a even number
		sel_game_offset = (item.count % 2 == 0) ? item.count/2 : item.count/2 +1;
		
		
	//
	//	Load the Gamelist
	//
		conveyor_entries = [];
		for ( local i=0; i<item.count/2; i++ )
		{
			switch (type)
			{
				case ch.Spinwheel:
					conveyor_entries.push( SpinwheelSlotItem(runtime, artwork.favActive));
					break;
				
				case ch.Coverflow:
					conveyor_entries.push( CoverflowSlotItem(runtime, artwork.favActive));
					conveyor_entries[i].gi_py = results.gi_py;
					break;
					
				default:
					conveyor_entries.push( LinearSlotItem(runtime, artwork.favActive, item.contentTemplate));
					conveyor_entries[i].gl_type = "linear";
					conveyor_entries[i].gi_txt_x = results.gi_txt_x
					conveyor_entries[i].gi_txt_y = results.gi_txt_y
					conveyor_entries[i].gi_txt_width = results.gi_txt_width;
					conveyor_entries[i].gi_txt_height = results.gi_txt_height;			
			}
						
			conveyor_entries[i].gl_stopPoints = results.gl_stopPoints;			
			conveyor_entries[i].gi_sel_a = results.gi_sel_a;
			conveyor_entries[i].gi_a = results.gi_a;
			conveyor_entries[i].gi_x = results.gi_x;
			conveyor_entries[i].gi_y = results.gi_y;			
			conveyor_entries[i].gi_w = results.gi_w;
			conveyor_entries[i].gi_h = results.gi_h;
			conveyor_entries[i].gi_r = results.gi_r;
			conveyor_entries[i].gi_oxmultiplier = origin_multiplier.x;
			conveyor_entries[i].gi_oymultiplier = origin_multiplier.y;
			conveyor_entries[i].gi_text_size = results.gi_text_size;
			conveyor_entries[i].gi_text_red = results.gi_text_red;
			conveyor_entries[i].gi_text_green = results.gi_text_green;
			conveyor_entries[i].gi_text_blue = results.gi_text_blue;
			conveyor_entries[i].gi_red = results.gi_red;
			conveyor_entries[i].gi_green = results.gi_green;
			conveyor_entries[i].gi_blue = results.gi_blue;
			conveyor_entries[i].gi_textFallback = gi_textFallback;
			conveyor_entries[i].text_fallback_index = text_fallback_index;
			conveyor_entries[i].artwork_test_name = get_artworkTestName(); 
			conveyor_entries[i].artwork_test_index = artwork_test_index
		}

		remaining = item.count - conveyor_entries.len();

		// we do it this way so that the last wheelentry created is the middle one showing the current
		// selection (putting it at the top of the draw order)
		
//		local backcount = item.count;
		
		for ( local i=0; i<remaining ; i++ )
		{

			switch (type)
			{
				case ch.Spinwheel:
					if (i == remaining -1)
					{ 
						conveyor_entries.insert( item.count/2, SpinwheelSlotItem(runtime, artwork.favActive, "useRuntimeContainer"))
					} else {
						conveyor_entries.insert( item.count/2, SpinwheelSlotItem(runtime, artwork.favActive));
					}
					break;
				
				case ch.Coverflow:
					if (i == remaining -1)
					{ 
						conveyor_entries.insert( item.count/2, CoverflowSlotItem(runtime, artwork.favActive, "useRuntimeContainer"))
					} else {
						conveyor_entries.insert( item.count/2, CoverflowSlotItem(runtime, artwork.favActive));
					}
					conveyor_entries[item.count/2].gi_py = results.gi_py;
					break;
					
				default:
					if (i == remaining -1)
					{ 
						conveyor_entries.insert( item.count/2, LinearSlotItem(runtime, artwork.favActive, item.contentTemplate, "useRuntimeContainer"))
					} else {
						conveyor_entries.insert( item.count/2, LinearSlotItem(runtime, artwork.favActive, item.contentTemplate));
					}
					conveyor_entries[item.count/2].gl_type = "linear";
					conveyor_entries[item.count/2].gi_txt_x = results.gi_txt_x
					conveyor_entries[item.count/2].gi_txt_y = results.gi_txt_y
					conveyor_entries[item.count/2].gi_txt_width = results.gi_txt_width;
					conveyor_entries[item.count/2].gi_txt_height = results.gi_txt_height;
			}
						
			conveyor_entries[item.count/2].gl_stopPoints = results.gl_stopPoints;			
			conveyor_entries[item.count/2].gi_sel_a = results.gi_sel_a;
			conveyor_entries[item.count/2].gi_a = results.gi_a;
			conveyor_entries[item.count/2].gi_x = results.gi_x;
			conveyor_entries[item.count/2].gi_y = results.gi_y;
			conveyor_entries[item.count/2].gi_w = results.gi_w;
			conveyor_entries[item.count/2].gi_h = results.gi_h;
			conveyor_entries[item.count/2].gi_r = results.gi_r;
			conveyor_entries[item.count/2].gi_oxmultiplier = origin_multiplier.x;
			conveyor_entries[item.count/2].gi_oymultiplier = origin_multiplier.y;
			conveyor_entries[item.count/2].gi_text_size = results.gi_text_size;
			conveyor_entries[item.count/2].gi_text_red = results.gi_text_red;
			conveyor_entries[item.count/2].gi_text_green = results.gi_text_green;
			conveyor_entries[item.count/2].gi_text_blue = results.gi_text_blue;
			conveyor_entries[item.count/2].gi_red = results.gi_red;
			conveyor_entries[item.count/2].gi_green = results.gi_green;
			conveyor_entries[item.count/2].gi_blue = results.gi_blue;
			conveyor_entries[item.count/2].gi_textFallback = gi_textFallback;
			conveyor_entries[item.count/2].text_fallback_index = text_fallback_index;
			conveyor_entries[item.count/2].artwork_test_name = get_artworkTestName(); 
			conveyor_entries[item.count/2].artwork_test_index = artwork_test_index; 
		}

		
		// Turn on video playing for the selected item
		conveyor_entries[sel_game_offset].video_status = 0;
			
	// set the selected item to be above all other conveyour items
		local highest = 0;
		foreach (key,value in fe.obj)
		{
			if (fe.obj[key].zorder > highest) highest = fe.obj[key].zorder;
		}
		conveyor_entries[sel_game_offset].zorder = highest + 1;
			
	//	Hide slot #0 to ensure it is only the configured # of slots are shown
		conveyor_entries[0].m_obj.visible = false
		
		// set the font for the selected item in the conveyour
		if ((text_fallback_index != -1 && gi_text_avaialble) || item.contentTemplate == ch.Text)
		{
			conveyor_entries[sel_game_offset].slot_text[text_fallback_index].font = text.currentlySelected.font;
		};
		
		// show the conveyour and set some operating options
		conveyor = Conveyor();
		conveyor.set_slots( conveyor_entries, sel_game_offset);
		conveyor.reset_progress;
		conveyor.transition_ms = ms_speed;
		conveyor.transition_swap_point = 1.0;

		
		// set each conveyour slots text object to be above the image objects in the fe.obj display list order
		if (type != ch.Spinwheel && type != ch.Coverflow)
		{	
			foreach (key,value in conveyor_entries)
			{
				conveyor_entries[key].newTextzorder();
			}
		}
		
	// after initializing the conveyor, hide fallback text 
		if (gi_textFallback)
		{
			foreach (key,value in conveyor_entries)
			{
				// handle fallback text
				if (fe.get_art( get_artworkTestName(), conveyor_entries[key].get_base_index_offset() ) == "")
				{
					conveyor_entries[key].slot_text[text_fallback_index].visible = true;
				} else {
					conveyor_entries[key].slot_text[text_fallback_index].visible = false;
				}		
			}
		}
		
	// activate game list fading after navigating
		if (fade_after_nav != 255) {
			fe.add_transition_callback(this,"on_transiton")
			fe.add_ticks_callback(this, "fade_gamelist")
			
		}
		
	} // -- End of show()
	

}; // -- End of MyGameList
	


	

	
	
	
	
	
	
