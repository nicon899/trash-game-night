extends Node

var SERVER_PORT	= 2207
var MAX_PLAYERS = 32
var player_info = {}

func _ready():
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

func _player_connected(id):
	var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }
	print("player_connected")
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.
	
remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	print(player_info)

	# Call function to update lobby UI here

func _on_GameController_game_over():
	pass # Replace with function body.
