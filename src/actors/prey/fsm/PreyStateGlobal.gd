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

	if prey.wander:
		prey.change_state("WANDERING")

	if prey.path_points:
		prey.steering_manager.path_follow(prey.path_points)
		prey.change_state("FOLLOWING")

	if prey.leader:
		prey.steering_manager.offset_pursuit(prey.leader, prey.offset, "prey")
		prey.change_state("FOLLOWING")

	if prey.predator != null:
		prey.steering_manager.evade(prey.predator)
		prey.change_state("FLEEING")
