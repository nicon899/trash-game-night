extends Control

export(PackedScene) var player_info_item

signal submit_shots

var shotsToGive = 0
var givenShots = []
var pl_items = []

func create_player_info_items(player_info):
	pl_items.clear()
	var fin = show_give_shots_control(player_info)
	for i in player_info:
		if  player_info[0].game != player_info[i].game:
			continue
		var pl = player_info[i]
		
		var item_row = HBoxContainer.new()
		var pl_item = player_info_item.instance()
		pl_item.set_info(i, pl)
		pl_item.connect("add_shot", self, "on_add_shot")
		pl_item.connect("remove_shot", self, "on_remove_shot")
		pl_items.append(pl_item)
		item_row.add_child(pl_item)
		add_child(item_row)
	return fin

func update_shots_to_give_label(visible):
	$ShotControlContainer.visible = visible
	var shotsLeftToGive = shotsToGive - givenShots.size()
	$ShotControlContainer/LabelShotsToGive.text = str("share ", shotsLeftToGive, " shots")
	for i in range(pl_items.size()):
		pl_items[i].set_given_shots_label(givenShots)
	
func on_add_shot(playerId):
	if shotsToGive > givenShots.size():
		givenShots.append(playerId)
		update_shots_to_give_label(true)
		
func on_remove_shot(playerId):
	for i in range(givenShots.size()):
		if givenShots[i] == playerId:
			givenShots.remove(i)
			update_shots_to_give_label(true)
			return
		
func show_give_shots_control(player_info):
	var fin = true
	shotsToGive = 0
	for i in player_info:
		if player_info[0].game == player_info[i].game and player_info[i].timer > 0:
			update_shots_to_give_label(false)
			fin = false
			return fin
		if i == 0 or player_info[0].game != player_info[i].game:
			continue
		if  player_info[0].highscore > player_info[i].highscore:
			shotsToGive += 1
	update_shots_to_give_label(true)
	
	return fin
		
func get_sorted_ids(player_info):
	var sorted_ids = []
	for i in player_info:
		sorted_ids.append({id = i, score = player_info[i].highscore})
	
	var size = sorted_ids.size() - 1
	for i in size:
		var max_i = i
		for j in range(i, size):
			if(sorted_ids[j].highscore > sorted_ids[max_i].highscore):
				max_i = j
		var tmp = sorted_ids[i]
		sorted_ids[i] = sorted_ids[max_i]
		sorted_ids[max_i] = tmp
	return sorted_ids

func update_player(player):
	get_tree().call_group("player-info-item", "queue_free")
	return create_player_info_items(player)


func _on_SubmitShotsButton_pressed():
	update_shots_to_give_label(false)
	emit_signal("submit_shots", givenShots)
