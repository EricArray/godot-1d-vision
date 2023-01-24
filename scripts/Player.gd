extends KinematicBody2D

export var speed := 100
export var rotation_speed_rads := PI / 2

var initial_position: Vector2
var initial_rotation: float

func _ready():
	initial_position = position
	initial_rotation = rotation

func _physics_process(delta):
	var velocity := Vector2(0, 0)
	if Input.is_action_pressed("move_front"):
		velocity += Vector2(cos(rotation), sin(rotation)) * speed

	if Input.is_action_pressed("move_back"):
		velocity += Vector2(cos(rotation), sin(rotation)) * speed * -1

	if Input.is_action_pressed("move_left"):
		velocity += Vector2(cos(rotation - PI/2), sin(rotation - PI/2)) * speed

	if Input.is_action_pressed("move_right"):
		velocity += Vector2(cos(rotation + PI/2), sin(rotation + PI/2)) * speed

	move_and_slide(velocity)
	
	if Input.is_action_pressed("rotate_left"):
		rotate(-rotation_speed_rads * delta)
		
	if Input.is_action_pressed("rotate_right"):
		rotate(rotation_speed_rads * delta)
