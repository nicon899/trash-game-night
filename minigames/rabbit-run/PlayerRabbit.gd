extends KinematicBody2D

var RABBIT_XPOS = 256
var MAX_JUMPS = 3

var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var device_type
var is_mobile
var velocity = Vector2(0,0)
var gravity = 2000
var jumps = 0

func _init():
	var os_name = OS.get_name()
	if os_name == "Android" or os_name == "iOS":
		device_type = "mobile_native"
		is_mobile = true
	elif OS.get_name() == "HTML5" and JavaScript.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)", true):
		device_type = "mobile_web"
		is_mobile = true
	else:
		device_type = "desktop"
		is_mobile = false
	
func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	#gravitiy
	velocity.y = velocity.y + gravity * (delta)
	
	#jumping
	var jump = false
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jumps = MAX_JUMPS
		if jumps > 0:
			velocity.y = -1000
			jumps -= 1
	
	# horizontal moving
	if is_mobile:
		var acc
		if device_type == "mobile_native":
			acc = Input.get_accelerometer()
		elif device_type == "mobile_web":
			acc = Acc.get_accelerometer()
		if OS.get_name() == "Android":
			if acc.x > 0:
				velocity.x += 1
			else:
				velocity.x -= 1
		else:
			if acc.x > 0:
				velocity.x -= 1
			else:
				velocity.x += 1
	else:
		var mouse_pos = get_viewport().get_mouse_position()
		if mouse_pos.x > (position.x + RABBIT_XPOS):
			velocity.x = 25000
		else:
			velocity.x = -25000
	velocity.x = velocity.x * delta
	
	$AnimatedSprite.flip_h = false if velocity.x > 0 else true
	move_and_slide(velocity, Vector2.UP)

	#set position
#	position += velocity * delta
#	if position.x < 0:
#		position.x = screen_size.x
#	elif position.x > screen_size.x:
#		position.x = 0
#	if position.y < 0:
#		position.y = screen_size.y
#	elif position.y > screen_size.y:
#		position.y = 0

#func _on_Player_body_entered(body):
#	hide() # Player disappears after being hit.
#	emit_signal("hit")
#	# Must be deferred as we can't change physics properties on a physics callback.
#	$CollisionShape2D.set_deferred("disabled", true)

#func start(pos):
#	position = pos
#	show()
#	$CollisionShape2D.disabled = false
