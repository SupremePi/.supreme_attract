/////////////////////////////////////////////////////////
//
// Attract-Mode Frontend - "Fade_in" Module
//
// By Machiminax
/////////////////////////////////////////////////////////

local my_config = fe.get_config();
fe.layout.font="BebasNeueRegular.otf";

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

local layout_width = fe.layout.width
local layout_height = fe.layout.height


local bth = floor( flh * 160.0 / 1080.0 )
local bbh = floor( flh * 160.0 / 1080.0 )
local bbm = ceil( bbh * 0.2 )
local lbw = floor( flh * 540.0 / 1080.0 )
local flyerH = flh - bth - bbh
local flyerW = lbw
local update_artwork = false
local update_counter = 0

local cr_en = false
local crw = 0

/////////////////////
//Background
/////////////////////
local layer1_default_fadein = fe.add_image("../../menu-art/fade-in/[DisplayName]", flx*0, fly*0, flw, flh );
layer1_default_fadein.alpha=0;
layer1_default_fadein.preserve_aspect_ratio = false;

local layer1_default_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 0,
    end = 255,
    time = 500
 }

local layer1_default_fadein_fade_out = {
    when = Transition.FromGame,
    property = "alpha",
    start = 255,
    end = 0,
    time = 500
	delay= 750
	wait = true
}

animation.add( PropertyAnimation ( layer1_default_fadein, layer1_default_fadein_fade_in ) );
animation.add( PropertyAnimation ( layer1_default_fadein, layer1_default_fadein_fade_out ) );


/////////////////////
//System Flyer
/////////////////////
local flx = ( fe.layout.width - layout_width ) / 2
local fly = ( fe.layout.height - layout_height ) / 2
local layer2_fadein = fe.add_image("../../menu-art/flyer/[DisplayName]",  (flw + flx - crw - flyerW)*0.85, flh*0.075, flyerW*1.6, flyerH*1.2 );
local flx = fe.layout.width;
local fly = fe.layout.height;
layer2_fadein.alpha=0;
layer2_fadein.preserve_aspect_ratio = true;

local layer2_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 0,
    end = 255,
    time = 500
    delay = 0
 }
 
local layer2_fadein_scale = {
	when = Transition.ToGame,
    property = "scale",
    start = 1,
    end = 0.8,
    time = 500	
    tween = Tween.Quad,
	pulse = false
}
	
local layer2_fadein_fade_out = {
    when = Transition.ToGame,
    property = "alpha",
    start = 155,
    end = 0,
    time = 500
    delay = 750
    wait = true
}

animation.add( PropertyAnimation ( layer2_fadein, layer2_fadein_fade_in ) );
animation.add( PropertyAnimation ( layer2_fadein, layer2_fadein_scale) );
animation.add( PropertyAnimation ( layer2_fadein, layer2_fadein_fade_out ) );

/////////////////////
//Artwork
/////////////////////
/*
local boxart_fadein = fe.add_artwork("boxart", flx*0.2, fly*0.3, flw*0.3, flh*0.5 );
boxart_fadein.alpha=0;
boxart_fadein.preserve_aspect_ratio = true;
boxart_fadein.trigger = Transition.EndNavigation;
local cartart_fadein = fe.add_artwork("cartart", flx*0.02, fly*0.4, flw*0.3, flh*0.3 );
cartart_fadein.alpha=0;
cartart_fadein.preserve_aspect_ratio = true;
cartart_fadein.trigger = Transition.EndNavigation;
local cdart_fadein = fe.add_artwork("cdart", flx*0.02, fly*0.4, flw*0.3, flh*0.3 );
cdart_fadein.alpha=0;
cdart_fadein.trigger = Transition.EndNavigation;
*/

local fanart_fadein = fe.add_image("systemimages/[DisplayName]", flx*0.25, fly*0.35, flw*0.3, flh*0.4 );
fanart_fadein.alpha=0;
fanart_fadein.preserve_aspect_ratio = true;

local layer3_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 0,
    end = 255,
    time = 500
    delay = 0
 }
 
local layer3_fadein_shrink = {
    when = Transition.ToGame,
    property = "scale",
    start = 0,
    end = 1.0,
    time = 750	
    tween = Tween.Bounce,
    wait = true
    delay = 500
}

local layer3_fadein_fade_out = {
    when = Transition.ToGame,
    property = "alpha",
    start = 155,
    end = 0,
    time = 500
    delay = 750
    wait = true
}

animation.add( PropertyAnimation ( fanart_fadein, layer3_fadein_fade_in ) );
//animation.add( PropertyAnimation ( boxart_fadein, layer3_fadein_fade_in ) );
//animation.add( PropertyAnimation ( cartart_fadein, layer3_fadein_fade_in ) );
//animation.add( PropertyAnimation ( cdart_fadein, layer3_fadein_fade_in ) );
//animation.add( PropertyAnimation ( layer3_fadein, layer3_fadein_shrink ) );
animation.add( PropertyAnimation ( fanart_fadein, layer3_fadein_fade_out ) );
//animation.add( PropertyAnimation ( boxart_fadein, layer3_fadein_fade_out ) );
//animation.add( PropertyAnimation ( cartart_fadein, layer3_fadein_fade_out ) );
//animation.add( PropertyAnimation ( cdart_fadein, layer3_fadein_fade_out ) );

/////////////////////
//Loading Text
/////////////////////
local layer4_fadein = fe.add_image("../../menu-art/fade-in/Loading.png", flx*0.27, fly*0.2, flw*0.3, flh*0.1 );
layer4_fadein.alpha=0;
layer4_fadein.preserve_aspect_ratio = true;

local layer4_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 0,
    end = 255,
    time = 500
    delay = 0
 }
 
local layer4_fadein_skew_x = {
    when = Transition.ToGame,
	property = "skew_x",
	start = (-500),
	end = (0),
	time = 750,
    tween = Tween.Expo
	loop=false
	wait = true
    delay = 0
}

local layer4_fadein_fade_out = {
    when = Transition.ToGame,
    property = "alpha",
    start = 155,
    end = 0,
    time = 500
    delay = 750
    wait = true
}

animation.add( PropertyAnimation ( layer4_fadein, layer4_fadein_fade_in ) );
animation.add( PropertyAnimation ( layer4_fadein, layer4_fadein_skew_x ) );
animation.add( PropertyAnimation ( layer4_fadein, layer4_fadein_fade_out ) );

//////////////////////
//Border
/////////////////////
local flx = ( fe.layout.width - layout_width ) / 2
local fly = ( fe.layout.height - layout_height ) / 2
 // Top Background
local bannerTop = fe.add_image( "../../menu-art/fade-in/white.png", flx, 0, flw, bth)
bannerTop.set_rgb( 0,0,0 )
bannerTop.alpha=0;

// Bottom Background
local bannerBottom = fe.add_image( "../../menu-art/fade-in/white.png", flx, flh - bbh, flw, bbh)
bannerBottom.set_rgb( 0,0,0 )
bannerBottom.alpha=0;
local flx = fe.layout.width;
local fly = fe.layout.height;

local layer5_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 150,
    end = 150,
    time = 500
    delay = 0
 }

 local layer5_fadein_fade_out = {
    when = Transition.ToGame,
    property = "alpha",
    start = 150,
    end = 0,
    time = 500
    delay = 750
    wait = true
}
 
 animation.add( PropertyAnimation ( bannerTop, layer5_fadein_fade_in ) );
 animation.add( PropertyAnimation ( bannerBottom, layer5_fadein_fade_in ) );
 animation.add( PropertyAnimation ( bannerTop, layer5_fadein_fade_out ) );
 animation.add( PropertyAnimation ( bannerBottom, layer5_fadein_fade_out ) );
/////////////////////
//HyperPie Logo
/////////////////////
local layer5_fadein = fe.add_image("../../menu-art/fade-in/HP2 Logo.png", flx*0.69, fly*0.85, flw*0.3, flh*0.1 );
layer5_fadein.alpha=0;
layer5_fadein.preserve_aspect_ratio = true;

local layer5_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 0,
    end = 255,
    time = 500
    delay = 0
 }
 
local layer5_fadein_skew_x = {
    when = Transition.ToGame,
	property = "skew_x",
	start = (-500),
	end = (0),
	time = 750,
    tween = Tween.Expo
	loop=false
	wait = true
    delay = 0
}

