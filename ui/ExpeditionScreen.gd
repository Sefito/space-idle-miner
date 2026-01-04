extends Control

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var mining_rate_label: Label = $VBoxContainer/MiningRateLabel
@onready var minerals_label: Label = $VBoxContainer/MineralsLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var start_button: Button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	GameManager.expedition_started.connect(_on_expedition_started)
	GameManager.expedition_ended.connect(_on_expedition_ended)
	GameManager.stats_updated.connect(_update_stats_display)
	
	_update_stats_display()
	_update_button_state()

func _process(_delta: float) -> void:
	if GameManager.is_expedition_active:
		_update_expedition_display()

func _update_stats_display() -> void:
	mining_rate_label.text = "Mining Rate: %.1f minerals/s" % GameManager.current_mining_rate
	minerals_label.text = "Total Minerals: %d" % GameManager.total_minerals

func _update_expedition_display() -> void:
	var time_remaining = GameManager.get_expedition_time_remaining()
	time_label.text = "Time Remaining: %d seconds" % int(time_remaining)
	progress_bar.value = GameManager.get_expedition_progress() * 100.0

func _update_button_state() -> void:
	start_button.disabled = GameManager.is_expedition_active
	start_button.text = "Start Expedition" if not GameManager.is_expedition_active else "Expedition In Progress"

func _on_start_button_pressed() -> void:
	GameManager.start_expedition()
	_update_button_state()

func _on_expedition_started() -> void:
	_update_button_state()
	time_label.visible = true
	progress_bar.visible = true

func _on_expedition_ended(minerals_gained: int) -> void:
	_update_button_state()
	time_label.visible = false
	progress_bar.visible = false
