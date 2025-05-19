// 1) On every new beat, reset bounce and record which beat
if (global.new_beat_event) {
    // Which beat of the bar? 1..beats_per_bar
    current_beat = ((global.beat_count - global.phase_start_beat - 1)
                    mod beats_per_bar) + 1;

    // start a little bounce
    bounce_timer = bounce_duration;
}
// 2) Count down the bounce timer
if (bounce_timer > 0) bounce_timer--;
