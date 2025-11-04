extends Control

signal accept_info_pressed


func _on_start_game_button_pressed() -> void:
	emit_signal("accept_info_pressed")



func _input(event: InputEvent) -> void:
	# Check for the custom action “start_game”
	if event.is_action_pressed("accept") && visible:
		# We treat it like the button was pressed
		_on_start_game_button_pressed()
