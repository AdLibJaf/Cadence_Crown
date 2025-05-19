
function update_stun_timers(){
	with (obj_piece) {
		if (stun_timer > 0) {
			stun_timer --; 
			if (stun_timer <= 0) {
				is_stunned = false;
			}
		}
	}
}