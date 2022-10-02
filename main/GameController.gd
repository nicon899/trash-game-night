extends Node

export(PackedScene) var rabbit_run

signal game_over

var game
var highscore

func _ready():
	pass
	
func start_game():
	game = rabbit_run.instance()
	game.connect("update_score", self, "_on_BaseGame_update_score")
	add_child(game)
	highscore = 0
	$Timer.start()
			
func _on_Timer_timeout():
	game.queue_free()
	emit_signal("game_over")
	
func _on_BaseGame_update_score(score):
	if score > highscore:
		highscore = score
	$HUD.update_score(highscore, score)
