extends AI

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var starting_position = position

# Avoidance Steering
var predator : AI

# Leader Following
export var initial_leader := NodePath()
var leader: MovingEntity
export var offset : float = 200

# Obstacle Avoidance
export var avoid_collisions = true
var max_avoid_force : float = 500
onready var raycasts : Node2D = $Raycasts

func _ready() -> void:
	animated_sprite.play("walking")
	if initial_leader:
		leader = get_node(initial_leader)

func _physics_process(_delta: float) -> void:
#	animated_sprite.rotation = velocity.angle()

	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

	if avoid_collisions:
		steering_manager.obstacle_avoidance(raycasts, max_avoid_force)

	if leader:
		steering_manager.offset_pursuit(leader, offset)
#	elif position.distance_to(starting_position) > 500:
#		steering_manager.seek(starting_position)
	elif predator != null:
		steering_manager.evade(predator)
	elif Input.is_action_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		steering_manager.seek(mouse_pos)
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
