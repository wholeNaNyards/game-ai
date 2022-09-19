class_name MovingEntity
extends KinematicBody2D

export (int, 10, 10000) var max_speed = 250
export (int, 10, 10000) var speed = 500
export (float, 0.1, 20.0) var mass = 1.0
# Controls how hard it is to turn the vehicle
export (float, 10.0, 100000) var max_force = 50000.0
export (String) var group

var velocity = Vector2()

func get_velocity() -> Vector2:
	return velocity

func get_speed() -> int:
	return speed

func get_max_speed() -> int:
	return max_speed

func get_position() -> Vector2:
	return global_position

func get_mass() -> float:
	return mass

func get_max_force() -> float:
	return max_force
