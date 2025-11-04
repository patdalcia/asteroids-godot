extends Control

signal start_game_pressed

var entry_scene = preload("res://Scenes/entry.tscn")

@export var leaderboard_internal_name: String = "asteroids-leaderboard"
@export var include_archived: bool

@onready var leaderboard_name: Label = %LeaderboardName
@onready var entries_container: VBoxContainer = %Entries
@onready var info_label: Label = %InfoLabel

var _entries_error: bool
var _filter: String = "All"
var _filter_idx: int

func _ready() -> void:
	# leaderboard_name.text = leaderboard_name.text.replace("{leaderboard}", leaderboard_internal_name)
	leaderboard_name.text = "Asteroids - made with love by patdalcia <3"
	await _load_entries()
	_set_entry_count()

func _set_entry_count():
	if entries_container.get_child_count() == 0:
		info_label.text = "No entries yet!" if not _entries_error else "Failed loading leaderboard %s. Does it exist?" % leaderboard_internal_name
	else:
		info_label.text = "%s entries" % entries_container.get_child_count()
		if _filter != "All":
			info_label.text += " (%s team)" % _filter

func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance = entry_scene.instantiate()
	entry_instance.set_data(entry)
	entries_container.add_child(entry_instance)

func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	var entries = Talo.leaderboards.get_cached_entries(leaderboard_internal_name)

	for entry in entries:
		entry.position = entries.find(entry)
		_create_entry(entry)

func _load_entries() -> void:
	var page := 0
	var done := false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		options.include_archived = include_archived

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)

		if not is_instance_valid(res):
			_entries_error = true
			return

		var entries := res.entries
		var is_last_page := res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

	_build_entries()

func submit_score(username, score):
	#var password = "1234"
	#var res = await Talo.player_auth.register(username, password)
	#if res != OK:
		#match Talo.player_auth.last_error.get_code():
			#TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
				#info_label.text = "Username is already taken"
				#res = await Talo.players.identify("username", username)
			#_:
				#info_label.text = Talo.player_auth.last_error.get_string()
	##var res := await Talo.leaderboards.add_entry("asteroids-leaderboard", score)
	#print("HERE")
	#if res == OK:
		#
		#res = await Talo.leaderboards.add_entry("asteroids-leaderboard", score)
		#print("You scored %s points" % [score,  " Your highscore was updated!" if res.updated else "ERRK"])
		#assert(is_instance_valid(res))
		#info_label.text = "You scored %s points" % [score,  " Your highscore was updated!" if res.updated else ""]
		#
		_build_entries()

func _input(event: InputEvent) -> void:
	# Check for the custom action “start_game”
	if event.is_action_pressed("accept") && visible:
		# We treat it like the button was pressed
		_on_submit_pressed()

func _on_submit_pressed() -> void:
	
	emit_signal("start_game_pressed")
	
	#await Talo.players.identify("qZ dsazdsewqwsddv ", username.text)
	#var score := RandomNumberGenerator.new().randi_range(0, 100)
	#var team := "Blue" if RandomNumberGenerator.new().randi_range(0, 1) == 0 else "Red"
#
	#var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, score, {team = team})
	#assert(is_instance_valid(res))
	#info_label.text = "You scored %s points for the %s team!%s" % [score, team, " Your highscore was updated!" if res.updated else ""]
#
	#_build_entries()
