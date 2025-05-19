
function play_anim(_inst, _animSprite, _animSpeed){
	with(_inst) {
		// cache current visuals 
		backup_sprite = sprite_index; 
		backup_image_speed = image_speed; 
		
		// switch to need anim 
		sprite_index = _animSprite; 
		image_index = 0; 
		image_speed = _animSpeed;
	}
}