extends Node

signal upgrade_purchased(upgrade_id: String)
signal upgrades_loaded()

# Data structure for upgrades
var upgrades_data: Dictionary = {}
var upgrade_levels: Dictionary = {}  # upgrade_id -> current_level

func _ready() -> void:
	load_upgrades()

func load_upgrades() -> void:
	var file = FileAccess.open("res://data/upgrades.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			if data.has("upgrades"):
				for upgrade in data["upgrades"]:
					upgrades_data[upgrade["id"]] = upgrade
					upgrade_levels[upgrade["id"]] = 0
				upgrades_loaded.emit()
		else:
			push_error("Failed to parse upgrades.json: " + json.get_error_message())
	else:
		push_error("Failed to open upgrades.json")

func get_upgrade_data(upgrade_id: String) -> Dictionary:
	if upgrades_data.has(upgrade_id):
		return upgrades_data[upgrade_id]
	return {}

func get_upgrade_level(upgrade_id: String) -> int:
	if upgrade_levels.has(upgrade_id):
		return upgrade_levels[upgrade_id]
	return 0

func get_upgrade_cost(upgrade_id: String) -> int:
	var data = get_upgrade_data(upgrade_id)
	if data.is_empty():
		return 0
	
	var current_level = get_upgrade_level(upgrade_id)
	var base_cost = data.get("cost_base", 0)
	var growth = data.get("cost_growth", 1.0)
	
	return int(base_cost * pow(growth, current_level))

func is_upgrade_unlocked(upgrade_id: String) -> bool:
	var data = get_upgrade_data(upgrade_id)
	if data.is_empty():
		return false
	
	var requires = data.get("requires", [])
	
	# Check if all prerequisites are met (at least level 1)
	for req_id in requires:
		if get_upgrade_level(req_id) < 1:
			return false
	
	return true

func is_upgrade_maxed(upgrade_id: String) -> bool:
	var data = get_upgrade_data(upgrade_id)
	if data.is_empty():
		return true
	
	var current_level = get_upgrade_level(upgrade_id)
	var max_level = data.get("max_level", 0)
	
	return current_level >= max_level

func can_purchase_upgrade(upgrade_id: String) -> bool:
	if is_upgrade_maxed(upgrade_id):
		return false
	
	if not is_upgrade_unlocked(upgrade_id):
		return false
	
	var cost = get_upgrade_cost(upgrade_id)
	return GameManager.total_minerals >= cost

func purchase_upgrade(upgrade_id: String) -> bool:
	if not can_purchase_upgrade(upgrade_id):
		return false
	
	var cost = get_upgrade_cost(upgrade_id)
	if GameManager.spend_minerals(cost):
		upgrade_levels[upgrade_id] += 1
		upgrade_purchased.emit(upgrade_id)
		apply_upgrades()
		return true
	
	return false

func apply_upgrades() -> void:
	# Reset to base stats
	var mining_rate_mult = 1.0
	var duration_add = 0.0
	
	# Apply all purchased upgrades
	for upgrade_id in upgrade_levels:
		var level = upgrade_levels[upgrade_id]
		if level <= 0:
			continue
		
		var data = get_upgrade_data(upgrade_id)
		if data.is_empty():
			continue
		
		var effects = data.get("effects", {})
		
		# Apply mining rate multiplier (multiplicative per level)
		if effects.has("mining_rate_mult"):
			var mult = effects["mining_rate_mult"]
			mining_rate_mult *= pow(mult, level)
		
		# Apply duration additions (additive per level)
		if effects.has("duration_add"):
			var add = effects["duration_add"]
			duration_add += add * level
	
	# Update GameManager stats
	GameManager.current_mining_rate = GameManager.base_mining_rate * mining_rate_mult
	GameManager.current_expedition_duration = GameManager.base_expedition_duration + duration_add
	GameManager.recalculate_stats()

func get_all_upgrades() -> Array:
	var result = []
	for upgrade_id in upgrades_data:
		result.append(upgrade_id)
	return result
