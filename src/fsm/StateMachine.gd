class_name StateMachine
extends Node2D

export (bool) var show_label = false setget set_show_label

onready var label = $Label

var current_state : State
var previous_state : State
var global_state : State

func _ready() -> void:
	label.visible = show_label

func set_show_label(value : bool):
	show_label = value
	if label:
		label.visible = value

func unhandled_input(event: InputEvent) -> void:
	if global_state:
		global_state.execute_unhandled_input(owner, event)

	current_state.execute_unhandled_input(owner, event)

func process(delta: float) -> void:
	if global_state:
		global_state.execute_process(owner, delta)

	current_state.execute_process(owner, delta)

func physics_process(delta: float) -> void:
	if global_state:
		global_state.execute_physics_process(owner, delta)

	if current_state:
		current_state.execute_physics_process(owner, delta)

func update_label(new_text: String) -> void:
	label.text = new_text
 
func change_state(new_state : State) -> void:
	if current_state:
		current_state.exit(owner)
		previous_state = current_state

	current_state = new_state
	current_state.enter(owner)

func revert_to_previous_state() -> void:
	change_state(previous_state)

func set_global_state(new_state: State) -> void:
	global_state = new_state
