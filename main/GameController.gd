extends Node
# SCENES
export(PackedScene) var drink_scene
# SCENES/minigames
export(PackedScene) var rabbit_run
# constants
var SERVER_PORT	= 2207
var MAX_PLAYERS = 32
var MINIGAME_TIME = 5
# variables
var game
var drink_scene_instance
var player_info = {}
var network_unique_id

func _ready():
	player_info[0] = { name = Variables.player_name, highscore = 0, totalShots = 0, givenShots = null, timer = MINIGAME_TIME, game = null }
	update_player_list()
	set_start_btn_visibility(true)

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
	network_unique_id = get_tree().get_network_unique_id()

# NETWORK/MULTIPLAYER
func _player_connected(id):
	rpc_id(id, "update_player_status", player_info[0])
	print(str("INFO: _player_connected: ", id))

func _player_disconnected(id):
	# Erase player from info.
	player_info.erase(id)
	update_player_list()
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
	
remote func submit_player_shots(info):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	load_drink_screen()
	
remote func select_game(gameId):
	start_game(gameId)

func send_score():
	for id in player_info:
		if id != 0:
			rpc_id(id, "update_player_status", player_info[0])
			
func send_shots():
	for id in player_info:
		if id != 0:
			rpc_id(id, "submit_player_shots", player_info[0])
	load_drink_screen()
			
func load_drink_screen():
	for i in player_info:
		if player_info[i].givenShots == null:
			return
	drink_scene_instance = drink_scene.instance()
	drink_scene_instance.init(network_unique_id, player_info)
	drink_scene_instance.connect("submit_drinking", self, "on_submit_drinking")
	add_child(drink_scene_instance)

# GAME CONTROLLING
func start_game(gameId):
	player_info[0].game = gameId
	player_info[0].highscore = 0
	player_info[0].timer = MINIGAME_TIME
	player_info[0].givenShots = null
	send_score()
	
	$LobbyContainer.visible = false
	$HUD.visible = true
	$HUD.update_score(player_info[0].highscore, 0)
	
	game = rabbit_run.instance()
	game.connect("update_score", self, "_on_BaseGame_update_score")
	add_child(game)
	$MinigameTimer.start(MINIGAME_TIME)
	$StatusUpdateTimer.start()

func _on_Timer_timeout():
	game.queue_free()
	$StatusUpdateTimer.stop()
	load_lobby()

func load_lobby():
	player_info[0].timer = 0
	send_score()
	update_player_list()
	$HUD.visible = false
	$LobbyContainer.visible = true
	
func on_submit_drinking(drunkShots):
	player_info[0].totalShots += drunkShots
	send_score()
	update_player_list()
	drink_scene_instance.queue_free()
	set_start_btn_visibility(true)
 
# UI
func _on_BaseGame_update_score(score):
	if score > player_info[0].highscore:
		player_info[0].highscore = score
		player_info[0].timer = $MinigameTimer.time_left
		send_score()
	$HUD.update_score(player_info[0].highscore, score)

func update_player_list():
	var res = $LobbyContainer/PlayerInfoContainer.update_player(player_info)
	if res:
		show_shots_screen()

func _on_StartButton_pressed():
	var gameId = Variables.MINIGAMES.RABBIT_RUN
	for id in player_info:
		if id != 0:
			print(str("select_game: ", id))
			rpc_id(id, "select_game", gameId)
	start_game(gameId)

func show_shots_screen():
	$LobbyContainer/StartButton.visible = false
	
func _on_PlayerInfoContainer_submit_shots(givenShots):
	player_info[0].givenShots = givenShots
	send_shots()
	
func set_start_btn_visibility(visible):
	$LobbyContainer/StartButton.visible = visible and Variables.is_host
