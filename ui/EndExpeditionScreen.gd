extends Control

@onready var minerals_gained_label: Label = $Panel/VBoxContainer/MineralsGainedLabel
@onready var total_minerals_label: Label = $Panel/VBoxContainer/TotalMineralsLabel
@onready var go_to_shop_button: Button = $Panel/VBoxContainer/GoToShopButton

signal go_to_shop_pressed()

func _ready() -> void:
	go_to_shop_button.pressed.connect(_on_go_to_shop_pressed)
	hide()

func show_results(minerals_gained: int, total_minerals: int) -> void:
	minerals_gained_label.text = "Minerals Gained: %d" % minerals_gained
	total_minerals_label.text = "Total Minerals: %d" % total_minerals
	show()

func _on_go_to_shop_pressed() -> void:
	go_to_shop_pressed.emit()
	hide()
