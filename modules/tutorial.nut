/////////////////
//Tutorial
////////////////

local my_config = fe.get_config();
fe.layout.font="BebasNeueRegular.otf";

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

local layout_width = fe.layout.width
local layout_height = fe.layout.height

local image_bg = fe.add_image( "white.png", flx*0.719, bth, lbw, (flh - bth - bbh) ); 

image_bg.set_rgb(0,0,0)
image_bg.alpha = 200;
image_bg.visible=true;

local text = fe.add_text("Welcome to HyperPie2", flx*0.72, fly*0.13, flw*0.26, flh*0.7);
text.font = "AEH.ttf"
text.charsize = flx*0.01;
text.align = Align.Left;
text.word_wrap = true;
text.alpha = 255;
text.visible=true;


fe.add_signal_handler(this, "on_signalinfo");
function on_signalinfo(signal) {
	if ( signal == "right" ){
		if ( image_bg.visible==true ) {
			image_bg.visible=false;
			text.visible=false;

		} else {
			image_bg.visible=true;
			text.visible=true;
		}
		return true;
	}
	return false;
}
}