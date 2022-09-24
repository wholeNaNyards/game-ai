class_name Vehicle
extends MovingEntity

onready var steering_manager = $SteeringManager as SteeringManager

# Wall Avoidance
export var wall_avoidance: bool = false
export var wall_avoidance_length = 100.0
onready var wall_avoidance_rays : Node2D = $WallAvoidanceRays

# Obstacle Avoidance
export var obstacle_avoidance: bool = false
export var obstacle_avoidance_length : float = 150.0
onready var obstacle_avoidance_rays : Node2D = $ObstacleAvoidanceRays

# Separation
export var separation: bool = false

# Alignment
export var alignment: bool = false

# Cohesion
export var cohesion: bool = false

# Wander Behavior
export var wander: bool = false
export (float, 1, 1000) var wander_distance = 1.0
export (float, 1, 1000) var wander_radius = 100.0
export (float, 0.1, 100) var wander_angle_change: float = 2.0

# Offset Pursuit
export var leader := NodePath()
export var offset : Vector2 = Vector2(-10, -10)

# Interpose
export var interpose_target_1 := NodePath()
export var interpose_target_2 := NodePath()

# Path Follow
export var path_follow := NodePath()

func _ready() -> void:
	if obstacle_avoidance:
		steering_manager.obstacle_avoidance_on(obstacle_avoidance_rays, obstacle_avoidance_length)

	if wall_avoidance:
		for raycast in wall_avoidance_rays.get_children():
			raycast = raycast as RayCast2D
			raycast.cast_to.x = wall_avoidance_length
		steering_manager.wall_avoidance_on(wall_avoidance_rays)

	if separation:
		steering_manager.separation_on(group)

	if alignment:
		steering_manager.alignment_on(group)

	if cohesion:
		steering_manager.cohesion_on(group)

	if wander:
		steering_manager.wander_on(wander_distance, wander_radius, wander_angle_change)

	if leader:
		steering_manager.leader_following_on(get_node(leader), offset)

	if interpose_target_1 and interpose_target_2:
		steering_manager.interpose_on(get_node(interpose_target_1), get_node(interpose_target_2))

	if path_follow:
		steering_manager.path_follow_on(get_node(path_follow).curve.get_baked_points())

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
