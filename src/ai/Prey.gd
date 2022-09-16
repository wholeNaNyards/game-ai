extends AI

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var obstacle_detector : Area2D = $ObstacleDetector
onready var sprite_size = animated_sprite.frames.get_frame("walking", 0).get_size() * animated_sprite.scale * .5
onready var shape : Shape2D = $ObstacleDetector/CollisionShape2D.shape

export var initial_leader := NodePath()
var leader: MovingEntity

export var min_box_length : int = 25
var box_length : float

export var offset : Vector2

var predator : AI

onready var starting_position = position

func _ready() -> void:
	animated_sprite.play("walking")
	if initial_leader:
		leader = get_node(initial_leader)

func _physics_process(_delta: float) -> void:
	box_length = min_box_length + abs(((get_velocity() / get_max_speed()) * min_box_length).x)
	shape.extents = Vector2(box_length, sprite_size.y + 10)

	if velocity.x >= 0:
		obstacle_detector.position = Vector2(shape.extents.x + sprite_size.x, -sprite_size.y/2)
		animated_sprite.flip_h = false
	else:
		obstacle_detector.position = Vector2(-shape.extents.x - sprite_size.x, -sprite_size.y/2)
		animated_sprite.flip_h = true

	if leader:
		steering_manager.offset_pursuit(leader, offset)
		return

	if position.distance_to(starting_position) > 1000:
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

func _on_ObstacleDetector_body_entered(body: Node2D) -> void:
	steering_manager.obstacle_avoidance(body, box_length)
