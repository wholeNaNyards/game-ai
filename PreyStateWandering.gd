class_name PreyStateWandering
extends State

func enter(prey) -> void:
	prey.get_fsm().update_label("WANDERING")
	prey.get_animated_sprite().play("walking")

func exit(_prey) -> void:
	pass

func execute_unhandled_input(_prey, _event: InputEvent) -> void:
	pass

func execute_process(_prey, _delta: float) -> void:
	pass

func execute_physics_process(_prey, _delta: float) -> void:
	pass