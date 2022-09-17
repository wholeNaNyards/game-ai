extends AI

onready var animated_sprite = $AnimatedSprite
onready var state_machine : StateMachine = $StateMachine

export (int, 1, 5000) var max_stamina = 2000
onready var stamina : int = max_stamina
var resting : bool = false
var prey : AI

func _ready() -> void:
	state_machine.set_global_state(PredatorStateGlobal.new())
	change_state("HUNTING")

func change_state(new_state: String) -> void:
	if new_state == "HUNTING":
		state_machine.change_state(PredatorStateHunting.new())
	elif new_state == "CHASING":
		state_machine.change_state(PredatorStateChasing.new())
	elif new_state == "RESTING":
		state_machine.change_state(PredatorStateResting.new())

func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

func _on_PreyDetector_body_entered(body: AI) -> void:
	if body:
		prey = body

func _on_PreyDetector_body_exited(body: AI) -> void:
	if body:
		prey = null

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite

func get_fsm() -> StateMachine:
	return state_machine
