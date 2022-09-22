class_name AI
extends MovingEntity

onready var steering_manager = $SteeringManager as SteeringManager

# Wander Behavior
export var wander = true
export (float, 1, 1000) var wander_distance = 1.0
export (float, 1, 1000) var wander_radius = 250.0
export (float, 0.1, 100) var wander_angle_change: float = 2.0

# Obstacle Avoidance
export var obstacle_avoidance = true
export var min_box_length : float = 250.0
onready var obstacle_avoidance_rays : Node2D = $ObstacleAvoidanceRays

# Wall Avoidance
export var wall_avoidance = true
export var wall_avoidance_length = 100.0
onready var wall_avoidance_rays : Node2D = $WallAvoidanceRays

func _ready() -> void:
	if obstacle_avoidance:
		steering_manager.obstacle_avoidance_on(obstacle_avoidance_rays, min_box_length)

	if wall_avoidance:
		for raycast in wall_avoidance_rays.get_children():
			raycast = raycast as RayCast2D
			raycast.cast_to.x = wall_avoidance_length
		steering_manager.wall_avoidance_on(wall_avoidance_rays)

	if wander:
		steering_manager.wander_on(wander_distance, wander_radius, wander_angle_change)

func _physics_process(delta: float) -> void:
	var steering_force: Vector2 = steering_manager.calculate()
	var acceleration: Vector2 = steering_force / mass
	var new_velocity: Vector2 = velocity + (acceleration * delta)
	new_velocity = truncate(new_velocity, max_speed)
	
	velocity = move_and_slide(new_velocity)

func truncate(vector: Vector2, max_value: float) -> Vector2:
	if vector.length() > max_value:
		vector = vector.normalized() * max_value
	return vector
