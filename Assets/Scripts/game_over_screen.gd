extends Control

signal submit_button_pressed(player_name)

@onready var info_label = $VBoxContainer/StatusLabel

var player_name: String = ""

func _set_info_text(new_text):
	info_label.text = new_text
	
func _input(event: InputEvent) -> void:
	# Check for the custom action “start_game”
	if event.is_action_pressed("accept") && visible:
		# We treat it like the button was pressed
		_on_restart_button_pressed()

func _on_restart_button_pressed():
	player_name = $VBoxContainer/LineEdit.text.strip_edges()  # remove leading/trailing whitespace
	# Convert to uppercase for uniformity (optional)
	player_name = player_name.to_upper()

	# Check empty
	if player_name.is_empty():
		print("Please enter your initials.")
		return

	# Check length (exactly 3 letters – change to <=3 if you allow fewer)
	if player_name.length() != 3:
		print("Initials must be exactly 3 letters.")
		return

	# Check only letters A‑Z
	var regex = RegEx.new()
	# pattern: start ^, then 3 characters in A‑Z or a‑z, then end $
	regex.compile("^[A-Za-z]{3}$")
	var match = regex.search(player_name)
	if match == null:
		print("Initials must contain only letters A‑Z.")
		return

	# If everything is valid:
	print("Initials accepted:", player_name)
	
	info_label.text = "Adding score to leaderbord, one second..."
	
	emit_signal("submit_button_pressed", player_name)
	# Proceed to reload or go to next screen
	#get_tree().reload_current_scene()
