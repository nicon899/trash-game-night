extends Node
# minigames
export(PackedScene) var rabbit_run
# constants
var SERVER_PORT	= 2207
var MAX_PLAYERS = 32
var MINIGAME_TIME = 10
# variables
var game
var player_info = {}

func _ready():
	player_info[0] = { name = Variables.player_name, highscore = 0, shots = 0, timer = 0, game = null }
	update_player_list()
	$LobbyContainer/StartButton.visible = Variables.is_host

	if Variables.is_host:
		var server_peer = NetworkedMultiplayerENet.new()
		server_peer.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = server_peer
	else:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client(Variables.server_ip, SERVER_PORT)
		get_tree().network_peer = peer

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# NETWORK/MULTIPLAYER
func _player_connected(id):
	rpc_id(id, "update_player_status", player_info[0])
	print(str("INFO: _player_connected: ", id))

func _player_disconnected(id):
	# Erase player from info.
	player_info.erase(id)
	print(str("INFO: _player_disconnected: ", id))

func _connected_ok():
	# Only called on clients, not server. Will go unused; not useful here.
	print("INFO: _connected_ok")

func _server_disconnected():
	# Server kicked us; show error and abort.
	print("INFO: _server_disconnected")

func _connected_fail():
	# Could not even connect to server; abort.
	print("INFO: _connected_fail")

remote func update_player_status(info):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	update_player_list()
	print(info)
	
remote func select_game(gameId):
	start_game(gameId)

func send_score():
	for id in player_info:
		if id != 0:
			rpc_id(id, "update_player_status", player_info[0])

# GAME CONTROLLING
func start_game(gameId):
	player_info[0].game = gameId
	player_info[0].highscore = 0
	player_info[0].timer = MINIGAME_TIME
	send_score()
	
	$LobbyContainer.visible = false
	
	game = rabbit_run.instance()
	game.connect("update_score", self, "_on_BaseGame_update_score")
	
	add_child(game)
	$Timer.start(MINIGAME_TIME)

func _on_Timer_timeout():
	game.queue_free()
	load_lobby()

func load_lobby():
	update_player_list()
	$LobbyContainer.visible = true
 
# UI
func _on_BaseGame_update_score(score):
	if score > player_info[0].highscore:
		player_info[0].highscore = score
		player_info[0].timer = $Timer.time_left
		send_score()
	$HUD.update_score(player_info[0].highscore, score)

func player_info_text_builder(player):
	var points
	if player.game != null and player.game == player_info[0].game:
		points = player.highscore
	else:
		points = "-"
	return str(player.name, " | ", points, " | ", player.shots)

func update_player_list():
	$LobbyContainer/PlayerList.clear()
	for i in player_info:
		var pl = player_info[i]
		var pl_info = player_info_text_builder(pl)
		$LobbyContainer/PlayerList.add_item(pl_info)
	$LobbyContainer/PlayerList.update()

func _on_StartButton_pressed():
	print("Button press")
	var gameId = Variables.MINIGAMES.RABBIT_RUN
	for id in player_info:
		if id != 0:
			print(str("select_game: ", id))
			rpc_id(id, "select_game", gameId)
	start_game(gameId)
