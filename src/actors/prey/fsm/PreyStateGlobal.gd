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
#	prey.animated_sprite.rotation = prey.velocity.angle()

	if prey.average_heading.x >= 0:
		if prey.group == "sheep":
			prey.get_animated_sprite().flip_h = true
		else:
			prey.get_animated_sprite().flip_h = false
	else:
		if prey.group == "sheep":
			prey.get_animated_sprite().flip_h = false
		else:
			prey.get_animated_sprite().flip_h = true

	if Input.is_action_pressed("left_click"):
		prey.steering_manager.seek_on(prey.get_global_mouse_position(), 400.0)
	else:
		prey.steering_manager.off("seek")

	if prey.path_follow:
		prey.change_state("FOLLOWING")

	if prey.leader:
		prey.change_state("FOLLOWING")

	if prey.interpose_target_1 and prey.interpose_target_2:
		prey.change_state("SEEKING")

	if prey.predator != null:
		prey.change_state("FLEEING")
