class_name SteeringManager
extends Node2D

# DEBUG Options
#export (bool) var enable_debug = true
#var desired_velocity : Vector2
#var steering : Vector2
#var behavior : String
#var wander_circle_center : Vector2
#var target_pos : Vector2
#var start_pos : Vector2
#
#func _draw() -> void:
#	if (enable_debug):
#		draw_line(Vector2.ZERO, velocity, Color.green, 3.0)
#		if behavior == "wander":
#			draw_arc(wander_circle_center, wander_radius, 0, 2 * PI, 100, Color.red, 3.0)
#			draw_line(Vector2(wander_distance, -32), target_pos, Color.green, 3.0)
#		elif behavior == "seek" or behavior == "flee" or behavior == "arrive":
#			draw_line(Vector2.ZERO, desired_velocity, Color.gray, 3.0)
#			draw_line(velocity, steering, Color.blue, 3.0)
#		elif behavior == "return":
#			draw_line(Vector2.ZERO, start_pos, Color.black, 3.0)

onready var host: MovingEntity = owner
var acceleration = Vector2()
var flocking_distance: float = 1000.0

var path_follow_index = 0

# Properties
var steering_force: Vector2

# Steering Behaviors
var wall_avoidance: bool = false
var wall_avoidance_weight: float = 10.0
var wall_avoidance_rays: Node2D

var obstacle_avoidance: bool = false
var obstacle_avoidance_weight: float = 10.0
var obstacle_avoidance_rays: Node2D
var obstacle_avoidance_force: float

var evade: bool = false
var evade_weight: float = 0.01
var evade_pursuer: MovingEntity

var flee: bool = false
var flee_weight: float = 1.0
var flee_position: Vector2

var separation: bool = false
var separation_weight: float = 1.0
var separation_group: String = ""
var separation_force: float = 5000.0

var alignment: bool = false
var alignment_weight: float = 1.0
var alignment_group: String = ""

var cohesion: bool = false
var cohesion_weight: float = 2.0
var cohesion_group: String = ""

var seek: bool = false
var seek_weight: float = 1.0
var seek_position: Vector2
var seek_slowing_radius: float

var wander: bool = false
var wander_weight: float = 1.0
var wander_distance: int
var wander_radius: int
var wander_angle_change: float
var wander_angle : float = 0.0

var pursuit: bool = false
var pursuit_weight: float = 1.0
var pursuit_evader: MovingEntity

var offset_pursuit: bool = false
var offset_pursuit_weight: float = 1.0
var offset_pursuit_leader: MovingEntity
var offset_pursuit_offset: Vector2

var interpose: bool = false
var interpose_weight: float = 1.0
var interpose_target_1: MovingEntity
var interpose_target_2: MovingEntity

var follow_path: bool = false

# Steering Behavior Weights
var weight_follow_path: float = 0.05

# Steering Behavior Properties

func reset() -> void:
	acceleration = Vector2()
	wander_angle = 0.0

func calculate(delta: float) -> Vector2:
	var force = Vector2()

	if wall_avoidance:
		force = _do_wall_avoidance(wall_avoidance_rays) * wall_avoidance_weight

		if not accumulate_force(force):
			return steering_force

	if obstacle_avoidance:
		force = _do_obstacle_avoidance(obstacle_avoidance_rays, obstacle_avoidance_force) * obstacle_avoidance_weight

		if not accumulate_force(force):
			return steering_force

	if evade:
		force = _do_evade(evade_pursuer) * evade_weight

		if not accumulate_force(force):
			return steering_force

	if flee:
		force = _do_flee(flee_position) * flee_weight

		if not accumulate_force(force):
			return steering_force

	if separation:
		force = _do_separation(separation_group, separation_force) * separation_weight

		if not accumulate_force(force):
			return steering_force

	if alignment:
		force = _do_alignment(alignment_group) * alignment_weight

		if not accumulate_force(force):
			return steering_force

	if cohesion:
		force = _do_cohesion(cohesion_group) * cohesion_weight

		if not accumulate_force(force):
			return steering_force

	if seek:
		force = _do_seek(seek_position, seek_slowing_radius) * seek_weight

		if not accumulate_force(force):
			return steering_force

	if wander:
		force = _do_wander(wander_distance, wander_radius, wander_angle_change) * wander_weight

		if not accumulate_force(force):
			return steering_force

	if pursuit:
		force = _do_pursuit(pursuit_evader) * pursuit_weight

		if not accumulate_force(force):
			return steering_force

	if offset_pursuit:
		force = _do_offset_pursuit(offset_pursuit_leader, offset_pursuit_offset) * offset_pursuit_weight

		if not accumulate_force(force):
			return steering_force

	if interpose:
		force = _do_interpose(interpose_target_1, interpose_target_2) * interpose_weight

		if not accumulate_force(force):
			return steering_force

	if wall_avoidance:
		force = _do_wall_avoidance(wall_avoidance_rays) * wall_avoidance_weight

		if not accumulate_force(force):
			return steering_force

	return steering_force

func accumulate_force(force: Vector2) -> bool:
	return false

#	var new_velocity = host.get_velocity() + (acceleration * delta)
#	new_velocity = limit(new_velocity, host.get_max_speed())
#	acceleration = Vector2()
#	return new_velocity

func apply_force(steering_force : Vector2) -> void:
	# Limit to within max force
	steering_force = limit(steering_force, host.get_max_force())
	var new_acceleration = steering_force / host.get_mass()
	acceleration += new_acceleration

func seek_on(target_position : Vector2, slowing_radius : float = 250.0) -> void:
	seek = true
	seek_position = target_position
	seek_slowing_radius = slowing_radius

func flee_on(target_position : Vector2) -> void:
	flee = true
	flee_position = target_position

func wander_on(distance : int, radius: int, angle_change : float) -> void:
	wander = true
	wander_distance = distance
	wander_radius = radius
	wander_angle_change = angle_change

func pursuit_on(evader: MovingEntity) -> void:
	pursuit = true
	pursuit_evader = evader

func evade_on(pursuer: MovingEntity) -> void:
	evade = true
	evade_pursuer = pursuer

func path_follow_on(path_points: PoolVector2Array) -> void:
	_do_path_follow(path_points)

func obstacle_avoidance_on(raycasts: Node2D, max_avoid_force: float) -> void:
	obstacle_avoidance = true
	obstacle_avoidance_rays = raycasts
	obstacle_avoidance_force = max_avoid_force

func wall_avoidance_on(raycasts: Node2D) -> void:
	wall_avoidance = true
	wall_avoidance_rays = raycasts

func alignment_on(group: String) -> void:
	alignment = true
	alignment_group = group

func cohesion_on(group: String) -> void:
	cohesion = true
	cohesion_group = group

func separation_on(group: String, force: float) -> void:
	separation = true
	separation_group = group
	separation_force = force

func interpose_on(target_1: MovingEntity, target_2: MovingEntity) -> void:
	interpose = true
	interpose_target_1 = target_1
	interpose_target_2 = target_2

func leader_following_on(leader: MovingEntity, offset: Vector2) -> void:
	offset_pursuit = true
	offset_pursuit_leader = leader
	offset_pursuit_offset = offset

func _do_seek(target_position : Vector2, slowing_radius : float = 250.0) -> Vector2:
	var desired_direction = target_position - host.get_position()
	var distance = desired_direction.length()
	var desired_velocity: Vector2

	# Start slowing down if we're withing the slowdown area
	if distance < slowing_radius:
		desired_velocity = desired_direction.normalized() * host.get_speed() * (distance / slowing_radius)
	else:
		desired_velocity = desired_direction.normalized() * host.get_speed()

	return desired_velocity - host.get_velocity()

func _do_flee(target_position: Vector2) -> Vector2:
	var desired_direction = host.get_position() - target_position
	var desired_velocity = desired_direction.normalized() * host.get_speed()

	return desired_velocity - host.get_velocity()

func _do_wander(wander_distance : int, wander_radius: int, wander_angle_change : float) -> Vector2:
	var host_velocity = host.get_velocity()
		# Calculate the circle center
	var wander_circle_center = Vector2(host_velocity.x, host_velocity.y)
	wander_circle_center = wander_circle_center.normalized() * wander_distance

	# Calculate the displacement force
	var displacement = Vector2.UP * wander_radius

	# Randomly change the vector direction by making it change its current angle
	var length = displacement.length()
	displacement = Vector2(cos(wander_angle) * length, sin(wander_angle) * length)
	
	# Change wander_angle just a bit, so it won't have the same value in the next frame
	wander_angle += randf() * wander_angle_change - wander_angle_change * 0.5

	return wander_circle_center + displacement

func _do_pursuit(evader: MovingEntity) -> Vector2:
	var evader_position = evader.get_position()
	var desired_position = evader_position - host.get_position()
	var updates_ahead = desired_position.length() / evader.get_max_speed()
	# Calculate where evader will be updates_ahead ahead
	var future_position = evader_position + (evader.get_velocity() * updates_ahead)

	return _do_seek(future_position, 250.0)

func _do_evade(pursuer: MovingEntity) -> Vector2:
	var pursuer_position = pursuer.get_position()
	var distance = pursuer_position - host.get_position()
	var updates_ahead = distance.length() / pursuer.get_max_speed()
	# Calculate where pursuer will be updates_ahead ahead
	var future_position = pursuer_position + (pursuer.get_velocity() * updates_ahead)

	return _do_flee(future_position)

func _do_path_follow(path_points: PoolVector2Array) -> void:
	var target_position = path_points[path_follow_index]
	if host.get_position().distance_to(target_position) < 50:
		path_follow_index = wrapi(path_follow_index + 1, 0, path_points.size())
		target_position = path_points[path_follow_index]

	_do_seek(target_position, 0.0)

func _do_obstacle_avoidance(raycasts: Node2D, max_avoid_force: float) -> Vector2:
	var force = Vector2()
	var host_velocity = host.get_velocity()
	raycasts.rotation = host_velocity.angle()

	var length = host_velocity.length()
	for raycast in raycasts.get_children():
		raycast = raycast as RayCast2D
		raycast.cast_to.x = length
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var obstacle : PhysicsBody2D = raycast.get_collider()
			var avoid_direction = host.get_position() + host_velocity - obstacle.global_position
			force = avoid_direction.normalized() * max_avoid_force
			break

	return force

func _do_wall_avoidance(raycasts: Node2D) -> Vector2:
	var force = Vector2()
	var host_velocity = host.get_velocity()
	raycasts.rotation = host_velocity.angle()

	var closest_intersecting_ray: RayCast2D

	for raycast in raycasts.get_children():
		raycast = raycast as RayCast2D
		raycast.force_raycast_update()

		if raycast.is_colliding():
			if closest_intersecting_ray == null:
				closest_intersecting_ray = raycast
			else:
				# Check if this Ray is closer than the current closest ray
				var host_position = host.get_position()
				var new_ray_distance = host_position.distance_squared_to(raycast.get_collision_point())
				var old_ray_distance = host_position.distance_squared_to(closest_intersecting_ray.get_collision_point())
				if new_ray_distance < old_ray_distance:
					closest_intersecting_ray = raycast

	if closest_intersecting_ray != null:
		# Calculate how far the Ray has gone through wall
		var ray_position: Vector2 = closest_intersecting_ray.to_global(closest_intersecting_ray.cast_to)
		var collision_point = closest_intersecting_ray.get_collision_point()

		# Create a force of overshoot magnitude in the direction of wall normal
		var overshoot: Vector2 = ray_position - collision_point
		force = closest_intersecting_ray.get_collision_normal() * overshoot.length()

	return force

func _do_offset_pursuit(leader: MovingEntity, offset: Vector2) -> Vector2:
	# Calculate offset in global coordinates
	var heading_offset: Vector2 = leader.get_heading() * offset.y
	var side_offset: Vector2 = leader.get_side() * offset.x * -1
	var global_offset: Vector2 = heading_offset + side_offset + leader.get_position()

	return _do_seek(global_offset, 50.0)

func _do_alignment(group : String) -> Vector2:
	var force = Vector2()
	var neighbor_count: float = 0.0

	for entity in  get_tree().get_nodes_in_group(group):
		var entity_position: Vector2 = entity.get_position()
		var host_position: Vector2 = host.get_position()
		if entity != host and entity_position.distance_to(host_position) <= flocking_distance:
			force += entity.get_heading() * entity.get_velocity().length()
			neighbor_count += 1

	if neighbor_count != 0:
		force /= float(neighbor_count)
		force -= host.get_heading() * host.get_velocity().length()

	return force

func _do_cohesion(group : String) -> Vector2:
	var center_of_mass = Vector2()
	var neighbor_count: float = 0.0

	for entity in  get_tree().get_nodes_in_group(group):
		var entity_position: Vector2 = entity.get_position()
		var host_position: Vector2 = host.get_position()
		if entity != host and entity_position.distance_to(host_position) <= flocking_distance:
			center_of_mass += entity_position
			neighbor_count += 1

	if neighbor_count != 0:
		center_of_mass /= float(neighbor_count)
		return _do_seek(center_of_mass, 0.0)
	else:
		return center_of_mass

func _do_separation(group : String, separation_force: float) -> Vector2:
	var force = Vector2()

	for entity in  get_tree().get_nodes_in_group(group):
		var entity_position: Vector2 = entity.get_position()
		var host_position: Vector2 = host.get_position()
		if entity != host and entity_position.distance_to(host_position) <= flocking_distance:
			var to_entity: Vector2 = host_position - entity_position
			force += (to_entity.normalized() / to_entity.length()) * separation_force

	return force

func _do_interpose(target_1: MovingEntity, target_2: MovingEntity) -> Vector2:
	var target_1_position = target_1.get_position()
	var target_2_position = target_2.get_position()
	
	var mid_point: Vector2 = (target_1_position + target_2_position) / 2.0
	var time_to_reach_mid_point = host.get_position().distance_to(mid_point) / host.get_max_speed()

	var target_1_future_position: Vector2 = target_1_position + target_1.get_velocity() * time_to_reach_mid_point
	var target_2_future_position: Vector2 = target_2_position + target_2.get_velocity() * time_to_reach_mid_point

	var future_mid_point: Vector2 = (target_1_future_position + target_2_future_position) / 2.0

	return _do_seek(future_mid_point, 0.0)

func limit(vector: Vector2, max_value: float) -> Vector2:
	var length = vector.length()
	if length > max_value:
		vector = (vector / length) * max_value

	return vector
