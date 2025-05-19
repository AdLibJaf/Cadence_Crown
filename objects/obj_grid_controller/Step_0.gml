/// obj_grid_controller – Step Event

// 1) — Beat & Phase Tracking —
var pos_s         = audio_sound_get_track_position(global.music_channel);
if (pos_s < global.last_pos_s) {
    global.loop_offset += global.track_duration;
}
global.last_pos_s = pos_s;

var abs_pos_s      = pos_s + global.loop_offset;
var new_beat_index = floor(abs_pos_s / global.beat_interval);

if (new_beat_index > global.last_beat_index) {
    // — A new beat!
    global.last_beat_index = new_beat_index;
    global.beat_count     += 1;
    global.new_beat_event  = true;

    // record beat time for perfect‐timing
    global.last_click_beat_time = abs_pos_s;

    // How many bars this phase lasts?
    var bars_for_phase = (global.current_phase == "planning"
                          ? global.PLANNING_PHASE_BARS
                          : (global.current_phase == "player"
                             ? global.PLAYER_PHASE_BARS
                             : global.ENEMY_PHASE_BARS));
    var phase_beats = bars_for_phase * global.BEATS_PER_BAR;

    // 1-based beat index within this phase
    var beat_index = global.beat_count - global.phase_start_beat;

    //
    // A) Phase‐rollover
    //
    if (beat_index > phase_beats) {
        // cycle planning → first team → second team → planning …
        var first  = global.first_turn_team;
        var second = (first == "player") ? "enemy" : "player";
        if      (global.current_phase == "planning") global.current_phase = first;
        else if (global.current_phase == first)      global.current_phase = second;
        else                                         global.current_phase = "planning";

        show_debug_message("Phase changed to: " + global.current_phase);
		
		// 2️⃣ On entering new turn, tick down cooldowns + shield_duration
		if (global.current_phase == "player" || global.current_phase == "enemy") {
		    with (obj_piece) {
		        // A) Stun durations
		        if (stun_duration > 0) {
		            stun_duration -= 1;
		            is_stunned    = (stun_duration > 0);
		        }
		        // B) Bass stun cooldown
		        if (stun_cooldown > 0) stun_cooldown -= 1;
		        // C) Conductor baton cooldown
		        if (piece_type == "Conductor" && baton_cooldown > 0)
		            baton_cooldown -= 1;
		        // D) Harmony shield cooldown
		        if (piece_type == "Harmony" && shield_cooldown > 0)
		            shield_cooldown -= 1;
		        // E) Shield durations
		        if (shield_duration > 0) {
		            shield_duration -= 1;
		            if (shield_duration <= 0) {
		                is_shielded  = false;
		                shield_state = "break";
		                shield_frame = 0;
		            }
		        }
		    }
		}


        // 1️⃣ Tick down stun_duration for entering team
        if (global.current_phase == "player" || global.current_phase == "enemy") {
            with (obj_piece) {
                if (team == global.current_phase && stun_duration > 0) {
                    stun_duration -= 1;
                    is_stunned    = (stun_duration > 0);
                }
            }
        }

        // 3️⃣ Give or remove move_credit
        with (obj_piece) {
            if (team == global.current_phase) {
                move_credit = !is_stunned;
            }
        }

        // 4️⃣ Reset phase timing
        global.phase_start_beat = global.beat_count - 1;
        beat_index              = 1;
        global.bar_in_phase     = 1;
    }

    //
    // B) Compute new_bar_event
    //
    var beat_in_bar     = ((beat_index - 1) mod global.BEATS_PER_BAR) + 1;
    global.new_bar_event = (beat_in_bar == 1);

    // C) Which bar of the phase?
    var new_bar = ((beat_index - 1) div global.BEATS_PER_BAR) + 1;
    if (new_bar > bars_for_phase) new_bar = bars_for_phase;

    // D) Debug
    show_debug_message(
        "Beat "          + string(beat_in_bar)
      + " | BarInPhase " + string(global.bar_in_phase)
      + " → "            + string(new_bar)
      + " | Phase "      + global.current_phase
    );

    // E) On entering new bar, reset highlights & move flag
    if (new_bar != global.bar_in_phase) {
        global.bar_in_phase = new_bar;
        show_debug_message("Advanced to BarInPhase " + string(new_bar));
    }
    if (global.new_bar_event) {
        global.valid_move_tiles = [];
        global.selected_piece   = noone;
        global.moved_this_bar   = false;
        // auto-run AI on enemy turn
        if (global.current_phase == "enemy") enemy_ai();
    }
}
else {
    // not a new beat this Step
    global.new_beat_event = false;
}


