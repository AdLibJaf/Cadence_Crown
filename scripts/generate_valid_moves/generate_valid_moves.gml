function generate_valid_moves(piece) {
    global.valid_move_tiles = [];
    var gx = piece.grid_x, gy = piece.grid_y;
    var move_set;
    switch (piece.piece_type) {
        case "Melody":    move_set = global.moves_melody;    break;
        case "Rhythm":    move_set = global.moves_rhythm;    break;
        case "Bass":      move_set = global.moves_bass;      break;
        case "Harmony":   move_set = global.moves_harmony;   break;
        case "Conductor": move_set = global.moves_conductor; break;
        default:          move_set = [];
    }
    for (var i = 0; i < array_length(move_set); i++) {
        var dx = move_set[i][0], dy = move_set[i][1],
            tx = gx + dx, ty = gy + dy;
        if (tx >= 0 && tx < global.grid_cols
         && ty >= 0 && ty < global.grid_rows) {
            var target = get_piece_at(tx, ty);
			// empty square always OK
			if (target == noone) {
			    array_push(global.valid_move_tiles, [tx, ty]);
			}
			// capture only if enemy and _not_ shielded
			else if (target.team != piece.team && !target.is_shielded) {
			    array_push(global.valid_move_tiles, [tx, ty]);
            }
        }
    }
    return global.valid_move_tiles;
}