extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# server
func _on_Button_pressed():
	Variables.is_host = true
	start_game()

# client
func _on_Button2_pressed():
	Variables.is_host = false
	Variables.server_ip = "93.204.4.57"
	start_game()

func start_game():
	get_tree().change_scene("res://main/GameNetworkController.tscn")
