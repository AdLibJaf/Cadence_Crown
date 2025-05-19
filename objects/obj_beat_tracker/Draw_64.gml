// 1) Banner (using draw_sprite_ext with scale)
var bw     = sprite_get_width(spr_beat_tracker);
var bh     = sprite_get_height(spr_beat_tracker);
var sbw    = bw * ui_scale;
var sbh    = bh * ui_scale;
var bx     = window_get_width()  / 2;
var by     = window_get_height() - (sbh / 2) - 32 * ui_scale;
draw_sprite_ext(
    spr_beat_tracker, 0,
    bx, by,
    ui_scale, ui_scale,    // x-scale, y-scale
    0,                     // rotation
    c_white,               // color
    1                      // alpha
);

// 2) Layout parameters (scaled)
var total_beats = beats_per_bar;  // e.g. 8
var cols        = 4;
var gutterX     = bw / (cols + 1) * ui_scale;

// 3) Draw each note icon
for (var idx = 0; idx < total_beats; idx++) {
    var r   = floor(idx / cols);
    var c   = idx mod cols;
    // base position inside the *scaled* banner
    var dx  = bx - sbw/2 + gutterX * (c + 1);
    var dy  = by - sbh/2 + sbh * (r == 0 ? 0.3 : 0.7);

    // bounce offset
    if (idx + 1 == current_beat && bounce_timer > 0) {
        var t    = bounce_timer / bounce_duration; 
        var offs = sin(pi * t) * -12 * ui_scale; 
        dy += offs;
    }

    // draw note at scaled size
    var frame = (idx + 1 == current_beat) ? 1 : 0;
    draw_sprite_ext(
        spr_beat_tracker_note, frame,
        dx, dy,
        ui_scale, ui_scale,
        0, c_white, 1
    );
}