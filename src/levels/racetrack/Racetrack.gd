extends Node2D

var rock = preload("res://src/objects/Rock.tscn")

func _init() -> void:
	randomize()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		var new_rock = rock.instance()
		new_rock.position = mouse_pos
		add_child(new_rock)
