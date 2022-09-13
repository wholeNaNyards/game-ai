class_name AI
extends MovingEntity

export var initial_target := NodePath()
onready var target: MovingEntity = get_node(initial_target)
export var steering_behavior = "wander"

export (int, 1, 1000000) var max_distance = 1000000

onready var animated_sprite = $AnimatedSprite

var starting_pos : Vector2

# Wander Behavior
export (int, 1, 1000) var wander_distance = 1
export (int, 1, 1000) var wander_radius = 250
export (float, 0.1, 100) var wander_angle_change: float = 2

# Arrive Behavior
# When to start slowing down to the target
export (float, 1.0, 500.0) var slowing_radius = 200.0

# DEBUG Options
export (bool) var enable_debug = true
var desired_velocity : Vector2
var steering : Vector2
var behavior : String
var wander_circle_center : Vector2
var target_pos : Vector2
var start_pos : Vector2

func _draw() -> void:
	if (enable_debug):
		draw_line(Vector2.ZERO, velocity, Color.green, 3.0)
		if behavior == "wander":
			draw_arc(wander_circle_center, wander_radius, 0, 2 * PI, 100, Color.red, 3.0)
			draw_line(Vector2(wander_distance, -32), target_pos, Color.green, 3.0)
		elif behavior == "seek" or behavior == "flee" or behavior == "arrive":
			draw_line(Vector2.ZERO, desired_velocity, Color.gray, 3.0)
			draw_line(velocity, steering, Color.blue, 3.0)
		elif behavior == "return":
			draw_line(Vector2.ZERO, start_pos, Color.black, 3.0)

func _ready() -> void:
	animated_sprite.play("walking")
	starting_pos = global_position

func _physics_process(delta: float) -> void:
	update()
	start_pos = Vector2.ZERO
	var steering_force  = Vector2.ZERO
	if Input.is_action_pressed("left_click"):
		behavior = "arrive"
#		steering_force = arrive(get_global_mouse_position())
	elif Input.is_action_pressed("right_click"):
		behavior = "flee"
#		steering_force = flee(get_global_mouse_position())
	elif position.distance_squared_to(starting_pos) > max_distance:
		behavior = "return"
#		start_pos = starting_pos - position
#		steering_force = arrive(starting_pos)
#	elif steering_behavior == "pursuit" or Input.is_action_pressed("pursuit"):
#		steering_force = pursuit(target)
#	elif steering_behavior == "evade":
#		steering_force = evade(target)
	else:
		behavior = "wander"
#		steering_force = wander()

	steering_force = truncate(steering_force, max_force.x)
	var steering_acceleration = steering_force / mass
	velocity = truncate(velocity + (steering_acceleration * delta) , max_speed)

	velocity = move_and_slide(velocity)

	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite
#
#func seek(target_position : Vector2) -> Vector2:
#	desired_velocity = (target_position - position).normalized() * max_speed
#	steering = desired_velocity - velocity
#	return steering

#func flee(target_position : Vector2) -> Vector2:
#	desired_velocity = (position - target_position).normalized() * max_speed
#	steering = desired_velocity - velocity
#	return steering
#
#func arrive(target_position : Vector2) -> Vector2:
#	desired_velocity = target_position - position
#	if desired_velocity.length_squared() < (slowing_radius * slowing_radius):
#		# Inside the slowing area
#		var distance = desired_velocity.length()
#		desired_velocity = desired_velocity.normalized() * max_speed * (distance / slowing_radius)
#	else:
#		# Outside the slowing area
#		desired_velocity = (desired_velocity).normalized() * max_speed
#
#	steering = desired_velocity - velocity
#	return steering

#func wander() -> Vector2:
#	# Calculate the circle center
#	wander_circle_center = Vector2(velocity.x, velocity.y)
#	wander_circle_center = wander_circle_center.normalized() * wander_distance
#
#	# Calculate the displacement force
#	var displacement = Vector2.UP * wander_radius
#
#	# Randomly change the vector direction by making it change its current angle
#	var length = displacement.length()
#	displacement = Vector2(cos(wander_angle) * length, sin(wander_angle) * length)
#
#	# Change wander_angle just a bit, so it won't have the same value in the next frame
#	wander_angle += randf() * wander_angle_change - wander_angle_change * 0.5;
#
#	target_pos = wander_circle_center + displacement
#
#	return target_pos

#func pursuit(evader: MovingEntity) -> Vector2:
#	var distance = evader.position - position
#	var future_frames = distance.length() / evader.max_speed
#	# Calculate where evader will be future_frames ahead
#	var future_position = evader.position + (evader.velocity * future_frames)
#
#	return seek(future_position)

#func evade(pursuer: MovingEntity) -> Vector2:
#	var distance = pursuer.position - position
#	var future_frames = distance.length() / pursuer.max_speed
#	# Calculate where pursuer will be future_frames ahead
#	var future_position = pursuer.position + (pursuer.velocity * future_frames)
#
#	return flee(future_position)

func truncate(vector: Vector2, max_value: float) -> Vector2:
	var max_value_squared = max_value * max_value
	if vector.length_squared() > max_value_squared:
		return vector.normalized() * max_value
	return vector
