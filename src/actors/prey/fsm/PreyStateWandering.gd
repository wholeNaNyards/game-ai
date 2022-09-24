class_name PreyStateWandering
extends State

func enter(prey) -> void:
	prey.get_fsm().update_label("WANDERING")
	prey.get_animation_player().play("walking")

func exit(_prey) -> void:
	queue_free()

func execute_unhandled_input(_prey, _event: InputEvent) -> void:
	pass

func execute_process(_prey, _delta: float) -> void:
	pass

func execute_physics_process(_prey, _delta: float) -> void:
	pass
