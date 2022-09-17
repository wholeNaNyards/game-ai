class_name Player
extends MovingEntity

export (float, 0, 1.0) var friction = 0.5
export (float, 0, 1.0) var acceleration = 0.5

onready var state_machine = $StateMachine
onready var animated_sprite = $AnimatedSprite
var direction : Vector2

func _ready() -> void:
	direction = Vector2()
	state_machine.set_global_state(StateGlobal.new())
	change_state("STANDING")

func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

func change_state(new_state: String) -> void:
	if new_state == "WALKING":
		state_machine.change_state(StateWalking.new())
	elif new_state == "STANDING":
		state_machine.change_state(StateStanding.new())
	elif new_state == "IDLE":
		state_machine.change_state(StateIdle.new())

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite

func get_fsm() -> StateMachine:
	return state_machine
