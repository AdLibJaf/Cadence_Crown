// ─────────────────────────────────────────────────────────────────────────────
// obj_grid_controller  — Create Event
// ─────────────────────────────────────────────────────────────────────────────
// ui scale
ui_scale = 1
image_speed = 0.5

// Beat & bar constants
global.BPM               = 120;
global.BEATS_PER_BAR     = 8;
global.beat_interval     = 60 / global.BPM;

// Phase lengths
global.PLANNING_PHASE_BARS = 4;
global.PLAYER_PHASE_BARS   = 4;
global.ENEMY_PHASE_BARS    = 4;

// Loop & beat tracking
global.last_pos_s       = 0;
global.loop_offset      = 0;
global.last_beat_index  = -1;
global.beat_count       = 0;

// Phase state
global.current_phase     = "planning";
global.phase_start_beat  = 0;
global.bar_in_phase      = 1;
global.new_bar_event     = false;
global.bar_count_in_phase = 0; 
global.new_beat_event = false;

// Perfect timing

global.PERFECT_WINDOW = 0.10; 
global.last_click_beat_time = 0;

// your new gauge state:
global.perfect_gauge        = 0;    // current fill (0–7)
global.gauge_points         = 0;    // how many full-gauge points earned

// Coin toss: choose "player" or "enemy"
randomize();
if (irandom(1) == 0) {
    global.first_turn_team = "player";
} else {
    global.first_turn_team = "enemy";
}
show_debug_message("Coin toss winner: " + string(global.first_turn_team));

// Starting phase
show_debug_message("Starting phase: planning");

// Play music & get its length
global.music_channel   = audio_play_sound(mus_cadence_crown, 1, true);
global.track_duration  = audio_sound_length(mus_cadence_crown);

// Grid layout
global.tile_size     = 64;
global.grid_cols     = 6;
global.grid_rows     = 6;
global.grid_offset_x = (window_get_width()  - global.grid_cols * global.tile_size) / 2;
global.grid_offset_y = (window_get_height() - global.grid_rows * global.tile_size) / 2;

// Mouse‐hover init
tile_hover_x = -1;
tile_hover_y = -1;

// Movement patterns
global.moves_melody    = [[-1,-1],[0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0]];
global.moves_rhythm    = [[2,0],[1,0],[0,1],[0,2],[-1,0],[-2,0],[0,-1],[0,-2]];
global.moves_bass      = [[1,0],[0,1],[-1,0],[0,-1]];
global.moves_harmony   = [[1,1],[-1,1],[-1,-1],[1,-1]];
global.moves_conductor = [[1,0],[0,1],[-1,0],[0,-1]];

// Spawn PLAYER pieces
var player_formation = [
    ["","Melody","Conductor","Harmony","Melody",""],
    ["","Bass","","Rhythm","",""]
];
for (var row = 0; row < array_length(player_formation); row++) {
    for (var col = 0; col < array_length(player_formation[row]); col++) {
        var t = player_formation[row][col];
        if (t != "") {
            spawn_piece(col, 5-row, t, "player");
        }
    }
}

// Spawn ENEMY pieces
var enemy_formation = [
    ["","Melody","Conductor","Harmony","Melody",""],
    ["","Bass","","Rhythm","",""]
];
for (var row = 0; row < array_length(enemy_formation); row++) {
    for (var col = 0; col < array_length(enemy_formation[row]); col++) {
        var t = enemy_formation[row][col];
        if (t != "") {
            spawn_piece(col, row, t, "enemy");
        }
    }
}

// No selection or highlights at start
global.selected_piece   = noone;
global.valid_move_tiles = [];
global.valid_shield_tiles = []; 

// Bass stun cooldown (in rounds)
stun_cooldown = 0;

// Bass stun camera shake 
shake_timer = 0; 
shake_duration = room_speed * 0.15; 
shake_magnitude = 4; // max shake offset in pixels

// Moved this bar
global.moved_this_bar = false;

// Base, unshaken offsets:
base_grid_offset_x = (window_get_width()  - global.grid_cols * global.tile_size) / 2;
base_grid_offset_y = (window_get_height() - global.grid_rows * global.tile_size) / 2;

// after calculating your original centering:
base_grid_offset_x = (window_get_width()  - global.grid_cols * global.tile_size) / 2;
base_grid_offset_y = (window_get_height() - global.grid_rows * global.tile_size) / 2;
global.grid_offset_x = base_grid_offset_x;
global.grid_offset_y = base_grid_offset_y;

// shake state
shake_timer     = 0;
shake_duration  = room_speed * 0.15;
shake_magnitude = 4;
shake_off_x     = 0;
shake_off_y     = 0;
