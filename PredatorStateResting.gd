class_name PredatorStateResting
extends State

func enter(predator) -> void:
	predator.get_fsm().update_label("RESTING")
	predator.get_animated_sprite().play("walking")

func exit(_predator) -> void:
	pass

func execute_unhandled_input(_predator, _event: InputEvent) -> void:
	pass

func execute_process(_predator, _delta: float) -> void:
	pass

func execute_physics_process(_predator, _delta: float) -> void:
	pass
