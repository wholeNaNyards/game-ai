class_name PreyStateFleeing
extends State

#var previous_modulate : Color
var animation_player : AnimationPlayer

func enter(prey) -> void:
	prey.get_fsm().update_label("FLEEING")
	
	animation_player = prey.get_animation_player()
	animation_player.play("walking")
#	previous_modulate = animation_player.modulate
#	animated_sprite.modulate = Color.green

func exit(_prey) -> void:
#	animated_sprite.modulate = previous_modulate
	queue_free()

func execute_unhandled_input(_prey, _event: InputEvent) -> void:
	pass

func execute_process(_prey, _delta: float) -> void:
	pass

func execute_physics_process(_prey, _delta: float) -> void:
	pass
