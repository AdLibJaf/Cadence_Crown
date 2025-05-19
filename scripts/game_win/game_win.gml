// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function game_win(winner){
	if (winner == "player") {
		show_message("You've captured the enemy Conductor, you win!");
	} else {
		show_message("Your Conductor has fallen, you lose.")}
}