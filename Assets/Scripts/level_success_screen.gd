extends Control

signal next_level_pressed

func _input(event: InputEvent) -> void:
	# Check for the custom action “start_game”
	if event.is_action_pressed("accept") && visible:
		# We treat it like the button was pressed
		_on_NextLevelButton_pressed()

func _on_NextLevelButton_pressed() -> void:
	emit_signal("next_level_pressed")
