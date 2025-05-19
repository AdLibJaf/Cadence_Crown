// Always draw the banner (it now handles all phases)

// Compute alpha from fade_state
var alpha = 1;
if (fade_state == "fade_out") {
    alpha = fade_timer / fade_duration;        // 1→0
}
else if (fade_state == "fade_in") {
    alpha = fade_timer / fade_duration;        // 0→1
}

// Apply global alpha
draw_set_alpha(alpha);

// Center coordinates
var bx = display_get_gui_width()/2;
var by = 32;

// 1) Panel
draw_sprite(spr_banner, 0, bx, by);

// 2) Stars
draw_sprite(spr_banner_star, 0, bx - star_offset_x, by + star_offset_y);
draw_sprite(spr_banner_star, 0, bx + star_offset_x, by + star_offset_y);

// 3) Text wave
var letter_w = sprite_get_width(spr_banner_letters);
var space_w  = letter_w * 0.5;
var total_w  = 0;
for (var i = 1; i <= letter_count; i++) {
    total_w += (string_char_at(banner_text,i) == " " ? space_w : letter_w);
}
var start_x = bx - (total_w/2);
var draw_x  = start_x;

for (var i = 1; i <= letter_count; i++) {
    var ch = string_char_at(banner_text, i);
    if (ch == " ") {
        draw_x += space_w;
    } else {
        var frame = ord(ch) - ord("A");
        var offY  = letter_offset_y[i-1];
        draw_sprite(spr_banner_letters, frame, draw_x, by + offY);
        draw_x += letter_w;
    }
}

// Reset alpha for the rest of the GUI
draw_set_alpha(1);