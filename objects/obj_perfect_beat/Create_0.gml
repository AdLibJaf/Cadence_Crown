ui_scale = 2

/// Cache starting gauge value
prev_gauge = global.perfect_gauge;

/// Flash timing
perfect_flash_timer    = 0;    // counts down each Step
perfect_flash_duration = 8;    // how many Steps to flash
/// Which subimage to flash—1=perfect, 2=miss
perfect_flash_frame    = 1;

// pulse 
perfect_pulse_timer     = 0;    // counts down the pulse
perfect_pulse_duration  = 8;    // in Steps
perfect_pulse_strength  = 0.05; // 10% extra size at peak