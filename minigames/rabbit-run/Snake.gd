extends KinematicBody2D

var RABBIT_XPOS = 256
var MAX_JUMPS = 3
var SPEED = 125

var screen_size # Size of the game window.

var velocity = Vector2(0,0)
var gravity = 10
var jumps = 0
var direction = 1

func _ready():
	screen_size = get_viewport_rect().size
	randomize()
	
func _physics_process(delta):
	velocity.y = velocity.y + gravity
	if rand_range(0, 100) > 95:
		if is_on_floor():
			jumps = MAX_JUMPS
		if jumps > 0:
			velocity.y = -500
			jumps -= 1
	
	if rand_range(0, 100) > 99:
		direction = direction * -1
	velocity.x = direction * SPEED
	$Sprite.flip_h = true if velocity.x > 0 else false
	
	move_and_slide(velocity, Vector2.UP)
	if position.x < 0:
		position.x = screen_size.x
	elif position.x > screen_size.x:
		position.x = 0
