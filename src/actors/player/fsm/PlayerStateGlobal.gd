class_name PlayerStateGlobal
extends State

func enter(_player) -> void:
	pass

func exit(_player) -> void:
	pass

func execute_unhandled_input(_player, _event: InputEvent) -> void:
	pass

func execute_process(_player, _delta: float) -> void:
	pass

func execute_physics_process(player, _delta: float) -> void:
	player.direction = Vector2()

	if Input.is_action_pressed("move_right"):
		player.direction += Vector2.RIGHT
	if Input.is_action_pressed("move_left"):
		player.direction += Vector2.LEFT
	if Input.is_action_pressed("move_up"):
		player.direction += Vector2.UP
	if Input.is_action_pressed("move_down"):
		player.direction += Vector2.DOWN

	if player.direction.x > 0:
		player.get_animated_sprite().flip_h = true
	elif player.direction.x < 0:
		player.get_animated_sprite().flip_h = false

	if player.direction == Vector2.ZERO:
		player.velocity = player.velocity.linear_interpolate(Vector2.ZERO, player.friction)
		player.velocity = player.move_and_slide(player.velocity)
	else:
		player.velocity = player.velocity.linear_interpolate(player.direction.normalized() * player.max_speed, player.acceleration)
		player.velocity = player.move_and_slide(player.velocity)
