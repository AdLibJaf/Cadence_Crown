function is_tile_threatened(_x, _y, _team) {
    with (obj_piece) {
        if (team != _team) {
            // This is an enemy piece
            var move_set;

            switch (piece_type) {
                case "Melody": move_set = global.moves_melody; break;
                case "Rhythm": move_set = global.moves_rhythm; break;
                case "Conductor": move_set = global.moves_conductor; break;
                case "Harmony": move_set = global.moves_harmony; break;
                case "Bass": move_set = global.moves_bass; break;
            }

            for (var i = 0; i < array_length(move_set); i++) {
                var dx = move_set[i][0];
                var dy = move_set[i][1];

                var tx = grid_x + dx;
                var ty = grid_y + dy;

                if (tx == _x && ty == _y) {
                    return true;
                }
            }
        }
    }

    return false;
}