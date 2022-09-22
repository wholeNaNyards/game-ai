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

	if prey.velocity.x >= 0:
		prey.animated_sprite.flip_h = false
	else:
		prey.animated_sprite.flip_h = true

#	if prey.wander:
#		prey.change_state("WANDERING")
	
	if Input.is_action_pressed("left_click"):
		prey.steering_manager.seek_on(prey.get_global_mouse_position(), 400.0)
	else:
		prey.steering_manager.seek_off()

	if prey.path_points:
		prey.steering_manager.path_follow(prey.path_points)
		prey.change_state("FOLLOWING")

	if prey.leader:
		prey.steering_manager.leader_following(prey.leader, prey.offset)
		prey.change_state("FOLLOWING")

	if prey.interpose_target_1 and prey.interpose_target_2:
		prey.steering_manager.interpose(prey.interpose_target_1, prey.interpose_target_2)
		prey.change_state("SEEKING")

	if prey.predator != null:
		prey.change_state("FLEEING")
