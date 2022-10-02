extends Node

export(PackedScene) var rabbit_run

var game
var highscore

func _ready():
	start_game()

func start_game():
	game = rabbit_run.instance()
	game.connect("update_score", self, "_on_BaseGame_update_score")
	add_child(game)
	highscore = 0
	$Timer.start()
	
func _on_Timer_timeout():
	game.queue_free()

func _on_BaseGame_update_score(score):
	if score > highscore:
		highscore = score
	$HUD.update_score(highscore, score)
