/// obj_perfect_beat – Step Event

// 1) Detect gauge change and trigger flash
if (global.perfect_gauge != prev_gauge) {
    if (global.perfect_gauge > prev_gauge) {
        perfect_flash_type = 1; // frame 1 = perfect flash
    } else {
        perfect_flash_type = 2; // frame 2 = miss flash
    }
    perfect_flash_timer = perfect_flash_duration;
    prev_gauge = global.perfect_gauge;
}

// 2) Countdown the flash timer
if (perfect_flash_timer > 0) {
    perfect_flash_timer--;
}

// 3) pulse on beat
if (global.new_beat_event) {
    perfect_pulse_timer = perfect_pulse_duration;
} else if (perfect_pulse_timer > 0) {
    perfect_pulse_timer--;
}