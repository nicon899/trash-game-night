extends Control
signal add_shot
signal remove_shot
var playerId

func set_info(id, player):
	playerId = id
	$InfoContainer/PlayerName.text = player.name
	$InfoContainer/PlayerScore.text = str(player.highscore)
	$PlayerTimer.visible = player.timer > 0
	$PlayerTimer.text = str(player.timer, "seconds left")
	
func _on_AddShot_pressed():
	emit_signal("add_shot", playerId)

func _on_RemoveShot_pressed():
	emit_signal("remove_shot", playerId)

func set_given_shots_label(givenShots):
	var shots = 0
	for j in range(givenShots.size()):
		if givenShots[j] == playerId:
			shots += 1
	$InfoContainer/ShotsControl/Shots.text = str(shots)
