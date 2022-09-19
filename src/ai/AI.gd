class_name AI
extends MovingEntity

onready var steering_manager = $SteeringManager as SteeringManager

# Wander Behavior
export (int, 1, 1000) var wander_distance = 1
export (int, 1, 1000) var wander_radius = 250
export (float, 0.1, 100) var wander_angle_change: float = 2

# Obstacle Avoidance
export var obstacle_avoidance = true
export var max_avoid_force : float = 500
onready var raycasts : Node2D = $Raycasts

# Wall Avoidance
export var wall_avoidance = true
export var wall_avoidance_length = 150.0
onready var wall_avoidance_rays : Node2D = $WallAvoidanceRays

func _ready() -> void:
	for raycast in wall_avoidance_rays.get_children():
		raycast = raycast as RayCast2D
		raycast.cast_to.x = wall_avoidance_length

func _physics_process(delta: float) -> void:
	if obstacle_avoidance:
		steering_manager.obstacle_avoidance(raycasts, max_avoid_force)

	if wall_avoidance:
		steering_manager.wall_avoidance(wall_avoidance_rays)

	var new_velocity = steering_manager.calculate(delta)
	velocity = move_and_slide(new_velocity)
