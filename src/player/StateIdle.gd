class_name StateIdle
extends State

export var idle_timeout: int = 5
var current_time: int
var timer: Timer

func enter(player) -> void:
	current_time = idle_timeout
	player.get_fsm().update_label("IDLE (%d)" % current_time)
	player.get_animated_sprite().play("idle")
	
	timer = create_timer(player)
	player.get_fsm().add_child(timer)
	timer.start()

func create_timer(player) -> Timer:
	var new_timer = Timer.new()
	new_timer.connect("timeout", self, "_on_Timer_timeout", [player])
	return new_timer

func _on_Timer_timeout(player) -> void:
	current_time -= 1

	player.get_fsm().update_label("IDLE (%d)" % current_time)
	if current_time <= 0:
		player.change_state("STANDING")

func exit(_player) -> void:
	timer.queue_free()

func execute_unhandled_input(_player, _event: InputEvent) -> void:
	pass

func execute_process(_player, _delta: float) -> void:
	pass

func execute_physics_process(player, _delta: float) -> void:
	if player.direction != Vector2.ZERO:
		player.change_state("WALKING")
