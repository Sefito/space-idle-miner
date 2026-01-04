extends Node

# Signal emitted when any upgrade level changes
signal upgrade_changed(upgrade_id: String)

# Upgrade data loaded from JSON
var upgrades_data: Dictionary = {}

# Current levels for each upgrade (upgrade_id -> level)
var levels_by_id: Dictionary = {}

func _ready() -> void:
	_load_upgrades()
	print("Upgrades autoload initialized with ", upgrades_data.size(), " upgrades")

# Load upgrades from data/upgrades.json
func _load_upgrades() -> void:
	var file_path = "res://data/upgrades.json"
	
	if not FileAccess.file_exists(file_path):
		push_error("Upgrades file not found: " + file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open upgrades file: " + file_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("Failed to parse upgrades JSON: " + json.get_error_message())
		return
	
	var data = json.get_data()
	if not data.has("upgrades"):
		push_error("Upgrades JSON missing 'upgrades' array")
		return
	
	# Store upgrades by ID for easy access
	for upgrade in data["upgrades"]:
		var id = upgrade["id"]
		upgrades_data[id] = upgrade
		levels_by_id[id] = 0  # Initialize all levels to 0

# Get the current level of an upgrade
func get_level(upgrade_id: String) -> int:
	if not levels_by_id.has(upgrade_id):
		push_warning("Unknown upgrade ID: " + upgrade_id)
		return 0
	return levels_by_id[upgrade_id]

# Get upgrade data by ID
func get_upgrade_data(upgrade_id: String) -> Dictionary:
	if not upgrades_data.has(upgrade_id):
		push_warning("Unknown upgrade ID: " + upgrade_id)
		return {}
	return upgrades_data[upgrade_id]

# Calculate the cost of the next level of an upgrade
func get_cost(upgrade_id: String) -> float:
	var upgrade = get_upgrade_data(upgrade_id)
	if upgrade.is_empty():
		return 0.0
	
	var current_level = get_level(upgrade_id)
	if current_level >= upgrade["max_level"]:
		return 0.0  # Already at max level
	
	var base_cost = upgrade["cost_base"]
	var growth = upgrade["cost_growth"]
	
	# Cost formula: base_cost * (growth ^ current_level)
	return base_cost * pow(growth, current_level)

# Check if an upgrade can be bought
func can_buy(upgrade_id: String) -> bool:
	var upgrade = get_upgrade_data(upgrade_id)
	if upgrade.is_empty():
		return false
	
	var current_level = get_level(upgrade_id)
	
	# Check if already at max level
	if current_level >= upgrade["max_level"]:
		return false
	
	# Check prerequisites
	if upgrade.has("requires"):
		for required_id in upgrade["requires"]:
			if get_level(required_id) < 1:
				return false
	
	# Check if player has enough minerals
	var cost = get_cost(upgrade_id)
	if Game.minerals_total < cost:
		return false
	
	return true

# Buy an upgrade (increase its level by 1)
func buy(upgrade_id: String) -> bool:
	if not can_buy(upgrade_id):
		return false
	
	var cost = get_cost(upgrade_id)
	
	# Deduct minerals
	Game.minerals_total -= cost
	
	# Increase level
	levels_by_id[upgrade_id] += 1
	
	# Emit signal and update game stats
	upgrade_changed.emit(upgrade_id)
	recalculate_stats()
	
	print("Bought upgrade: ", upgrade_id, " to level ", levels_by_id[upgrade_id])
	
	# Save progress after buying upgrade
	Save.save_game()
	
	return true

# Recalculate game stats based on current upgrades
func recalculate_stats() -> void:
	var mining_rate_mult_total: float = 0.0
	var duration_add_total: float = 0.0
	
	# Sum up all effects from all upgrades
	for upgrade_id in levels_by_id:
		var level = levels_by_id[upgrade_id]
		if level == 0:
			continue
		
		var upgrade = get_upgrade_data(upgrade_id)
		if upgrade.is_empty() or not upgrade.has("effects"):
			continue
		
		var effects = upgrade["effects"]
		
		# Apply mining rate multiplier
		if effects.has("mining_rate_mult"):
			mining_rate_mult_total += effects["mining_rate_mult"] * level
		
		# Apply duration addition
		if effects.has("duration_add"):
			duration_add_total += effects["duration_add"] * level
	
	# Apply to Game stats
	# Base values
	var base_mining_rate = 1.0
	var base_duration = 30.0
	
	# Apply multipliers
	Game.mining_rate = base_mining_rate * (1.0 + mining_rate_mult_total)
	Game.expedition_duration = max(5.0, base_duration + duration_add_total)  # Minimum 5 seconds
	
	print("Stats recalculated: mining_rate=", Game.mining_rate, " duration=", Game.expedition_duration)

# Get all upgrades (for UI display)
func get_all_upgrades() -> Array:
	return upgrades_data.values()

# Check if upgrade is locked (prerequisites not met)
func is_locked(upgrade_id: String) -> bool:
	var upgrade = get_upgrade_data(upgrade_id)
	if upgrade.is_empty():
		return true
	
	if upgrade.has("requires"):
		for required_id in upgrade["requires"]:
			if get_level(required_id) < 1:
				return true
	
	return false

# Check if upgrade is at max level
func is_maxed(upgrade_id: String) -> bool:
	var upgrade = get_upgrade_data(upgrade_id)
	if upgrade.is_empty():
		return false
	
	return get_level(upgrade_id) >= upgrade["max_level"]
