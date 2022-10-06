extends Control

func set_info(player):
	$InfoContainer/PlayerName.text = player.name
	$InfoContainer/PlayerScore.text = str(player.highscore)
	$PlayerTimer.visible = player.timer > 0
	$PlayerTimer.text = str(player.timer)
