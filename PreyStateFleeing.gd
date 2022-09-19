class_name PreyStateFleeing
extends State

var previous_modulate : Color
var animated_sprite : AnimatedSprite

func enter(prey) -> void:
	prey.get_fsm().update_label("FLEEING")
	
	animated_sprite = prey.get_animated_sprite()
	animated_sprite.play("walking")
	previous_modulate = animated_sprite.modulate
	animated_sprite.modulate = Color.green

func exit(_prey) -> void:
	animated_sprite.modulate = previous_modulate
	queue_free()

func execute_unhandled_input(_prey, _event: InputEvent) -> void:
	pass

func execute_process(_prey, _delta: float) -> void:
	pass

func execute_physics_process(_prey, _delta: float) -> void:
	pass