local layer5_fadein_fade_out = {
    when = Transition.ToGame,
    property = "alpha",
    start = 155,
    end = 0,
    time = 500
    delay = 750
    wait = true
}

animation.add( PropertyAnimation ( layer5_fadein, layer5_fadein_fade_in ) );
animation.add( PropertyAnimation ( layer5_fadein, layer5_fadein_skew_x ) );
animation.add( PropertyAnimation ( layer5_fadein, layer5_fadein_fade_out ) );


/////////////////////
//Layer Game Information Text
/////////////////////
local layout_width = fe.layout.width
local layout_height = fe.layout.height
local flx = ( fe.layout.width - layout_width ) / 2
local fly = ( fe.layout.height - layout_height ) / 2
local flw = layout_width
local flh = layout_height
local gameTitleW = flw - crw - bbm - bbm
local gameTitleH = floor( bbh * 0.35 ) 
local gameTitleFade = fe.add_text( "[Title]", flx + bbm, flh - bbh + bbm, gameTitleW, gameTitleH )
gameTitleFade.align = Align.Left
gameTitleFade.style = Style.Regular
gameTitleFade.nomargin = true
gameTitleFade.set_rgb(255,255,0)
gameTitleFade.charsize = floor(gameTitleFade.height * 1000/700)
gameTitleFade.font = "BebasNeueBold.otf"
gameTitleFade.alpha=0;

// Game Year And Manufacturer
function year_formatted()
{
	local m = fe.game_info( Info.Manufacturer )
	local y = fe.game_info( Info.Year )

	if (( m.len() > 0 ) && ( y.len() > 0 ))
		return "© " + y + "  " + m

	return m
}

local gameYearW = flw - crw - bbm - floor( bbh * 2.875 )
local gameYearH = floor( bbh * 0.15 )
local gameYearFade = fe.add_text( "[Emulator]  [!year_formatted]", flx + bbm, flh - bbm - gameYearH, gameYearW, gameYearH )
gameYearFade.align = Align.Left
gameYearFade.style = Style.Regular
gameYearFade.nomargin = true
gameYearFade.charsize = floor(gameYearFade.height * 1000/700)
gameYearFade.font = flh <= 600 ? "BebasNeueRegular.otf": "BebasNeueBook.otf"
gameYearFade.alpha=0;


local layer6_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 0,
    end = 255,
    time = 750
    delay = 0
 }
 

local layer6_fadein_fade_out = {
    when = Transition.ToGame,
    property = "alpha",
    start = 255,
    end = 0,
    time = 500
    delay = 750
    wait = true
}

animation.add( PropertyAnimation ( gameTitleFade, layer6_fadein_fade_in ) );
animation.add( PropertyAnimation ( gameTitleFade, layer6_fadein_fade_out ) );

animation.add( PropertyAnimation ( gameYearFade, layer6_fadein_fade_in ) );
animation.add( PropertyAnimation ( gameYearFade, layer6_fadein_fade_out ) );

/////////////////////
//Layer Wheel
/////////////////////
// Wheel Image
local wheelScale = ( flw - crw * 2 ) < flh ? flw - crw * 2 : flh
local wheelImageW = floor( wheelScale * 0.3 )*0.9
local wheelImageH = floor( wheelScale * 0.3 )*0.9
local wheelImage = fe.add_artwork( "wheel" ,flx + bbm, bth - floor( wheelImageH / 2 ), wheelImageW, wheelImageH )
wheelImage.preserve_aspect_ratio = true
wheelImage.alpha=0;

local layer5_fadein_fade_in = {
    when = Transition.ToGame,
    property = "alpha",
    start = 255,
    end = 255,
    time = 500
    delay = 0
 }

 local layer5_fadein_fade_out = {
    when = Transition.ToGame,
    property = "alpha",
    start = 255,
    end = 0,
    time = 500
    delay = 750
    wait = true
}
 
animation.add( PropertyAnimation ( wheelImage, layer5_fadein_fade_in ) );
animation.add( PropertyAnimation ( wheelImage, layer5_fadein_fade_out ) );

