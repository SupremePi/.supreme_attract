class CoverFlow {
    slots = null;
    width = 0;
    selected = 0;
	opts = {
        COUNT = 5,
        SELECTED_PAD = 20,
        SELECTED_PRESERVE = true,
        SELECTED_WIDTH = 0.25,
        SELECTED_HEIGHT = 1.25,
        SELECTED_YOFFSET = 0,
        SELECTED_PINCH_Y = 0,
        UNSELECTED_PAD = 10,
        UNSELECTED_PRESERVE = false,
        UNSELECTED_YOFFSET = 0.4,
        UNSELECTED_PINCH_Y = 20,
        UNSELECTED_HEIGHT = 0.6
    }

    constructor(art, x, y, w, h) {
        slots = [];
        create(art, x, y, w, h);

        //fe.add_transition_callback(this, "on_transition" );
        fe.add_signal_handler(this, "on_signal");
    }
	
    function create(art, x, y, w, h) {
        width = ( w / opts.COUNT ) - (opts.UNSELECTED_PAD * opts.COUNT);
        selected = floor(opts.COUNT / 2) + 1;	

        local totalW = w - ( opts.UNSELECTED_PAD * 2 );
        local totalH = h - ( opts.UNSELECTED_PAD * 2 );
        local selectedY = y + ( opts.UNSELECTED_PAD + totalH * -opts.SELECTED_YOFFSET ) * 1;
        local selectedW = totalW * opts.SELECTED_WIDTH + (opts.UNSELECTED_PAD / 2);
        local selectedH = totalH * opts.SELECTED_HEIGHT - opts.UNSELECTED_PAD;
        local unselectedY = y + ( opts.UNSELECTED_PAD + totalH * opts.UNSELECTED_YOFFSET ) * 1;
        local unselectedW = totalW / opts.COUNT * ( 1 - opts.SELECTED_WIDTH ) + opts.UNSELECTED_PAD;
        local unselectedH = totalH * opts.UNSELECTED_HEIGHT - opts.UNSELECTED_PAD;
        local cfX = x - unselectedW - opts.UNSELECTED_PAD;

        //create art slots, animations and set props for each slot
        for( local i = 0; i < opts.COUNT + 2; i++) {
            local itemX = ( i == selected || i == selected + 1 ) ? cfX + opts.SELECTED_PAD : cfX + opts.UNSELECTED_PAD;
            local itemY = ( i == selected ) ? selectedY : unselectedY;
            local itemW = ( i == selected ) ? selectedW : unselectedW;
            local itemH = ( i == selected ) ? selectedH : unselectedH;
            slots.push( CoverFlowArt(art) );
            slots[i].props({
                x = itemX,
                y = itemY,
                width = itemW,
                height = itemH,
                pinch_y = ( i < selected ) ? opts.UNSELECTED_PINCH_Y : ( i == selected ) ? opts.SELECTED_PINCH_Y : -opts.UNSELECTED_PINCH_Y,
                alpha = ( i == 0 || i == opts.COUNT + 1 ) ? 0 : 255,
            });
            slots[i].ref.preserve_aspect_ratio = slots[i].mirror.preserve_aspect_ratio = ( i == selected ) ? opts.SELECTED_PRESERVE : opts.UNSELECTED_PRESERVE;
            slots[i].ref.index_offset = slots[i].mirror.index_offset = -selected + i;
			slots[i].index_offset = -selected + i;
            cfX = itemX + itemW;
        }

    }

    function on_signal(str) {
        if ( str == "prev_game" ) {
            forwards();
			fe.list.index--
            return true;
        } else if ( str == "next_game" ) {
            backwards();
			fe.list.index++
			return true;
        }
        return false;
    }

    function on_transition( ttype, var, ttime ) {
        if ( ttype == Transition.StartLayout ) {

        } else if ( ttype == Transition.FromOldSelection ) {
            if ( var > 0 ) forwards(); else backwards();
        }
        for( local i = 0; i < slots.len(); i++)
            slots[i].artwork_transition(ttype, var, ttime);
        return false;
    }

    function backwards() {
        for ( local i = 0; i < slots.len(); i++ ) {
            local toIndex = ( i > 0 ) ? i - 1 : slots.len() - 1;
			slots[i].animate( slots[toIndex]._props, - 1 );
        }
		
		
    }

    function forwards() {
        for ( local i = 0; i < slots.len(); i++ ) {
            local toIndex = ( i < slots.len() - 1 ) ? i + 1 : 0;
            slots[i].animate( slots[toIndex]._props, 1 );
        }
    }
}

