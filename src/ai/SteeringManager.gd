class_name SteeringManager
extends Node2D

onready var host: MovingEntity = owner
var acceleration = Vector2()
var wander_angle : float = 0.0
var separation_radius: float = 150.0
var max_separation = 500.0

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

func reset() -> void:
	acceleration = Vector2()
	wander_angle = 0.0

func calculate(delta: float) -> Vector2:
	var new_velocity = host.get_velocity() + (acceleration * delta)
	new_velocity = limit(new_velocity, host.get_max_speed())
	acceleration = Vector2()
	return new_velocity

func apply_force(steering_force : Vector2) -> void:
	# Limit to within max force
	steering_force = limit(steering_force, host.get_max_force())
	var new_acceleration = steering_force / host.get_mass()
	acceleration += new_acceleration

func seek(target_position : Vector2, slowing_radius : float = 250.0) -> void:
	_do_seek(target_position, slowing_radius)

func flee(target_position : Vector2) -> void:
	_do_flee(target_position)

func wander(wander_distance : int, wander_radius: int, wander_angle_change : float) -> void:
	_do_wander(wander_distance, wander_radius, wander_angle_change)

func pursuit(evader: MovingEntity) -> void:
	_do_pursuit(evader)

func evade(pursuer: MovingEntity) -> void:
	_do_evade(pursuer)

func obstacle_avoidance(raycasts: Node2D, max_avoid_force: float) -> void:
	_do_obstacle_avoidance(raycasts, max_avoid_force)

func separation(group: String) -> void:
	_do_separation(group)

func offset_pursuit(leader: MovingEntity, offset: float, group: String) -> void:
	_do_offset_pursuit(leader, offset, group)

func _do_seek(target_position : Vector2, slowing_radius : float = 250.0):
	var desired_direction = target_position - host.get_position()
	var distance = desired_direction.length()
	var desired_velocity: Vector2

	# Start slowing down if we're withing the slowdown area
	if distance < slowing_radius:
		desired_velocity = desired_direction.normalized() * host.get_speed() * (distance / slowing_radius)
	else:
		desired_velocity = desired_direction.normalized() * host.get_speed()

	apply_force(desired_velocity - host.get_velocity())

func _do_flee(target_position : Vector2):
	var desired_direction = host.get_position() - target_position
	var desired_velocity = desired_direction.normalized() * host.get_speed()

	apply_force(desired_velocity - host.get_velocity())

func _do_wander(wander_distance : int, wander_radius: int, wander_angle_change : float):
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

	apply_force(wander_circle_center + displacement)

func _do_pursuit(evader: MovingEntity):
	var evader_position = evader.get_position()
	var desired_position = evader_position - host.get_position()
	var updates_ahead = desired_position.length() / evader.get_max_speed()
	# Calculate where evader will be updates_ahead ahead
	var future_position = evader_position + (evader.get_velocity() * updates_ahead)

	_do_seek(future_position)

func _do_evade(pursuer: MovingEntity):
	var pursuer_position = pursuer.get_position()
	var distance = pursuer_position - host.get_position()
	var updates_ahead = distance.length() / pursuer.get_max_speed()
	# Calculate where pursuer will be updates_ahead ahead
	var future_position = pursuer_position + (pursuer.get_velocity() * updates_ahead)

	_do_flee(future_position)

func _do_obstacle_avoidance(raycasts: Node2D, max_avoid_force: float):
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
			apply_force(avoid_direction.normalized() * max_avoid_force)

func _do_offset_pursuit(leader: MovingEntity, offset: float, group: String):
	var leader_sight_radius = 50.0

	var tv = leader.get_velocity().normalized() * offset
	var leader_position = leader.get_position()

	var ahead: Vector2 = leader_position + tv
	tv *= -1
	var behind: Vector2 = leader_position + tv

	var host_position = host.get_position()
	var in_leader_way = host_position.distance_to(leader_position) <= leader_sight_radius
	var in_leader_future_way = host_position.distance_to(ahead) <= leader_sight_radius

	if in_leader_way or in_leader_future_way:
		_do_evade(leader)

	_do_seek(behind + leader.get_position())
	_do_separation(group)

func _do_separation(group : String):
	var force: Vector2 = Vector2()
	var neighbor_count: float = 0.0

	for entity in  get_tree().get_nodes_in_group(group):
		var entity_position: Vector2 = entity.global_position
		var host_position: Vector2 = host.get_position()
		if entity != self and entity_position.distance_to(host_position) <= separation_radius:
			force.x += entity_position.x - host_position.x
			force.y += entity_position.y - host_position.y
			neighbor_count += 1

	if neighbor_count != 0:
		force.x /= neighbor_count
		force.y /= neighbor_count
		force *= -1
		return force.normalized() * max_separation

	apply_force(force)

func limit(vector: Vector2, max_value: float) -> Vector2:
	var length = vector.length()
	if length > max_value:
		vector = (vector / length) * max_value

	return vector