// 2) — Grid & Mouse Hover —

// ── Screen-shake logic ──
if (shake_timer > 0) {
    shake_timer -= 1;
    shake_off_x = irandom_range(-shake_magnitude, shake_magnitude);
    shake_off_y = irandom_range(-shake_magnitude, shake_magnitude);
} else {
    shake_off_x = 0;
    shake_off_y = 0;
}

// apply shake by jittering around our stored base offsets
global.grid_offset_x = base_grid_offset_x + shake_off_x;
global.grid_offset_y = base_grid_offset_y + shake_off_y;

// now compute hover in board‐space
var mx = mouse_x - global.grid_offset_x;
var my = mouse_y - global.grid_offset_y;
tile_hover_x = (mx >= 0 && mx < global.grid_cols * global.tile_size)
               ? floor(mx / global.tile_size) : -1;
tile_hover_y = (my >= 0 && my < global.grid_rows * global.tile_size)
               ? floor(my / global.tile_size) : -1;

// 2.5) — Hover‐to‐Highlight —
if (global.selected_piece == noone) {
    var hover_inst = get_piece_at(tile_hover_x, tile_hover_y);
    if (hover_inst != noone && hover_inst.team == "player") {
        generate_valid_moves(hover_inst);
    } else {
        global.valid_move_tiles = [];
    }
}


