extends "res://minigames/BaseGame.gd"

var score
var carrot_collectible = true

func _ready():
	randomize()
	score = 0
	
func _on_PlayerRabbit_hit():
	$GameOverRect.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	$GameOverRect.visible = false
	$PlayerRabbit.position = Vector2(256, 256)
	$Snake.position = Vector2(0, 850)
	score = 0
	emit_signal("update_score", score)

func _on_PlayerRabbit_collect():
	if carrot_collectible:
		carrot_collectible = false
		$Carrot.visible = false
		$Carrot.position = Vector2(800, 100)
		score += 1
		emit_signal("update_score", score)
	yield(get_tree().create_timer(0.1), "timeout")
	$Carrot.visible = true
	carrot_collectible = true
