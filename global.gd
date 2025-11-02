extends Node

func _ready() -> void:
	
  SilentWolf.configure({
	"api_key": "lIwj8g5EYb54UlqTSQqLs9jAOotg82pI9jL52mpY",
	"game_id": "patdalcia-asteroid-clone",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/MainPage.tscn"
  })
