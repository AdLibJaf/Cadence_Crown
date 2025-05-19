// A) Update current bar at the very start of each bar
if (global.new_bar_event) {
    current_bar = global.bar_in_phase;
}

// B) On every new beat, trigger bounce on beat 1 or beat 3
if (global.new_beat_event) {
    var beat_in_bar = ((global.beat_count - global.phase_start_beat - 1)
                       mod global.BEATS_PER_BAR) + 1;
    if (beat_in_bar == 1 || beat_in_bar == 3 || beat_in_bar == 5 || beat_in_bar == 7) {
        bounce_timer = bounce_duration;
    }
}

// C) Count down the bounce timer
if (bounce_timer > 0) {
    bounce_timer -= 1;
}