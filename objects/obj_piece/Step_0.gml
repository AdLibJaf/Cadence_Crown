
// ===  Harmony Shield ===
// 1) Advance shield cooldown/duration on phase change
if (global.new_bar_event && global.bar_in_phase == 1) {  
    // (this runs once per bar-start; only tick on the first bar of a new phase)
    if (shield_duration > 0) {
        shield_duration -= 1;
        if (shield_duration <= 0) {
            is_shielded  = false;
            shield_state = "break";
            shield_frame = 0;
        }
    }
    if (piece_type == "Harmony" && shield_cooldown > 0) {
        shield_cooldown -= 1;
    }
}

// 2) Animate the shield sprite if active
if (shield_state != "") {
    shield_frame += shield_fps;
    var maxf;
	// new: pick player vs enemy variants
	var spn = (team == "player"
	           ? spr_shield_spawn_player
	           : spr_shield_spawn_enemy);
	var idl = (team == "player"
	           ? spr_shield_idle_player
	           : spr_shield_idle_enemy);
	var brk = (team == "player"
	           ? spr_shield_break_player
	           : spr_shield_break_enemy);

	if      (shield_state == "spawn") maxf = sprite_get_number(spn);
	else if (shield_state == "idle" ) maxf = sprite_get_number(idl);
	else                               maxf = sprite_get_number(brk);

    if (shield_frame >= maxf) {
        if (shield_state == "spawn") {
            shield_state  = "idle"; 
            shield_frame  = 0;
        }
        else if (shield_state == "break") {
            shield_state  = "";
            shield_frame  = 0;
        }
        else {
            shield_frame -= maxf;  // loop idle
        }
    }
}

// Piece Stunned
if (is_stunned) {
	stun_anim_timer += stun_anim_speed; 
	if (stun_anim_timer >= 1) {
		stun_anim_timer -= 1; 
	}
	stun_anim_frame = floor(stun_anim_timer * sprite_get_number(spr_stun));
} else {
	stun_anim_timer = 0; 
	stun_anim_frame = -1;
}

// 1) On each new beat, check if this piece should hop
if (global.new_beat_event) {
    // only hop if this piece can act in this bar
    var myTurn     = (team == global.current_phase);
    var barAllowed = false;
    for (var i = 0; i < array_length(allowed_bars); i++) {
        if (allowed_bars[i] == global.bar_in_phase) {
            barAllowed = true;
            break;
        }
    }
    if (myTurn && barAllowed) {
        hop_timer = hop_duration;
    }
}

// 2) Compute the offset each frame
if (hop_timer > 0) {
    // t runs from 1→0
    var t    = hop_timer / hop_duration;
    // triangular wave 0→1→0
    var wave = 1 - abs(2*t - 1);
    // negative so sprite moves up
    hop_offset = -wave * hop_height;
    hop_timer -= 1;
} else {
    hop_offset = 0;
}