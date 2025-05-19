
function get_piece_at(_x, _y) {
    with (obj_piece) {
        if (grid_x == _x && grid_y == _y) {
            return id;
        }
    }
    return noone;
}