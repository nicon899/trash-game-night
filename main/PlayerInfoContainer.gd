extends Control

export(PackedScene) var player_info_item 

var items = []

func player_info_text_builder(player, game):
	var points
	if player.game != null and player.game == game:
		points = player.highscore
	else:
		points = "-"
	return str(player.name, " | ", points, " | ", player.shots)
	
func create_player_info_items(player_info):
	for i in player_info:
		var pl = player_info[i]
		var pl_info = player_info_text_builder(pl, player_info[0].game)
		
		var item_row = HBoxContainer.new()
		var pl_item = player_info_item.instance()
		pl_item.set_info(pl)
		item_row.add_child(pl_item)
		add_child(item_row)

func update_player(player):
	get_tree().call_group("player-info-item", "queue_free")
	create_player_info_items(player)
