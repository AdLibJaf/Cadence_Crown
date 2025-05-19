function advance_phase() {
    switch (global.phase_step) {
        case 0:
            // After planning phase, go to whoever won the coin flip
            global.current_phase = global.first_turn_team + "_turn";
            global.phase_step = 1;
            break;

        case 1:
            // After first team moves, switch to other team
            global.current_phase = (global.first_turn_team == "player") ? "enemy_turn" : "player_turn";
            global.phase_step = 2;
            break;

        case 2:
            // After both sides have moved, return to planning
            global.current_phase = "planning";
            global.phase_step = 0;
            break;
    }

    global.beat_count = 0;
}