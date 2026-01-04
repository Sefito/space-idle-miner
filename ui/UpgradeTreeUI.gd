extends Control

@onready var upgrades_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var minerals_label: Label = $TopBar/MineralsLabel
@onready var start_expedition_button: Button = $TopBar/StartExpeditionButton

signal start_expedition_pressed()

var upgrade_node_scene: PackedScene

func _ready() -> void:
	start_expedition_button.pressed.connect(_on_start_expedition_pressed)
	
	# Create upgrade node scene programmatically
	upgrade_node_scene = preload("res://ui/UpgradeNode.tscn")
	
	# Wait for upgrades to load
	if UpgradeSystem.upgrades_data.is_empty():
		await UpgradeSystem.upgrades_loaded
	
	_populate_upgrades()
	_update_minerals_display()
	
	GameManager.minerals_changed.connect(_on_minerals_changed)
	UpgradeSystem.upgrade_purchased.connect(_on_upgrade_purchased)

func _populate_upgrades() -> void:
	# Clear existing nodes
	for child in upgrades_container.get_children():
		child.queue_free()
	
	# Add all upgrades
	var all_upgrades = UpgradeSystem.get_all_upgrades()
	for upgrade_id in all_upgrades:
		var upgrade_node = upgrade_node_scene.instantiate()
		upgrades_container.add_child(upgrade_node)
		upgrade_node.setup(upgrade_id)

func _update_minerals_display() -> void:
	minerals_label.text = "Minerals: %d" % GameManager.total_minerals

func _on_minerals_changed(_new_amount: int) -> void:
	_update_minerals_display()

func _on_upgrade_purchased(_upgrade_id: String) -> void:
	# Refresh all upgrade nodes
	for child in upgrades_container.get_children():
		if child.has_method("refresh"):
			child.refresh()

func _on_start_expedition_pressed() -> void:
	start_expedition_pressed.emit()
