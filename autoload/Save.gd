extends Node

# Path to the save file
const SAVE_PATH = "user://save.json"

func _ready() -> void:
	print("Save autoload initialized")
	load_game()

# Save the current game state
func save_game() -> void:
	var save_data = {
		"minerals_total": Game.minerals_total,
		"levels_by_id": Upgrades.levels_by_id
	}
	
	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to open save file for writing: " + SAVE_PATH)
		return
	
	file.store_string(json_string)
	file.close()
	print("Game saved to ", SAVE_PATH)

# Load the game state from save file
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found, starting fresh")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading: " + SAVE_PATH)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("Failed to parse save file: " + json.get_error_message())
		return
	
	var save_data = json.get_data()
	
	# Restore minerals_total
	if save_data.has("minerals_total"):
		Game.minerals_total = save_data["minerals_total"]
		print("Loaded minerals_total: ", Game.minerals_total)
	
	# Restore levels_by_id
	if save_data.has("levels_by_id"):
		var saved_levels = save_data["levels_by_id"]
		# Only restore levels for upgrade IDs that exist in the current game
		for upgrade_id in saved_levels:
			if Upgrades.levels_by_id.has(upgrade_id):
				Upgrades.levels_by_id[upgrade_id] = saved_levels[upgrade_id]
		print("Loaded upgrade levels")
		# Recalculate stats based on loaded upgrades
		Upgrades.recalculate_stats()
	
	print("Game loaded from ", SAVE_PATH)
	Game.values_changed.emit()

# Reset the save file and game state
func reset_save() -> void:
	# Delete the save file
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("save.json")
			print("Save file deleted")
		else:
			push_error("Failed to open user:// directory")
	
	# Reset game values to defaults
	Game.minerals_total = 0.0
	Game.minerals_run = 0.0
	
	# Reset all upgrade levels to 0
	for upgrade_id in Upgrades.levels_by_id:
		Upgrades.levels_by_id[upgrade_id] = 0
	
	# Recalculate stats
	Upgrades.recalculate_stats()
	
	# Emit signals to update UI
	Game.values_changed.emit()
	
	print("Save reset complete")
