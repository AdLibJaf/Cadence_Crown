// 1) Calculate the hop offset (you should already have hop_offset from your Step event)
var offset_y = hop_offset;  

// pick tint white if can move, grey if cant
var tint = move_credit ? c_white : c_gray;

// 2) Calculate pixel position on the grid, including the hop
var px = global.grid_offset_x 
       + grid_x * global.tile_size 
       + global.tile_size / 2;
var py = global.grid_offset_y 
       + grid_y * global.tile_size 
       + global.tile_size / 2
       + offset_y;    // apply the hop here!

// 3) Draw the sprite at (px,py)
if (sprite_index != -1) {
    draw_sprite_ext(
        sprite_index, 
        image_index, 
        px, 
        py, 
        image_xscale, 
        image_yscale, 
        image_angle, 
        tint, 
        image_alpha
    );
}

// Overlay shield animation
if (shield_state != "") {
    // pick the correct sprite
    var spt;
	// new: pick the team-specific sprite
	if (team == "player") {
	    if      (shield_state == "spawn") spt = spr_shield_spawn_player;
	    else if (shield_state == "idle" ) spt = spr_shield_idle_player;
	    else                               spt = spr_shield_break_player;
	} else {
	    if      (shield_state == "spawn") spt = spr_shield_spawn_enemy;
	    else if (shield_state == "idle" ) spt = spr_shield_idle_enemy;
	    else                               spt = spr_shield_break_enemy;
	}

    var sf = floor(shield_frame);
    var px = global.grid_offset_x + grid_x * global.tile_size + global.tile_size/2;
    var py = global.grid_offset_y + grid_y * global.tile_size + global.tile_size/2;

    draw_sprite_ext(
        spt, sf,
        px, py,
        1, 1,
        0, c_white, 1
    );
}


// Stunned piece 
if (stun_anim_frame >= 0) {
	var px = global.grid_offset_x + grid_x * global.tile_size + global.tile_size/2; 
	var py = global.grid_offset_y + grid_y * global.tile_size + global.tile_size/2;
	
	draw_sprite_ext(
	spr_stun, 
	stun_anim_frame, 
	px, py, 
	1, 1, 
	0, 
	c_white, 
	1
	);
}

// 4) Highlight if selected
if (id == global.selected_piece) {
    draw_set_color(c_lime);
    draw_rectangle(
        px - global.tile_size/2 + 4, 
        py - global.tile_size/2 + 4,
        px + global.tile_size/2 - 4, 
        py + global.tile_size/2 - 4, 
        false
    );
}



// 5) (Optional) show piece type above
//draw_set_color(c_blue);
//draw_text(px, py - global.tile_size/2 - 4, piece_type);

// 6) Debug grid coords
//draw_text(10, 10 + (grid_y * 16), "grid_x: " + string(grid_x) + ", grid_y: " + string(grid_y));
//draw_text(grid_x * global.tile_size, grid_y * global.tile_size + 40, team);