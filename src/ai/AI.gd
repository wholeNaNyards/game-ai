class_name AI
extends MovingEntity

onready var animated_sprite = $AnimatedSprite
onready var steering_manager = $SteeringManager

# Wander Behavior
export (int, 1, 1000) var wander_distance = 1
export (int, 1, 1000) var wander_radius = 250
export (float, 0.1, 100) var wander_angle_change: float = 2

# Arrive Behavior
export (float, 1.0, 500.0) var slowing_radius = 200.0

func _ready() -> void:
	animated_sprite.play("walking")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		steering_manager.seek(get_global_mouse_position())
	elif Input.is_action_pressed("right_click"):
		steering_manager.flee(get_global_mouse_position())
	else:
		steering_manager.wander(wander_distance, wander_radius, wander_angle_change)

	velocity = steering_manager.calculate(delta)
	velocity = move_and_slide(velocity)

	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite
