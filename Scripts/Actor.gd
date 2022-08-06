class_name Actor
extends KinematicBody2D

# Both the Player and Enemy inherit this scene as they have shared behaviours
# such as speed and are affected by gravity.


export var speed = Vector2(4.8888, 0.4444)
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL_LEFT = Vector2.LEFT;
const FLOOR_NORMAL_RIGHT = Vector2.RIGHT;
const MAX_HORIZONTAL_VELOCITY = 120;

var _velocity = Vector2.ZERO



# _physics_process is called after the inherited _physics_process function.
# This allows the Player and Enemy scenes to be affected by gravity.
func _physics_process(delta):
	_velocity.y -= 0.1;
	if _velocity.x > MAX_HORIZONTAL_VELOCITY:
		_velocity.x = MAX_HORIZONTAL_VELOCITY
	if _velocity.x < -MAX_HORIZONTAL_VELOCITY:
		_velocity.x = -MAX_HORIZONTAL_VELOCITY
	
