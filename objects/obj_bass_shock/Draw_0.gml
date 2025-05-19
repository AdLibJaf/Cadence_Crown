/// obj_bass_shock – Draw Event
draw_set_color(c_white);
draw_set_alpha(alpha);

/// draw a single line out from the origin
var tx = origin_x + dirX * length;
var ty = origin_y + dirY * length;
draw_line(origin_x, origin_y, tx, ty);

/// reset alpha for any other drawing
draw_set_alpha(1);
