extends Control

signal submit_drinking

var shots_to_drink = 0

func init(player_id, player_info):
	var shots = 0
	for i in player_info:
		var pl = player_info[i]
		for id in pl.givenShots:
			if id == player_id:
				shots += 1
	shots_to_drink = shots
	$VBoxContainer/Label.text = str(shots_to_drink)
	
func _on_SubmitButton_pressed():
	emit_signal("submit_drinking", shots_to_drink)