// 3) — Player Input — one action max per bar —
if (global.current_phase == "player" && mouse_check_button_pressed(mb_left)) {
    // A) Already acted?
    if (global.moved_this_bar) {
        show_debug_message("Already moved this bar!");
        return;
    }

    var clicked = get_piece_at(tile_hover_x, tile_hover_y);

    // B) Nothing selected → try to select (unified for Harmony & others)
    if (global.selected_piece == noone) {
        if (clicked != noone
            && clicked.team == "player"
            && clicked.move_credit)
        {
			
			// only allow selection if this piece can move on bar 
			var ok = false; 
			for (var j = 0; j < array_length(clicked.allowed_bars); j++) {
				if (clicked.allowed_bars[j] == global.bar_in_phase) {
					ok = true; 
					break;
				}
			}
			if (!ok) {
				show_debug_message("Cannot select" + clicked.piece_type + 
				" on bar " + string(global.bar_in_phase)
				); 
			} 
			else {
			
	            // Select it
	            global.selected_piece   = clicked;

	            // 1) Normal move-tiles
	            global.valid_move_tiles = [];
	            generate_valid_moves(clicked);
	            show_debug_message(
	                clicked.piece_type + " move-tiles: " +
	                string(array_length(global.valid_move_tiles))
	            );

	            // 2) Baton-swap for Conductor
	            if (clicked.piece_type == "Conductor"
	                && clicked.baton_cooldown == 0)
	            {
	                with (obj_piece) {
	                    if (id != clicked.id && team == clicked.team) {
	                        array_push(global.valid_move_tiles,
	                                   [grid_x, grid_y]);
	                    }
	                }
	                show_debug_message("Conductor can swap—" 
	                    + string(array_length(global.valid_move_tiles))
	                    + " targets");
	            }

	            // 3) Shield-tiles for Harmony
				global.valid_shield_tiles = [];
				if (clicked.piece_type == "Harmony"
				    && clicked.shield_cooldown == 0)
				{
				    // all eight directions
				    var dirs = [
				        [ 1,-1], [ 1, 0], [ 1, 1],
				        [ 0,-1],          [ 0, 1],
				        [-1,-1], [-1, 0], [-1, 1]
				    ];
				    // loop over the *entire* array
				    for (var d = 0; d < array_length(dirs); d++) {
				        var tx = clicked.grid_x + dirs[d][0],
				            ty = clicked.grid_y + dirs[d][1];
				        var inst = get_piece_at(tx, ty);
				        if (inst != noone
				            && inst.team == "player"
				            && !inst.is_shielded)
				        {
				            array_push(global.valid_shield_tiles, [tx, ty]);
				        }
				    }
				    if (array_length(global.valid_shield_tiles) > 0) {
				        show_debug_message("Select a friendly piece to shield");
				    }
				}
	        }
	    }
	}
    // C) Something is selected → attempt action
    else {
        var sp       = global.selected_piece;
        var moved    = false;
        var didShield = false;

        //
        // C.1) Shield-mode: only if you clicked on a shield tile
        //
        for (var i = 0; i < array_length(global.valid_shield_tiles); i++) {
            var s = global.valid_shield_tiles[i];
            if (tile_hover_x == s[0] && tile_hover_y == s[1]) {
                // — Perfect/Miss Gauge for shield —
                var click_time = audio_sound_get_track_position(global.music_channel)
                               + global.loop_offset;
                var diff       = click_time - global.last_click_beat_time;
                var isPerfect  = abs(diff) <= global.PERFECT_WINDOW;
                if (isPerfect) {
                    global.perfect_gauge += 1;
                    show_debug_message("Perfect shield! Gauge: "
                                     + string(global.perfect_gauge) + "/8");
                } else {
                    global.perfect_gauge = max(0, global.perfect_gauge - 1);
                    show_debug_message("Shield timing missed. Gauge: "
                                     + string(global.perfect_gauge) + "/8");
                }
                if (global.perfect_gauge >= 8) {
                    global.perfect_gauge = 0;
                    global.gauge_points += 1;
                    show_debug_message("★ Gauge filled! Points: "
                                     + string(global.gauge_points));
                }

                // — Apply the shield —
                var target = get_piece_at(s[0], s[1]);
                target.is_shielded     = true;
                target.shield_duration = 2;
                target.shield_state    = "spawn";
                target.shield_frame    = 0;
                sp.shield_cooldown     = 4;
                sp.move_credit         = false;
                global.moved_this_bar  = true;
                show_debug_message("Shielded "
                                  + target.piece_type
                                  + " at ("
                                  + string(target.grid_x) + ","
                                  + string(target.grid_y) + ")");
                didShield = true;
                moved     = true;
                break;
            }
        }

        //
        // C.2) Normal move / capture / baton-swap if we didn’t shield
        //
        if (!didShield) {
            for (var i = 0; i < array_length(global.valid_move_tiles); i++) {
                var t = global.valid_move_tiles[i];
                if (tile_hover_x == t[0] && tile_hover_y == t[1]) {
                    // — Perfect/Miss Gauge for move —
                    var click_time = audio_sound_get_track_position(global.music_channel)
                                   + global.loop_offset;
                    var diff       = click_time - global.last_click_beat_time;
                    var isPerfect  = abs(diff) <= global.PERFECT_WINDOW;
                    if (isPerfect) {
                        global.perfect_gauge += 1;
                        show_debug_message("Perfect move! Gauge: "
                                         + string(global.perfect_gauge) + "/8");
                    } else {
                        global.perfect_gauge = max(0, global.perfect_gauge - 1);
                        show_debug_message("Move timing missed. Gauge: "
                                         + string(global.perfect_gauge) + "/8");
                    }
					
                    if (global.perfect_gauge >= 8) {
                        global.perfect_gauge = 0;
                        global.gauge_points += 1;
                        show_debug_message("★ Gauge filled! Points: "
                                         + string(global.gauge_points));
                    }

                    var target = get_piece_at(t[0], t[1]);

                    // — Baton-swap for Conductor —
                    if (sp.piece_type == "Conductor"
                        && target != noone
                        && target.team == sp.team
                        && sp.baton_cooldown == 0)
                    {
                        var ax = sp.grid_x, ay = sp.grid_y;
                        sp.grid_x     = target.grid_x;
                        sp.grid_y     = target.grid_y;
                        target.grid_x = ax;
                        target.grid_y = ay;
                        sp.move_credit        = false;
                        global.moved_this_bar = true;
                        sp.baton_cooldown     = 4;
                        show_debug_message("Baton Swap with "
                                          + target.piece_type);
                    }
                    else {
                        // a) If target is shielded, just break its shield
                        if (target != noone
                            && target.team != sp.team
                            && target.is_shielded)
                        {
                            target.is_shielded  = false;
                            target.shield_state = "break";
                            target.shield_frame = 0;
                            show_debug_message("Shield broken on "
                                              + target.piece_type);
                        }
                        // b) Otherwise capture as normal
                        else if (target != noone
                                 && target.team != sp.team)
                        {
                            // Conductor-capture win check
                            if (target.piece_type == "Conductor") {
                                if (target.team == "enemy") game_win("player");
                                else                         game_win("enemy");
                            }
                            // Bass cannot capture
                            if (sp.piece_type == "Bass") {
                                show_debug_message("Bass cannot capture!");
                                break;
                            }
                            show_debug_message("Captured "
                                              + target.piece_type);
                            with (target) instance_destroy();
                        }

						// — c) Commit the move —
						sp.grid_x          = t[0];
						sp.grid_y          = t[1];
						sp.move_credit     = false;
						global.moved_this_bar = true;
						show_debug_message("Moved " + sp.piece_type);

						// — d) Bass shockwave on move —
						if (sp.piece_type == "Bass" && sp.stun_cooldown == 0) {
					
						    // 1) Compute the pixel‐center of the tile we just landed on
						    var px = global.grid_offset_x 
						           + sp.grid_x * global.tile_size 
						           + global.tile_size/2;
						    var py = global.grid_offset_y 
						           + sp.grid_y * global.tile_size 
						           + global.tile_size/2;

						    // 2) Four‐directional shockwave
						    var dirs = [[ 1,0],[-1,0],[0, 1],[0,-1]];
						    for (var i = 0; i < 4; i++) {
						        var dx = dirs[i][0], dy = dirs[i][1];

						        // — a) Spawn the visual effect —
						        // Make sure your room has an Instance layer named "Effects"
						        var eff = instance_create_layer(px, py, "Effects", obj_bass_shock);
						        eff.dirX = dx;    // your effect can read these to push its sprite
						        eff.dirY = dy;
						        eff.origin_x = px; // optional: if your effect needs to know start-pos
						        eff.origin_y = py;

						        // — b) Apply shield‐break or stun to any piece in that direction —
						        var target = get_piece_at(sp.grid_x + dx, sp.grid_y + dy);
						        if (target != noone && target.team != sp.team) {
						            if (target.is_shielded) {
						                // break their shield instead of stun
						                target.is_shielded  = false;
						                target.shield_state = "break";
						                target.shield_frame = 0;
						                show_debug_message("Shield broken on " + target.piece_type);
						            } else {
						                // stun for 3 full phases (you set stun_duration=3)
						                target.is_stunned    = true;
						                target.stun_duration = 3;
										shake_timer = shake_duration; // camera shake on stun
						                show_debug_message(target.piece_type +
						                                   " stunned by shockwave");
						            }
						        }
						    }

						    // 3) Put the Bass on cooldown so it can’t shock again until its next turn
						    sp.stun_cooldown = 1;
						    show_debug_message("Bass shockwave—cooldown=1");
						}
						
					}

						moved = true;
						break;  // you’ve handled the move+shock, so exit the loop
                }
            }
        }

        // D) Invalid click?
        if (!moved) {
            show_debug_message("Invalid action at ("
                              + string(tile_hover_x) + ","
                              + string(tile_hover_y) + ")");
        }

        // E) Cleanup
        global.selected_piece     = noone;
        global.valid_move_tiles   = [];
        global.valid_shield_tiles = [];
    }
}