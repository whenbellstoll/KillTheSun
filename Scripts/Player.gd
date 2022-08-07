class_name Player
extends Actor


# warning-ignore:unused_signal
signal collect_coin()

const FLOOR_DETECT_DISTANCE = 20.0

export(String) var action_suffix = ""

onready var right_platform_detector = $RightPlatformDetector
onready var left_platform_detector = $LeftPlatformDetector
onready var animation_player = $AnimationPlayer
onready var slap_timer = $SlapAnimation
onready var sprite = $Sprite
onready var audioPlayer = $AudioStreamPlayer
onready var timer = get_node("../PlayerTracker/Time");

onready var slap1 = preload("res://Sound/Slap.mp3")
onready var slap2 = preload("res://Sound/Slap2.mp3")

onready var rng = RandomNumberGenerator.new()
# onready var sound_jump = $Jump

var mississippi = 0

func _ready():
	# Static types are necessary here to avoid warnings.
	var camera: Camera2D = $Camera
	rng.randomize()


# Physics process is a built-in loop in Godot.
# If you define _physics_process on a node, Godot will call it every frame.

# We use separate functions to calculate the direction and velocity to make this one easier to read.
# At a glance, you can see that the physics process loop:
# 1. Calculates the move direction.
# 2. Calculates the move velocity.
# 3. Moves the character.
# 4. Updates the sprite direction.
# 5. Shoots bullets.
# 6. Updates the animation.

# Splitting the physics process logic into functions not only makes it
# easier to read, it help to change or improve the code later on:
# - If you need to change a calculation, you can use Go To -> Function
#   (Ctrl Alt F) to quickly jump to the corresponding function.
# - If you split the character into a state machine or more advanced pattern,
#   you can easily move individual functions.
func _physics_process(_delta):
	# Play jump sound
	# if Input.is_action_just_pressed("jump" + action_suffix) and is_on_floor():
		# sound_jump.play()

	if distance >= END_DISTANCE:
		_velocity = Vector2.ZERO
		mississippi += _delta
		if(mississippi > 3):
			var new_scene = get_tree().change_scene("res://Ending.tscn")
		return

	var direction = get_move_direction()

	# var is_jump_interrupted = Input.is_action_just_released("jump" + action_suffix) and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, false)

	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = right_platform_detector.is_colliding() || left_platform_detector.is_colliding()
	if _velocity.x > 0:
		if right_platform_detector.is_colliding():
			_velocity.x = min(-150, -abs(_velocity.x))
			sprite.flip_v = false
		_velocity = move_and_slide_with_snap(
			_velocity, snap_vector, FLOOR_NORMAL_LEFT, not right_platform_detector.is_colliding(), 4, 0.9, false
		)
	elif _velocity.x < 0:
		if left_platform_detector.is_colliding():
			_velocity.x = max(150, abs(_velocity.x))
			sprite.flip_v = true
		_velocity = move_and_slide_with_snap(
			_velocity, snap_vector, FLOOR_NORMAL_RIGHT, not left_platform_detector.is_colliding(), 4, 0.9, false
		)
	else:
		if right_platform_detector.is_colliding():
			_velocity.x = min(-150, -abs(_velocity.x))
			sprite.flip_v = false
		if left_platform_detector.is_colliding():
			_velocity.x = max(150, abs(_velocity.x))
			sprite.flip_v = true
		_velocity = move_and_slide_with_snap(
			_velocity, snap_vector, FLOOR_NORMAL_RIGHT, not is_on_platform, 4, 0.9, false
		)
		

	# We use the sprite's scale to store Robi’s look direction which allows us to shoot
	# bullets forward.
	# There are many situations like these where you can reuse existing properties instead of
	# creating new variables.
	var is_shooting = false
	if Input.is_action_just_pressed("slap"):
		is_shooting = true;

	var animation = get_new_animation(is_shooting)
	if animation != animation_player.current_animation and slap_timer.is_stopped():
		if is_shooting:
			slap_timer.start()
			var num = rng.randi_range(0, 1)
			if num == 0: audioPlayer.stream = slap1
			else: audioPlayer.stream = slap2
		animation_player.play(animation)


func get_move_direction():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0
	)


# This function calculates a new velocity whenever you need it.
# It allows you to interrupt jumps.
func calculate_move_velocity(
		linear_velocity,
		direction,
		speed,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	velocity.x += speed.x * direction.x;
	return velocity


func get_new_animation(is_shooting = false):
	var animation_new = "Run"
	if is_shooting:
		animation_new = "Slap"
	return animation_new


func _on_slap(area):
	area.queue_free()


func _on_slap_plat(body):
	body.get_owner().queue_free()
	
func _on_hit():
	print(_velocity)
	_velocity *= 0.6
	print(_velocity)
