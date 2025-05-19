/// obj_piece – Create Event

depth        = -100;    // draw above grid

grid_x       = 0;
grid_y       = 0;
piece_type   = "";      // will be set by spawn_piece()
team         = "";      // same
is_stunned   = false;   // stun flag
stun_timer   = 0;       // unused unless you want a per‐beat timer
move_credit  = true;    // can move once per turn
stun_cooldown = 0;      // number of rounds before this Bass can re‐stun
stun_duration = 0; 


// Piece 'bounce' on beat if their turn
hop_duration = floor(global.beat_interval * room_speed / 2);
hop_height   = 8;
hop_timer    = 0;
hop_offset   = 0;      // current Y offset for drawing

// NOTE: allowed_bars & sprite_index are all set in spawn_piece()

// Conductor baton swap cooldown
// ensure all pieces have baton_cooldown 0 
baton_cooldown = 0; 
// then do conductor specific cooldown
if (piece_type == "Conductor") {
	baton_cooldown = 0;
}

// Stun anim state
stun_anim_timer = 0; 
stun_anim_frame = -1; 
stun_anim_speed = 0.15; 

// Harmony shield state
is_shielded = false; 
shield_duration = 0; 
shield_cooldown = 0; 
shield_state = ""; //spawn, idle, break
shield_frame = 0; 
shield_fps = 0.2; 

