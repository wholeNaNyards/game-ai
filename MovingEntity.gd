class_name MovingEntity
extends KinematicBody2D

export (int, 10, 10000) var max_speed = 800
export (float, 0.1, 20.0) var mass = 5.0
export var max_force : Vector2 = Vector2(800, 800)

var velocity = Vector2()

func get_velocity() -> Vector2:
	return velocity

func get_max_speed() -> int:
	return max_speed

func get_position() -> Vector2:
	return position

func get_mass() -> float:
	return mass

func get_max_force() -> Vector2:
	return max_force
