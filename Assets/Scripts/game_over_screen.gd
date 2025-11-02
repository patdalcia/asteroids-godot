extends Control

signal submit_button_pressed(player_name)

var player_name: String = ""

func _on_restart_button_pressed():
	player_name = $LineEdit.text.strip_edges()  # remove leading/trailing whitespace
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
	
	emit_signal("submit_button_pressed", player_name)
	# Proceed to reload or go to next screen
	get_tree().reload_current_scene()
