// 0) Detect a phase change and kick off fade‐out
if (global.current_phase != last_phase && fade_state == "none") {
    // Prepare the new text
    switch(global.current_phase) {
        case "planning": next_text = "PLAN";   break;
        case "player":   next_text = "PLAYER TURN";break;
        case "enemy":    next_text = "ENEMY TURN"; break;
    }
    // Start fading out the old text
    fade_state = "fade_out";
    fade_timer = fade_duration;
}

// 1) Drive the fade state machine
if (fade_state == "fade_out") {
    fade_timer -= 1;
    if (fade_timer <= 0) {
        // old text is fully gone → swap in the new
        banner_text = next_text;
        letter_count     = string_length(banner_text);
        letter_hop_timer = array_create(letter_count, 0);
        letter_offset_y  = array_create(letter_count, 0);

        last_phase = global.current_phase;

        // begin fading the new text in
        fade_state = "fade_in";
        fade_timer = 0;
    }
}
else if (fade_state == "fade_in") {
    fade_timer += 1;
    if (fade_timer >= fade_duration) {
        // fully visible, stop fading
        fade_state = "none";
        fade_timer = fade_duration;
    }
}

// (B) On every new beat—any phase—trigger a bounce
if (global.new_beat_event) {
    // start both stars hopping
    star_hop_timer = star_hop_duration;

    // stagger each letter in a left→right wave
    for (var i = 0; i < letter_count; i++) {
        var delay = floor((hop_duration / letter_count) * i);
        letter_hop_timer[i] = hop_duration + delay;
    }
}

// (C) Update star’s offset
if (star_hop_timer > 0) {
    var t = star_hop_timer / star_hop_duration;
    var w = 1 - abs(2*t - 1);
    star_offset_y = -w * star_hop_height;
    star_hop_timer -= 1;
} else {
    star_offset_y = 0;
}

// (D) Update each letter’s offset
for (var i = 0; i < letter_count; i++) {
    if (letter_hop_timer[i] > 0) {
        letter_hop_timer[i] -= 1;
        var t = letter_hop_timer[i] / hop_duration;
        if (t > 1) t = 1;
        var w = 1 - abs(2*t - 1);
        letter_offset_y[i] = -w * hop_height;
    } else {
        letter_offset_y[i] = 0;
    }
}