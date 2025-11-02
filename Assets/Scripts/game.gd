extends Node2D

@export var asteroid_count := 5
@export var asteroid_increment_per_level := 2
@export var base_score_multiplier := 1.0
@export var multiplier_increment_per_level := 0.25

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var level_success_screen = $UI/LevelSuccessScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var level_ui = $UI/LevelSuccessScreen
@onready var start_ui = $UI/Leaderboard


var asteroid_scene = preload("res://Scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)

var level: int:
	set(value):
		level = value
		hud.level = level

var score_multiplier := base_score_multiplier
var active_asteroids: int = 0

func _ready():
	randomize()
	game_over_screen.visible = false
	level_success_screen.visible = false
	
	hud.visible = false
	player.visible = false

	score = 0
	lives = 3
	level = 1

	player.connect("laser_shot", Callable(self, "_on_player_laser_shot"))
	player.connect("died", Callable(self, "_on_player_died"))

	if level_ui.has_signal("next_level_pressed"):
		level_ui.connect("next_level_pressed", Callable(self, "_on_next_level_button_pressed"))
	if start_ui.has_signal("start_game_pressed"):
		start_ui.connect("start_game_pressed", Callable(self, "_on_start_game_button_pressed"))
	if game_over_screen.has_signal("submit_button_pressed"):
		game_over_screen.connect("submit_button_pressed", Callable(self, "_on_submit_button_pressed"))
	start_ui.visible = true
	#start_level()

func start_level():
	active_asteroids = 0
	player.global_position = player_spawn_pos.global_position
	for child in lasers.get_children():
		child.queue_free()

	score_multiplier = base_score_multiplier + (level - 1) * multiplier_increment_per_level

	var count = asteroid_count + (level - 1) * asteroid_increment_per_level
	init_asteroids(count)

func _on_player_laser_shot(laser):
	lasers.add_child(laser)

func _process(_delta: float):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_asteroid_exploded(pos: Vector2, sides: int, points: int, parent_vel: Vector2):
	var points_awarded = int(points * score_multiplier)
	score += points_awarded

	active_asteroids -= 1

	# spawn two children if sides > 3
	if sides > 3:
		# compute perpendicular vector to parent velocity
		var perp = Vector2(-parent_vel.y, parent_vel.x).normalized()
		# one child goes perp, the other goes opposite perp
		spawn_asteroid_with_velocity(pos, sides - 1, perp)
		spawn_asteroid_with_velocity(pos, sides - 1, -perp)

	if active_asteroids <= 0:
		await get_tree().create_timer(2.0).timeout
		level_cleared()

func init_asteroids(count: int):
	var screen_size = get_viewport().get_visible_rect().size
	var safe_radius = screen_size.y / 2
	for i in range(count):
		var pos = get_random_spawn_position(screen_size, player_spawn_pos.global_position, safe_radius)
		spawn_asteroid(pos, 6)

func spawn_asteroid(pos: Vector2, sides: int):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.sides = sides
	a.connect("exploded", Callable(self, "_on_asteroid_exploded"))
	asteroids.add_child(a)
	active_asteroids += 1

func spawn_asteroid_with_velocity(pos: Vector2, sides: int, vel: Vector2):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.sides = sides
	# set its velocity
	a.velocity = vel
	a.connect("exploded", Callable(self, "_on_asteroid_exploded"))
	asteroids.add_child(a)
	active_asteroids += 1

func get_random_spawn_position(screen_size: Vector2, safe_center: Vector2, safe_radius: float):
	while true:
		var pos = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		if pos.distance_to(safe_center) > safe_radius:
			return pos

func _on_player_died():
	lives -= 1
	if lives <= 0:
		await get_tree().create_timer(2.0).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1.0).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)

func level_cleared() -> void:
	level_success_screen.visible = true
	var btn = level_success_screen.get_node("NextLevelButton")
	var cb = Callable(self, "_on_next_level_button_pressed")
	if not btn.pressed.is_connected(cb):
		btn.pressed.connect(cb)

func _on_next_level_button_pressed() -> void:
	level_success_screen.visible = false
	level += 1
	start_level()
	
func _on_start_game_button_pressed() -> void:
	start_ui.visible = false
	
	hud.visible = true
	player.visible = true
	
	level = 1
	start_level()

func _on_submit_button_pressed(player_name) -> void:
	SilentWolf.Scores.save_score(player_name, score)
	print("NAME: " + player_name + " SCORE: " + str(score))
