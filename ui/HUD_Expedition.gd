extends Control

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var minerals_run_label: Label = $VBoxContainer/MineralsRunLabel
@onready var minerals_total_label: Label = $VBoxContainer/MineralsTotalLabel
@onready var mining_rate_label: Label = $VBoxContainer/MiningRateLabel

func _ready() -> void:
	Game.state_changed.connect(_on_game_state_changed)
	Game.values_changed.connect(_on_game_values_changed)
	_update_visibility()
	_update_values()

func _on_game_state_changed(_new_state: Game.State) -> void:
	_update_visibility()

func _on_game_values_changed() -> void:
	_update_values()

func _update_visibility() -> void:
	visible = (Game.state == Game.State.EXPEDITION)

func _update_values() -> void:
	if not visible:
		return
	
	# Format time as mm:ss
	var total_seconds = int(Game.time_left)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	time_label.text = "Tiempo: %02d:%02d" % [minutes, seconds]
	
	# Display minerals
	minerals_run_label.text = "Minerales (run): %.1f" % Game.minerals_run
	minerals_total_label.text = "Minerales (total): %.1f" % Game.minerals_total
	
	# Display mining rate
	mining_rate_label.text = "Velocidad: %.1f /s" % Game.mining_rate
