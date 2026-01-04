extends PanelContainer

@onready var name_label: Label = $HBoxContainer/LeftSection/NameLabel
@onready var desc_label: Label = $HBoxContainer/LeftSection/DescLabel
@onready var level_label: Label = $HBoxContainer/LeftSection/LevelLabel
@onready var cost_label: Label = $HBoxContainer/RightSection/CostLabel
@onready var purchase_button: Button = $HBoxContainer/RightSection/PurchaseButton
@onready var locked_label: Label = $HBoxContainer/RightSection/LockedLabel

var upgrade_id: String = ""

func _ready() -> void:
	purchase_button.pressed.connect(_on_purchase_pressed)

func setup(id: String) -> void:
	upgrade_id = id
	refresh()

func refresh() -> void:
	if upgrade_id.is_empty():
		return
	
	var data = UpgradeSystem.get_upgrade_data(upgrade_id)
	if data.is_empty():
		return
	
	var level = UpgradeSystem.get_upgrade_level(upgrade_id)
	var cost = UpgradeSystem.get_upgrade_cost(upgrade_id)
	var is_unlocked = UpgradeSystem.is_upgrade_unlocked(upgrade_id)
	var is_maxed = UpgradeSystem.is_upgrade_maxed(upgrade_id)
	var can_purchase = UpgradeSystem.can_purchase_upgrade(upgrade_id)
	
	# Update labels
	name_label.text = data["name"]
	desc_label.text = data["desc"]
	level_label.text = "Level: %d / %d" % [level, data["max_level"]]
	cost_label.text = "Cost: %d minerals" % cost
	
	# Update button state
	if not is_unlocked:
		purchase_button.visible = false
		locked_label.visible = true
		locked_label.text = "LOCKED"
		modulate = Color(0.6, 0.6, 0.6)
	elif is_maxed:
		purchase_button.visible = false
		locked_label.visible = true
		locked_label.text = "MAX LEVEL"
		modulate = Color(1.0, 1.0, 1.0)
	else:
		purchase_button.visible = true
		locked_label.visible = false
		purchase_button.disabled = not can_purchase
		purchase_button.text = "Purchase" if can_purchase else "Not Enough Minerals"
		modulate = Color(1.0, 1.0, 1.0)

func _on_purchase_pressed() -> void:
	UpgradeSystem.purchase_upgrade(upgrade_id)
	refresh()
