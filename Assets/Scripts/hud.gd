extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)
		
var ui_life_scene = preload("res://Scenes/ui_life.tscn")

@onready var lives = $Lives

@onready var level = $Level:
	set(value):
		level.text = "LEVEL: " + str(value)

func init_lives(amount):
		for ul in lives.get_children():
			ul.queue_free()
		for i in amount:
			var ul = ui_life_scene.instantiate()
			lives.add_child(ul)
