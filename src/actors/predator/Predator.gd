class_name Predator
extends Vehicle

onready var animated_sprite = $AnimatedSprite
onready var state_machine : StateMachine = $StateMachine
onready var prey_detector_raycasts : Node2D = $PreyDetectorRaycasts

export (int, 1, 5000) var max_stamina = 2000
onready var stamina : int = max_stamina
var resting : bool = false
var prey : MovingEntity

func _ready() -> void:
	state_machine.set_global_state(PredatorStateGlobal.new())
	change_state("HUNTING")
	add_to_group("predator")

func change_state(new_state: String) -> void:
	if new_state == "HUNTING":
		state_machine.change_state(PredatorStateHunting.new())
	elif new_state == "CHASING":
		state_machine.change_state(PredatorStateChasing.new())
	elif new_state == "RESTING":
		state_machine.change_state(PredatorStateResting.new())

func _physics_process(delta: float) -> void:
	if prey:
		var can_see_prey = false
		for raycast in prey_detector_raycasts.get_children():
			raycast = raycast as RayCast2D
			raycast.look_at(prey.global_position)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				if raycast.get_collider().is_in_group("prey"):
					can_see_prey = true
					break

		if not can_see_prey:
			prey = null

	state_machine.physics_process(delta)

func _on_PreyDetector_body_entered(body: MovingEntity) -> void:
	if body:
		prey = body

func _on_PreyDetector_body_exited(body: MovingEntity) -> void:
	if body:
		prey = null
		steering_manager.off("pursuit")

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite

func get_fsm() -> StateMachine:
	return state_machine
