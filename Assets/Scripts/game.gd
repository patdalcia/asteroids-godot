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
@onready var info_ui = $UI/StartGameScreen

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

# Colour palette data: each palette is an Array of Color
var palettes := [
	[ Color8(255,  99,  71),  Color8(255,160,122),  Color8(240,128,128),  Color8(178, 34, 34) ],
	[ Color8(65,105,225),   Color8(100,149,237), Color8(135,206,250), Color8(70,130,180) ],
	[ Color8(124,252,0),    Color8(144,238,144), Color8(0,250,154),   Color8(34,139,34) ],
	[ Color8(255,215,0),    Color8(240,230,140), Color8(255,255,102), Color8(218,165,32) ],
	[ Color8(219,112,147),  Color8(255,105,180), Color8(255,182,193), Color8(199,21,133) ],
	[ Color8(72, 61,139),   Color8(123,104,238), Color8(147,112,219), Color8(138,43,226) ],
	[ Color8(255,140,0),    Color8(255,165,0),   Color8(255,215,0),   Color8(184,134,11) ],
	[ Color8(0,206,209),    Color8(64,224,208),  Color8(72,209,204),  Color8(0,191,255) ],
	[ Color8(210,180,140),  Color8(244,164,96),  Color8(222,184,135), Color8(205,133,63) ],
	[ Color8(135,206,235),  Color8(176,224,230), Color8(173,216,230), Color8(0,191,255) ],
	[ Color8(199,199,199),  Color8(169,169,169), Color8(128,128,128), Color8(105,105,105) ],
	[ Color8(255,240,245),  Color8(255,228,225), Color8(255,182,193), Color8(255,192,203) ],
	[ Color8(152,251,152),  Color8(143,188,143), Color8(60,179,113),  Color8(46,139,87) ],
	[ Color8(255,228,181),  Color8(255,222,173), Color8(255,239,213), Color8(250,250,210) ],
	[ Color8(70,70,70),     Color8(90,90,90),    Color8(110,110,110), Color8(130,130,130) ]
]

var current_palette : Array = []
var background_color : Color = Color.BLACK

#func _input(event: InputEvent) -> void:
	#if start_ui.visible && event.is_action_pressed("accept"):
		#start_ui._on_start_game_button_pressed()

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
	if info_ui.has_signal("accept_info_pressed"):
		info_ui.connect("accept_info_pressed", Callable(self, "start_pressed"))

	player.set_process_input(false)
	player.set_process(false)
	player.set_physics_process(false)
	start_ui.visible = true

func start_level():
	active_asteroids = 0
	
	player.set_process_input(true)
	player.set_process(true)
	player.set_physics_process(true)
	
	player.global_position = player_spawn_pos.global_position
	for child in lasers.get_children():
		child.queue_free()

	score_multiplier = base_score_multiplier + (level - 1) * multiplier_increment_per_level

	if level == 1:
		# all asteroids black on first level
		current_palette = [ Color.BLACK ]
	else:
		current_palette = palettes[randi() % palettes.size()]
	background_color = _choose_background_for_palette(current_palette)
	# NEED TO IMPLEMENT BACKGROUND COLOR CHANGES
	# get_viewport().set_clear_color(background_color)

	var count = asteroid_count + (level - 1) * asteroid_increment_per_level
	init_asteroids(count)

func _on_player_laser_shot(laser):
	lasers.add_child(laser)

func _process(_delta: float):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_asteroid_exploded(pos: Vector2, sides: int, points: int, parent_vel: Vector2, parent_color: Color):
	var points_awarded = int(points * score_multiplier)
	score += points_awarded
	active_asteroids -= 1

	var use_color : Color = parent_color
	if use_color == Color.BLACK and level != 1:
		use_color = current_palette[randi() % current_palette.size()]

	if sides > 3:
		var perp = Vector2(-parent_vel.y, parent_vel.x).normalized()
		_spawn_asteroid_with_velocity(pos, sides - 1, perp, use_color)
		_spawn_asteroid_with_velocity(pos, sides - 1, -perp, use_color)

	if active_asteroids <= 0:
		await get_tree().create_timer(2.0).timeout
		level_cleared()

func init_asteroids(count: int):
	var screen_size = get_viewport().get_visible_rect().size
	var safe_radius = screen_size.y / 2
	for i in range(count):
		var pos = get_random_spawn_position(screen_size, player_spawn_pos.global_position, safe_radius)
		_spawn_asteroid(pos, 6, current_palette[randi() % current_palette.size()])

func _spawn_asteroid(pos: Vector2, sides: int, color: Color):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.sides = sides
	a.modulate = color
	a.connect("exploded", Callable(self, "_on_asteroid_exploded"))
	asteroids.add_child(a)
	active_asteroids += 1

func _spawn_asteroid_with_velocity(pos: Vector2, sides: int, vel: Vector2, color: Color):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.sides = sides
	a.velocity = vel
	a.modulate = color
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
	var btn = level_success_screen.get_node("VBoxContainer/NextLevelButton")
	var cb = Callable(self, "_on_next_level_button_pressed")
	if not btn.pressed.is_connected(cb):
		btn.pressed.connect(cb)

func _on_next_level_button_pressed() -> void:
	level_success_screen.visible = false
	level += 1
	start_level()

func _on_start_game_button_pressed() -> void:
	start_ui.visible = false
	await get_tree().create_timer(0.1).timeout
	info_ui.visible = true
	

func start_pressed() -> void:
	info_ui.visible = false
	hud.visible = true
	player.visible = true
	level = 1
	start_level()

func _on_submit_button_pressed(player_name) -> void:
	print("NAME: " + player_name + " SCORE: " + str(score))
	var password = "1234"
	var res = await Talo.player_auth.register(player_name, password)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
				print("Username is already taken")
				res = await Talo.player_auth.login(player_name, password)
				match res:
					Talo.player_auth.LoginResult.FAILED:
						match Talo.player_auth.last_error.get_code():
							TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
								print("Username or password is incorrect")
							_:
								print(Talo.player_auth.last_error.get_string())
					Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
						print("Verification required")
					Talo.player_auth.LoginResult.OK:
						pass
					_:
						print(Talo.player_auth.last_error.get_string())
	if res == OK:
		res = await Talo.leaderboards.add_entry("asteroids-leaderboard", score)
		game_over_screen._set_info_text("Adding Score to Leaderboard, one second...")
		print("You scored %s points" % [score,  " Your highscore was updated!" if res.updated else ""])
	start_ui.submit_score(player_name, score)
	get_tree().reload_current_scene()

func _choose_background_for_palette(pal: Array) -> Color:
	var total = 0.0
	for c in pal:
		total += (c.r + c.g + c.b) / 3.0
	var avg = total / pal.size()
	if avg > 0.6:
		return Color(0.05, 0.05, 0.1, 1.0)
	else:
		return Color(0.9, 0.9, 0.95, 1.0)
