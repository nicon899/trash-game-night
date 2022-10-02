extends CanvasLayer

func update_score(highscore, score):
	$ScoreLabel.text = str("Best: ", highscore, " Score: ",score)
