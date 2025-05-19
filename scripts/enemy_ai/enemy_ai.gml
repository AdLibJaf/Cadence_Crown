/// scr_enemy_ai(): basic random‐move AI, one action max per bar
function enemy_ai() {
    // — 0) guard: only one action per bar —
    if (global.moved_this_bar) return;

    // — 1) Gather all enemy pieces with credit this bar —
    var candidates = [];
    with (obj_piece) {
        if (team == "enemy" && move_credit) {
            // only on allowed bars
            for (var i = 0; i < array_length(allowed_bars); i++) {
                if (allowed_bars[i] == global.bar_in_phase) {
                    array_push(candidates, id);
                    break;
                }
            }
        }
    }
    if (array_length(candidates) == 0) return;

    // — 2) pick one piece at random —
    var pick_id = candidates[ irandom(array_length(candidates) - 1) ];

    // — 3) generate its valid moves —
    with (obj_piece) if (id == pick_id) {
        generate_valid_moves(id);
    }

    // — 4) If it’s a Bass with its shock off-cooldown, only keep **empty** tiles —
    //     (so it never attempts to “stand on” another piece)
    with (obj_piece) if (id == pick_id && piece_type == "Bass" && stun_cooldown == 0) {
        var filtered = [];
        for (var j = 0; j < array_length(global.valid_move_tiles); j++) {
            var m = global.valid_move_tiles[j];
            if (get_piece_at(m[0], m[1]) == noone) {
                array_push(filtered, m);
            }
        }
        global.valid_move_tiles = filtered;
    }
    if (array_length(global.valid_move_tiles) == 0) return;

    // — 5) choose one of the remaining tiles —
    var tile = global.valid_move_tiles[
        irandom(array_length(global.valid_move_tiles) - 1)
    ];

    // — 6) execute the move —
    with (obj_piece) if (id == pick_id) {
        move_credit           = false;
        global.moved_this_bar = true;

        // Bass shockwave special
        if (piece_type == "Bass" && stun_cooldown == 0) {
            // move
            grid_x = tile[0];
            grid_y = tile[1];

            // apply shock in 4 directions
            var dirs = [[1,0],[-1,0],[0,1],[0,-1]];
            for (var d = 0; d < 4; d++) {
                var p = get_piece_at(grid_x + dirs[d][0],
                                     grid_y + dirs[d][1]);
                if (p != noone && p.team == "player") {
                    // if they’re shielded, break the shield
                    if (p.is_shielded) {
                        p.is_shielded   = false;
                        p.shield_state  = "break";
                        p.shield_frame  = 0;
                    }
                    else {
                        // otherwise, stun them
                        p.is_stunned    = true;
                        p.stun_duration = 3;
                    }
                }
            }

            stun_cooldown = 1;
            show_debug_message("AI Bass shockwave at (" +
                               string(grid_x) + "," +
                               string(grid_y) + ")");
        }
        // normal move / capture
        else {
            var tgt = get_piece_at(tile[0], tile[1]);
            if (tgt != noone) {
                // Bass can’t capture, so this only ever happens for others
                with (tgt) instance_destroy();
            }
            grid_x = tile[0];
            grid_y = tile[1];
            show_debug_message("AI moved " + piece_type +
                               " to (" +
                               string(grid_x) + "," +
                               string(grid_y) + ")");
        }
    }

    // — 7) cleanup highlights —
    global.valid_move_tiles = [];
    global.selected_piece   = noone;
}
