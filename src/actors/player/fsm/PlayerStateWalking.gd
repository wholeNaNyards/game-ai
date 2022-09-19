class_name PlayerStateWalking
extends State

func enter(player) -> void:
	player.get_fsm().update_label("WALKING")
	player.get_animated_sprite().play("walking")

func exit(_player) -> void:
	queue_free()

func execute_unhandled_input(_player, _event: InputEvent) -> void:
	pass

func execute_process(_player, _delta: float) -> void:
	pass

func execute_physics_process(player, _delta: float) -> void:
	if player.direction == Vector2.ZERO:
		player.change_state("STANDING")
