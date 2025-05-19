// ─────────────────────────────────────────────────────────────────────────────
// spawn_piece(x, y, the_type, the_team)  — Script
// ─────────────────────────────────────────────────────────────────────────────
function spawn_piece(_x, _y, _type, _team) {
    // Create the piece instance
    var inst = instance_create_layer(
        _x * global.tile_size + global.grid_offset_x,
        _y * global.tile_size + global.grid_offset_y,
        "Instances", obj_piece
    );
    
    // --- Logic state ---
    inst.grid_x      = _x;
    inst.grid_y      = _y;
    inst.piece_type  = _type;
    inst.team        = _team;
    inst.move_credit = true;
    
    // Debug: log spawn
    show_debug_message("Spawned " + _type + " [" + _team + "] at (" +
                       string(_x) + "," + string(_y) + ")");
    
    // --- Allowed bars ---
    if (_type == "Conductor" || _type == "Harmony") {
        inst.allowed_bars = [1, 3];
    }
    else if (_type == "Bass" || _type == "Melody") {
        inst.allowed_bars = [2, 4];
    }
    else if (_type == "Rhythm") {
        // jumps two tiles orthogonally—give it bars 2 & 3
        inst.allowed_bars = [2, 3];
    }
    else {
        inst.allowed_bars = [1, 2, 3, 4];
    }
    
    // --- Sprite assignment ---
    if (_type == "Melody") {
        if (_team == "player") inst.sprite_index = spr_melody_player;
        else                   inst.sprite_index = spr_melody_enemy;
    }
    else if (_type == "Bass") {
        if (_team == "player") inst.sprite_index = spr_bass_player;
        else                   inst.sprite_index = spr_bass_enemy;
    }
    else if (_type == "Harmony") {
        if (_team == "player") inst.sprite_index = spr_harmony_player;
        else                   inst.sprite_index = spr_harmony_enemy;
    }
    else if (_type == "Conductor") {
        if (_team == "player") inst.sprite_index = spr_conductor_player;
        else                   inst.sprite_index = spr_conductor_enemy;
    }
    else if (_type == "Rhythm") {
        if (_team == "player") inst.sprite_index = spr_rhythm_player;
        else                   inst.sprite_index = spr_rhythm_enemy;
    }
    else {
        // Unknown type → leave obj_piece’s default sprite, but warn
        show_debug_message("Warning: no sprite for piece type '" + _type + "'");
    }
}

