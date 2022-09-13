extends AI

onready var animated_sprite = $AnimatedSprite
var predator : AI

onready var starting_position = position

func _ready() -> void:
	animated_sprite.play("walking")

func _physics_process(_delta: float) -> void:
	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	if position.distance_to(starting_position) > 500:
		steering_manager.seek(starting_position)
		return
			
	if predator != null:
		steering_manager.evade(predator)
	elif Input.is_action_pressed("left_click"):
		steering_manager.seek(get_global_mouse_position())
	else:
		steering_manager.wander(wander_distance, wander_radius, wander_angle_change)

func _on_PredatorDetector_body_entered(body: AI) -> void:
	if body:
		predator = body

func _on_PredatorDetector_body_exited(body: AI) -> void:
	if body:
		predator = null

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite
