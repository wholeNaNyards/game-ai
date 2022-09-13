class_name SteeringManager
extends Node2D

onready var host: MovingEntity = owner
var steering_force = Vector2()
var wander_angle : float = 0.0

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
	steering_force = Vector2()
	wander_angle = 0.0

func calculate(delta: float) -> Vector2:
	var host_velocity = host.get_velocity()

	steering_force = truncate(steering_force, host.get_max_force())
	var steering_acceleration = steering_force / host.get_mass()
	steering_acceleration *= delta

	return truncate(host_velocity + steering_acceleration, host.get_max_speed())

func seek(target_position : Vector2, slowing_radius : float = 200.0) -> void:
	steering_force += _do_seek(target_position, slowing_radius)

func flee(target_position : Vector2) -> void:
	steering_force += _do_flee(target_position)

func wander(wander_distance : int, wander_radius: int, wander_angle_change : float) -> void:
	steering_force += _do_wander(wander_distance, wander_radius, wander_angle_change)

func pursuit(evader: MovingEntity) -> void:
	steering_force += _do_pursuit(evader)

func evade(pursuer: MovingEntity) -> void:
	steering_force += _do_evade(pursuer)

func _do_seek(target_position : Vector2, slowing_radius : float = 0.0) -> Vector2:
	var desired_velocity = target_position - host.get_position()
	if desired_velocity.length_squared() <= (slowing_radius * slowing_radius):
		# Inside the slowing area
		var distance = desired_velocity.length()
		desired_velocity = desired_velocity.normalized() * host.get_max_speed() * (distance / slowing_radius)
	else:
		# Outside the slowing area
		desired_velocity = desired_velocity.normalized() * host.get_max_speed()

	return desired_velocity - host.get_velocity()

func _do_flee(target_position : Vector2) -> Vector2:
	var desired_velocity = (host.get_position() - target_position).normalized() * host.get_max_speed()
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
	wander_angle += randf() * wander_angle_change - wander_angle_change * 0.5;

	return wander_circle_center + displacement

func _do_pursuit(evader: MovingEntity) -> Vector2:
	var distance = evader.position - host.get_position()
	var future_frames = distance.length() / evader.max_speed
	# Calculate where evader will be future_frames ahead
	var future_position = evader.position + (evader.velocity * future_frames)

	return _do_seek(future_position, 0.0)

func _do_evade(pursuer: MovingEntity) -> Vector2:
	var distance = pursuer.position - host.get_position()
	var future_frames = distance.length() / pursuer.max_speed
	# Calculate where pursuer will be future_frames ahead
	var future_position = pursuer.position + (pursuer.velocity * future_frames)

	return _do_flee(future_position)

func truncate(vector: Vector2, max_value: float) -> Vector2:
	if vector.length_squared() > (max_value * max_value):
		return vector.normalized() * max_value
	return vector
