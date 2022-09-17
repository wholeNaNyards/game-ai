class_name AI
extends MovingEntity

onready var steering_manager = $SteeringManager

# Wander Behavior
export (int, 1, 1000) var wander_distance = 1
export (int, 1, 1000) var wander_radius = 250
export (float, 0.1, 100) var wander_angle_change: float = 2

func _physics_process(delta: float) -> void:
	var new_velocity = steering_manager.calculate(delta)
	velocity = move_and_slide(new_velocity)
