class_name MovingEntity
extends KinematicBody2D

var velocity: Vector2
var heading: Vector2
var side: Vector2
export (float, 0.1, 20.0) var mass = 1.0
export (float, 1.0, 1000.0) var max_speed = 500.0
export (float, 1.0, 1000.0) var max_force = 2.0 * 200.0

export (String) var group

func _ready() -> void:
	velocity = Vector2()
	heading = Vector2()
	side = Vector2()

	if group:
		add_to_group(group)

func _physics_process(_delta: float) -> void:
	if velocity.length_squared() > 0.00000001:
		heading = velocity.normalized()
		side = heading.tangent()

func get_velocity() -> Vector2:
	return velocity

func get_heading() -> Vector2:
	return heading

func get_side() -> Vector2:
	return side

func get_mass() -> float:
	return mass

func get_max_speed() -> float:
	return max_speed

func get_max_force() -> float:
	return max_force

func get_speed() -> float:
	return velocity.length()

func get_position() -> Vector2:
	return global_position
