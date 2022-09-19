class_name Prey
extends AI

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var state_machine : StateMachine = $StateMachine
onready var predator_detector_raycasts : Node2D = $PredatorDetectorRaycasts

# Avoidance Steering
var predator : AI

# Leader Following
export var initial_leader := NodePath()
var leader: MovingEntity
export var offset : float = 10

# Path Following
export var path_follow := NodePath()
var path_points: PoolVector2Array

# Interpose
export var initial_interpose_target_1 := NodePath()
var interpose_target_1: MovingEntity
export var initial_interpose_target_2 := NodePath()
var interpose_target_2: MovingEntity

func _ready() -> void:
	if initial_leader:
		leader = get_node(initial_leader)

	if path_follow:
		path_points = get_node(path_follow).curve.get_baked_points()
	
	if initial_interpose_target_1 and initial_interpose_target_2:
		interpose_target_1 = get_node(initial_interpose_target_1)
		interpose_target_2 = get_node(initial_interpose_target_2)

	state_machine.set_global_state(PreyStateGlobal.new())
	change_state("FOLLOWING")
	add_to_group(group)

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
