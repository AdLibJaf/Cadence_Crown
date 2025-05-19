// Set colour 
draw_set_color(c_white); 

// Draw the 6x6 grid
for (var i = 0; i < global.grid_cols; i++) {
    for (var j = 0; j < global.grid_rows; j++) {
        var px = global.grid_offset_x + i * global.tile_size;
        var py = global.grid_offset_y + j * global.tile_size;

        // Choose light or dark tile
        var tile_sprite = ((i + j) mod 2 == 0) ? spr_tile_light : spr_tile_dark;
        draw_sprite(tile_sprite, 0, px, py); 

        // Optional: highlight hover tile on top
		if (i == tile_hover_x && j == tile_hover_y) {
			draw_sprite_ext(
			spr_tile_cursor,
			image_index,
			px, py,
			ui_scale, 
			ui_scale, 
			0, 
			c_white, 1
			); 
			//draw_set_alpha(0.65);
			//draw_set_color(c_yellow); 
			//draw_rectangle(px, py, px + global.tile_size, py + global.tile_size, true);
			//draw_set_alpha(1);
		}
	}
}


// Highlight Legal Moves
if (variable_global_exists("valid_move_tiles")) {
    for (var i = 0; i < array_length(global.valid_move_tiles); i++) {
        var tile = global.valid_move_tiles[i];
        var gx = tile[0];
        var gy = tile[1];

        var px = global.grid_offset_x + gx * global.tile_size;
        var py = global.grid_offset_y + gy * global.tile_size;

        draw_set_alpha(0.3);
        draw_set_color(c_blue);
        draw_rectangle(px, py, px + global.tile_size, py + global.tile_size, false);
        draw_set_alpha(1);
    }
}

