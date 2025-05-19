/// obj_bass_shock – Step Event
life -= 1;
/// fade from 1 → 0
alpha = clamp(life / (room_speed * 0.25), 0, 1);
if (life <= 0) {
    instance_destroy();
}
