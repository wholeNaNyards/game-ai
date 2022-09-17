extends AI

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var state_machine : StateMachine = $StateMachine

# Avoidance Steering
var predator : AI

# Leader Following
export var initial_leader := NodePath()
var leader: MovingEntity
export var offset : float = 200

func _ready() -> void:
	if initial_leader:
		leader = get_node(initial_leader)
	state_machine.set_global_state(PreyStateGlobal.new())
	change_state("WANDERING")

func change_state(new_state: String) -> void:
	if new_state == "WANDERING":
		state_machine.change_state(PreyStateWandering.new())
	elif new_state == "FLEEING":
		state_machine.change_state(PreyStateFleeing.new())
	elif new_state == "FOLLOWING":
		state_machine.change_state(PreyStateFollowing.new())
	elif new_state == "SEEKING":
		state_machine.change_state(PreyStateSeeking.new())

func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)

func _on_PredatorDetector_body_entered(body: AI) -> void:
	if body:
		predator = body

func _on_PredatorDetector_body_exited(body: AI) -> void:
	if body:
		predator = null

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite

func get_fsm() -> StateMachine:
	return state_machine
