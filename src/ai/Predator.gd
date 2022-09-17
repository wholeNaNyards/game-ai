extends AI

onready var animated_sprite = $AnimatedSprite

export (int, 1, 5000) var max_stamina = 2000
onready var stamina : int = max_stamina
var resting : bool = false
var prey : AI

onready var starting_position = position

# Obstacle Avoidance
export var avoid_collisions = true
var max_avoid_force : float = 500
onready var raycasts : Node2D = $Raycasts

func _ready() -> void:
	animated_sprite.play("walking")

func _physics_process(_delta: float) -> void:
	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

	if avoid_collisions:
		steering_manager.obstacle_avoidance(raycasts, max_avoid_force)

#	if position.distance_to(starting_position) > 1000:
#		steering_manager.seek(starting_position)
#		return

	if resting:
		stamina += 1
		if stamina >= max_stamina:
			resting = false

	if prey != null and !resting:
		steering_manager.pursuit(prey)
		stamina -= 2

		if stamina <= 0:
			prey = null
			resting = true
	else:
		steering_manager.wander(wander_distance, wander_radius, wander_angle_change)

func _on_PreyDetector_body_entered(body: AI) -> void:
	if body:
		prey = body

func _on_PreyDetector_body_exited(body: AI) -> void:
	if body:
		prey = null

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite
