extends Control

@onready var score = $HBoxContainer/Score:
	set(value):
		score.text = str(value)
		
var ui_life_scene = preload("res://Scenes/ui_life.tscn")

@onready var lives = $HBoxContainer/Lives

@onready var level = $HBoxContainer/Level:
	set(value):
		level.text = str(value)


func _ready() -> void:
	_update_min_height()
	# (Optional) If you want to also listen for viewport size changes:
	get_viewport().connect("size_changed", Callable(self, "_update_min_height"))

func _notification(what: int) -> void:
	if what == Control.NOTIFICATION_RESIZED:
		_update_min_height()

func _update_min_height() -> void:
	var screen_h = get_viewport_rect().size.y
	# Set the minimum height to ¼ of screen height:
	custom_minimum_size.y = screen_h * 0.25
	# If you also want to preserve the existing X minimum size:
	# custom_minimum_size = Vector2(custom_minimum_size.x, screen_h * 0.25)


func init_lives(amount):
		for ul in lives.get_children():
			ul.queue_free()
		for i in amount:
			var ul = ui_life_scene.instantiate()
			lives.add_child(ul)
