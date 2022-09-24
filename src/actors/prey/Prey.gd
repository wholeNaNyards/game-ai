class_name Prey
extends Vehicle

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var state_machine : StateMachine = $StateMachine
onready var predator_detector_raycasts : Node2D = $PredatorDetectorRaycasts

# Avoidance Steering
var predator : MovingEntity

func _ready() -> void:
	state_machine.set_global_state(PreyStateGlobal.new())
	change_state("FOLLOWING")

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
	if predator:
		var can_see_predator = false
		for raycast in predator_detector_raycasts.get_children():
			raycast = raycast as RayCast2D
			raycast.look_at(predator.global_position)
			raycast.force_raycast_update()
			if raycast.is_colliding():
				if raycast.get_collider().is_in_group("predator"):
					can_see_predator = true
					break

		if not can_see_predator:
			predator = null

	state_machine.physics_process(delta)

func _on_PredatorDetector_body_entered(body: MovingEntity) -> void:
	if body:
		predator = body
		steering_manager.evade_on(predator)

func _on_PredatorDetector_body_exited(body: MovingEntity) -> void:
	if body:
		predator = null
		steering_manager.off("evade")

func get_animation_player() -> AnimationPlayer:
	return animation_player

func get_animated_sprite() -> AnimatedSprite:
	return animated_sprite

func get_fsm() -> StateMachine:
	return state_machine
