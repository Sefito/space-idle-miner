extends Node

# Game state signals
signal minerals_changed(new_amount: int)
signal expedition_started()
signal expedition_ended(minerals_gained: int)
signal stats_updated()

# Player resources
var total_minerals: int = 0
var expedition_minerals: int = 0

# Base stats (modified by upgrades)
var base_mining_rate: float = 10.0  # minerals per second
var base_expedition_duration: float = 60.0  # seconds

# Current modified stats
var current_mining_rate: float = 10.0
var current_expedition_duration: float = 60.0

# Expedition state
var is_expedition_active: bool = false
var expedition_time_remaining: float = 0.0

func _ready() -> void:
	recalculate_stats()

func _process(delta: float) -> void:
	if is_expedition_active:
		expedition_time_remaining -= delta
		if expedition_time_remaining <= 0:
			end_expedition()

func start_expedition() -> void:
	if is_expedition_active:
		return
	
	is_expedition_active = true
	expedition_minerals = 0
	expedition_time_remaining = current_expedition_duration
	expedition_started.emit()

func end_expedition() -> void:
	if not is_expedition_active:
		return
	
	is_expedition_active = false
	# Calculate minerals gained based on mining rate and duration
	expedition_minerals = int(current_mining_rate * current_expedition_duration)
	total_minerals += expedition_minerals
	minerals_changed.emit(total_minerals)
	expedition_ended.emit(expedition_minerals)

func add_minerals(amount: int) -> void:
	total_minerals += amount
	minerals_changed.emit(total_minerals)

func spend_minerals(amount: int) -> bool:
	if total_minerals >= amount:
		total_minerals -= amount
		minerals_changed.emit(total_minerals)
		return true
	return false

func recalculate_stats() -> void:
	# This will be called by UpgradeSystem after purchases
	# For now, just use base stats
	current_mining_rate = base_mining_rate
	current_expedition_duration = base_expedition_duration
	stats_updated.emit()

func get_expedition_progress() -> float:
	if not is_expedition_active or current_expedition_duration <= 0:
		return 0.0
	return 1.0 - (expedition_time_remaining / current_expedition_duration)

func get_expedition_time_remaining() -> float:
	return expedition_time_remaining if is_expedition_active else 0.0
