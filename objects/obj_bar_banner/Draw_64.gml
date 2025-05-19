// 1) Compute text bounce offset (–12px max, scaled)
var bounce_off = 0;
if (bounce_timer > 0) {
    var t         = bounce_timer / bounce_duration;   // 1→0
    bounce_off    = sin(pi * t) * -12 * ui_scale;     // up to –12px
}

// 2) Draw the banner (no bounce)
var bw   = sprite_get_width(spr_bar_banner);
var bh   = sprite_get_height(spr_bar_banner);
var sbw  = bw * ui_scale;
var sbh  = bh * ui_scale;
var bx   = window_get_width() / 2;
var by   = global.grid_offset_y
         - sbh/2
         - (banner_margin * ui_scale);
draw_sprite_ext(
    spr_bar_banner, 0,
    bx, by,
    ui_scale, ui_scale,
    0, c_white, 1
);

// 1) Text dimensions (scaled)
var lw        = sprite_get_width(spr_banner_letters)     * ui_scale;
var nh        = sprite_get_width(spr_bar_banner_numbers) * ui_scale;

// 2) Gaps
var charGap   = 2  * ui_scale;   // between B↔A and A↔R
var numberGap = 8  * ui_scale;   // before the digit

// 3) Compute total width: 3 letters + digit, plus 2*charGap + numberGap
var total_w = (3*lw + nh) + (2*charGap + numberGap);

// 4) Start cursor at left‐edge so group centers on bx
var cursor = bx - (total_w/2);

// 5) Draw “B”, “A”, “R”
var letters = ["B","A","R"];
for (var i = 0; i < 3; i++) {
    var frame = ord(letters[i]) - ord("A");
    // draw each letter centered on its cell
    draw_sprite_ext(
        spr_banner_letters, frame,
        cursor + lw/2,             // center X of this letter
        by + bounce_off,           // Y with bounce
        ui_scale, ui_scale, 0, c_white, 1
    );
    // advance cursor by letter width + appropriate gap
    cursor += lw + (i < 2 ? charGap : numberGap);
}

// 6) Draw the digit
var num_frame = current_bar - 1;  // 1→0, 2→1, etc.
draw_sprite_ext(
    spr_bar_banner_numbers, num_frame,
    cursor + nh/2,                // center X of the number
    by + bounce_off,              // Y with bounce
    ui_scale, ui_scale, 0, c_white, 1
);