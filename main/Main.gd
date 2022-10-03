extends Node

var characters = 'abcdefghijklmnopqrstuvwxyz'

func _ready():
	randomize()
	$InputName.text = generate_word(characters, 12)

func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

# server
func _on_Button_pressed():
	Variables.is_host = true
	start_game()

# client
func _on_Button2_pressed():
	Variables.is_host = false
	Variables.server_ip = "192.168.181.128"
	start_game()

func start_game():
	Variables.player_name = $InputName.text
	if Variables.is_host:
		Variables.player_name = str("SERVER", Variables.player_name.substr(0, 6))
	get_tree().change_scene("res://main/GameController.tscn")
