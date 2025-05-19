/// obj_perfect_beat – Draw GUI

// 1) Compute your pulse bump (if you’re doing the beat pulse)
var bump = 0;
if (perfect_pulse_timer > 0) {
    var t    = perfect_pulse_timer / perfect_pulse_duration;      // 1→0
    bump     = sin(pi * t) * perfect_pulse_strength;      // up to ±pulse_strength
}

// 2) Pick which subimage
var subimg;
if (perfect_flash_timer > 0) {
    subimg = perfect_flash_type;  // 1 or 2
} else {
    // if gauge=0 → empty frame; else 1–8 → frames 3–10
    if (global.perfect_gauge == 0) {
        subimg = 0;
    } else {
        // clamp just in case gauge>8
        subimg = clamp(2 + global.perfect_gauge, 
                       3, 
                       sprite_get_number(spr_perfect_beat) - 1);
    }
}

// 3) Calculate final scale with pulse
var final_scale = ui_scale * (1 + bump);

// 4) Position (to the left of your board)
var padding  =  100 * ui_scale;
var bw       = sprite_get_width(spr_perfect_beat)  * final_scale;
var bh       = sprite_get_height(spr_perfect_beat) * final_scale;
var board_l  = global.grid_offset_x;
var gx       = board_l - padding - bw/2;
var board_t  = global.grid_offset_y;
var board_h  = global.grid_rows * global.tile_size;
var gy       = board_t + board_h/2;

// 5) Draw it
draw_sprite_ext(
    spr_perfect_beat, subimg,
    gx, gy,
    final_scale, final_scale,
    0, c_white, 1
);