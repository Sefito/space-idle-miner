extends Control

@onready var minerals_run_label: Label = $CenterContainer/VBoxContainer/MineralsRunLabel
@onready var minerals_total_label: Label = $CenterContainer/VBoxContainer/MineralsTotalLabel
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton

func _ready() -> void:
	Game.state_changed.connect(_on_game_state_changed)
	start_button.pressed.connect(_on_start_button_pressed)
	_update_visibility()
	_update_values()

func _on_game_state_changed(_new_state: Game.State) -> void:
	_update_visibility()
	if visible:
		_update_values()

func _update_visibility() -> void:
	visible = (Game.state == Game.State.SHOP)

func _update_values() -> void:
	if not visible:
		return
	
	minerals_run_label.text = "Minerales obtenidos: %.1f" % Game.minerals_run
	minerals_total_label.text = "Total acumulado: %.1f" % Game.minerals_total

func _on_start_button_pressed() -> void:
	Game.start_expedition()
