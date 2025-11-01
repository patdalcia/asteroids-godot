extends Control

signal next_level_pressed

func _on_NextLevelButton_pressed() -> void:
	emit_signal("next_level_pressed")
