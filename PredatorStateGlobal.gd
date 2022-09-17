class_name PredatorStateGlobal
extends State

func enter(_predator) -> void:
	pass

func exit(_predator) -> void:
	pass

func execute_unhandled_input(_predator, _event: InputEvent) -> void:
	pass

func execute_process(_predator, _delta: float) -> void:
	pass

func execute_physics_process(predator, _delta: float) -> void:
	if predator.velocity.x >= 0:
		predator.animated_sprite.flip_h = false
	else:
		predator.animated_sprite.flip_h = true

	if predator.resting:
		predator.stamina += 2
		if predator.stamina >=predator.max_stamina:
			predator.resting = false
		else:
			predator.change_state("RESTING")

	if predator.prey != null and !predator.resting:
		predator.steering_manager.pursuit(predator.prey)
		predator.stamina -= 2
		predator.change_state("CHASING")

		if predator.stamina <= 0:
			predator.prey = null
			predator.resting = true
	else:
		predator.steering_manager.wander(predator.wander_distance, predator.wander_radius, predator.wander_angle_change)
		if not predator.resting:
			predator.change_state("HUNTING")
