class_name PredatorStateChasing
extends State

var previous_modulate : Color
var animated_sprite : AnimatedSprite

func enter(predator) -> void:
	predator.get_fsm().update_label("CHASING")
	
	animated_sprite = predator.get_animated_sprite()
	animated_sprite.play("walking")
	previous_modulate = animated_sprite.modulate
	animated_sprite.modulate = Color.red

func exit(_predator) -> void:
	animated_sprite.modulate = previous_modulate
	queue_free()

func execute_unhandled_input(_predator, _event: InputEvent) -> void:
	pass

func execute_process(_predator, _delta: float) -> void:
	pass

func execute_physics_process(_predator, _delta: float) -> void:
	pass
