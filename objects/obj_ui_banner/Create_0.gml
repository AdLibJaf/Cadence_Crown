
// Phase tracking
last_phase       = "";
banner_text      = "";        // will be set in Step
letter_count     = 0;

// Hop state arrays (will size up/down when phase changes)
letter_hop_timer = [];
letter_offset_y  = [];

// Letter‐hop tuning
hop_duration     = 12;
hop_height       = 8;

// Star‐hop state & tuning
star_hop_timer    = 0;
star_hop_duration = 8;
star_hop_height   = 6;
star_offset_y     = 0;

// Panel & star spacing
var panel_w      = sprite_get_width(spr_banner);
var star_w       = sprite_get_width(spr_banner_star);
star_offset_x    = (panel_w/2) - (star_w/2) - 4;

/// Fade state
fade_state     = "none";   // "none", "fade_out", "fade_in"
fade_timer     = 0;        // counts up or down
fade_duration  = 12;       // frames for each fade in/out

// Temp storage for the next text
next_text      = "";

// Don’t fade at startup:
last_phase    = global.current_phase;

// Immediately pick the right text & size your arrays:
switch (last_phase) {
    case "planning": banner_text = "PLAN";    break;
    case "player":   banner_text = "PLAYER TURN"; break;
    case "enemy":    banner_text = "ENEMY TURN";  break;
}
letter_count     = string_length(banner_text);
letter_hop_timer = array_create(letter_count, 0);
letter_offset_y  = array_create(letter_count, 0);

// Also mark us fully visible:
fade_state    = "none";
fade_timer    = fade_duration;


