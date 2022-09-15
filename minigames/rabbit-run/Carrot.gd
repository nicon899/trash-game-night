extends KinematicBody2D

var screen_size
var linear_velocity
var direction

func new_direction():
	direction = rotation + PI / 2
	direction += rand_range(-PI / 4, PI / 4)
	rotation = direction
	var velocity = Vector2(rand_range(100.0, 300.0), 0.0)
	linear_velocity = velocity.rotated(direction)
	
func _ready():
	screen_size = get_viewport_rect().size
	randomize()
	new_direction()
	
func _physics_process(delta):
	if rand_range(0, 100) > 99:
		new_direction()
	
	move_and_slide(linear_velocity, Vector2.UP)
	if position.x < 0:
		position.x = screen_size.x
	elif position.x > screen_size.x:
		position.x = 0
	
	if position.y < 10:
		position.y = 10
		new_direction()