class CoverFlowArt {
    ref = null;
    anim = null;
    _props = null;
    mirror = null;
    mirror_anim = null;
    mirror_props = null;
    index_offset = null;
	offset = null;	
	
    constructor(art) {
        ref = fe.add_artwork(art, -1, -1, 1, 1);
        anim = PropertyAnimation(ref);
        mirror = fe.add_clone(ref);
        mirror_anim = PropertyAnimation(mirror);
    }

    function artwork_transition(ttype, var, ttime) {
        //mirror.subimg_y = -1 * ref.texture_height;
        //mirror.subimg_height = -ref.texture_height;
    }

    function props(props) {
        this._props = props;
        set_props(ref, props);
        //update_mirror();
    }
	
	function reset_index(blah)
	{
		ref.rawset_index_offset(index_offset);			
		return;
	}

	function adjust_images(blah)
	{
		ref.index_offset = index_offset + offset;
		return;
	}	
	
    function animate(to, offset) {
		this.offset = offset;
		anim.from(_props).to(to).on("start", this "adjust_images").on("stop", this, "reset_index" ).play();
		//mirror_anim.from(mirror_props).to(to).on("start", this "adjust_images").on("stop", this, "reset_index" ).play();
    }
    
    function update_mirror() {
        mirror_props = {
            x = _props.x,
            y = _props.y + _props.height,
            width = _props.width,
            height = _props.height,
            alpha = _props.alpha,
            subimg_y = -1 * ref.texture_height,
            subimg_height = -ref.texture_height
        }
        //set_props(mirror, mirror_props);
    }
		
    function set_props(target, props) {
        foreach( key, val in props )
        try {
            if ( key == "rgb" ) {
                target.set_rgb(val[0],val[1],val[2]);
                if ( val.len() > 3 ) target.alpha = val[3];
            } else {
                target[key] = val;
            }
        } catch(e) { ::print("set_props error,  setting property: " + key + "\n") }
    }
}


class CustomFlow extends CoverFlow {
    opts = {
        COUNT = 9,
        SELECTED_PAD = 50,
        SELECTED_PRESERVE = true,
        SELECTED_WIDTH = 0.25,
        SELECTED_HEIGHT = 1.5,
        SELECTED_YOFFSET = 0.2,
        SELECTED_PINCH_Y = 0,
        UNSELECTED_PAD = 0,
        UNSELECTED_PRESERVE = false,
        UNSELECTED_YOFFSET = 0.7,
        UNSELECTED_HEIGHT = 0.5
        UNSELECTED_PINCH_Y = 30,
    }
}

class Gallery extends CoverFlow {
    function create(art, x, y, w, h) {
        for ( local i = 0; i < 5; i++)
            slots.push( CoverFlowArt(art) );
        slots[0].props({ x = 50, y = 50, width = 300, height = 300 });
        slots[1].props({ x = 450, y = 50, width = 300, height = 300 });
        slots[2].props({ x = 850, y = 50, width = 300, height = 300 });
        slots[3].props({ x = 50, y = 450, width = 300, height = 300 });
        slots[4].props({ x = 450, y = 450, width = 300, height = 300 });
        slots[0].ref.index_offset = -2;
        slots[1].ref.index_offset = -1;
        slots[2].ref.index_offset = 0;
        slots[3].ref.index_offset = 1;
        slots[4].ref.index_offset = 2;
    }
}