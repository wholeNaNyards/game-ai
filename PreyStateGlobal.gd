class_name PreyStateGlobal
extends State

func enter(_prey) -> void:
	pass

func exit(_prey) -> void:
	pass

func execute_unhandled_input(_prey, _event: InputEvent) -> void:
	pass

func execute_process(_prey, _delta: float) -> void:
	pass

func execute_physics_process(prey, _delta: float) -> void:
	#	animated_sprite.rotation = velocity.angle()
	var currently_steering = false

	if prey.velocity.x >= 0:
		prey.animated_sprite.flip_h = false
	else:
		prey.animated_sprite.flip_h = true

	if Input.is_action_pressed("left_click"):
		var mouse_pos = prey.get_global_mouse_position()
		prey.steering_manager.seek(mouse_pos)
		currently_steering = true
		prey.change_state("SEEKING")

	if prey.leader:
		prey.steering_manager.offset_pursuit(prey.leader, prey.offset)
		currently_steering = true
		prey.change_state("FOLLOWING")

	if prey.predator != null:
		prey.steering_manager.evade(prey.predator)
		currently_steering = true
		prey.change_state("FLEEING")

	prey.steering_manager.wander(prey.wander_distance, prey.wander_radius, prey.wander_angle_change)
	if not currently_steering:
		prey.change_state("WANDERING")
