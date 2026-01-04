extends Control

@onready var minerals_run_label: Label = $CenterContainer/VBoxContainer/MineralsRunLabel
@onready var minerals_total_label: Label = $CenterContainer/VBoxContainer/MineralsTotalLabel
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var upgrades_container: VBoxContainer = $CenterContainer/VBoxContainer/UpgradesScrollContainer/UpgradesContainer

# Store upgrade UI elements for updates
var upgrade_panels: Dictionary = {}

# Confirmation dialog for reset
var reset_confirmation_dialog: ConfirmationDialog

func _ready() -> void:
	Game.state_changed.connect(_on_game_state_changed)
	Game.values_changed.connect(_on_game_values_changed)
	Upgrades.upgrade_changed.connect(_on_upgrade_changed)
	start_button.pressed.connect(_on_start_button_pressed)
	_create_reset_button()
	_create_confirmation_dialog()
	_update_visibility()
	_update_values()
	_create_upgrade_ui()

func _on_game_state_changed(_new_state: Game.State) -> void:
	_update_visibility()
	if visible:
		_update_values()
		_update_upgrades_ui()

func _on_game_values_changed() -> void:
	if visible:
		_update_values()
		_update_upgrades_ui()

func _on_upgrade_changed(_upgrade_id: String) -> void:
	_update_values()
	_update_upgrades_ui()

func _update_visibility() -> void:
	visible = (Game.state == Game.State.SHOP)

func _update_values() -> void:
	if not visible:
		return
	
	minerals_run_label.text = "Minerales obtenidos: %.1f" % Game.minerals_run
	minerals_total_label.text = "Total acumulado: %.1f" % Game.minerals_total

func _create_upgrade_ui() -> void:
	# Clear existing UI
	for child in upgrades_container.get_children():
		child.queue_free()
	upgrade_panels.clear()
	
	# Group upgrades by tier (based on max prerequisite depth)
	var upgrades_by_tier: Dictionary = {}
	var all_upgrades = Upgrades.get_all_upgrades()
	
	for upgrade in all_upgrades:
		var tier = _calculate_tier(upgrade["id"])
		if not upgrades_by_tier.has(tier):
			upgrades_by_tier[tier] = []
		upgrades_by_tier[tier].append(upgrade)
	
	# Create UI for each tier
	var tiers = upgrades_by_tier.keys()
	tiers.sort()
	
	for tier in tiers:
		# Tier label
		var tier_label = Label.new()
		tier_label.text = "Tier " + str(tier)
		tier_label.add_theme_font_size_override("font_size", 24)
		tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		upgrades_container.add_child(tier_label)
		
		# Grid for this tier's upgrades
		var grid = GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		upgrades_container.add_child(grid)
		
		for upgrade in upgrades_by_tier[tier]:
			var panel = _create_upgrade_panel(upgrade)
			grid.add_child(panel)
			upgrade_panels[upgrade["id"]] = panel
	
	_update_upgrades_ui()

func _calculate_tier(upgrade_id: String) -> int:
	var upgrade = Upgrades.get_upgrade_data(upgrade_id)
	if upgrade.is_empty():
		return 0
	
	if not upgrade.has("requires") or upgrade["requires"].is_empty():
		return 0
	
	var max_tier = 0
	for required_id in upgrade["requires"]:
		var required_tier = _calculate_tier(required_id)
		max_tier = max(max_tier, required_tier + 1)
	
	return max_tier

func _create_upgrade_panel(upgrade: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 150)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	panel.add_child(vbox)
	
	# Name label
	var name_label = Label.new()
	name_label.text = upgrade["name"]
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# Description label
	var desc_label = Label.new()
	desc_label.text = upgrade["desc"]
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)
	
	# Level label
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.add_theme_font_size_override("font_size", 14)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level_label)
	
	# Cost label
	var cost_label = Label.new()
	cost_label.name = "CostLabel"
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cost_label)
	
	# Buy button
	var buy_button = Button.new()
	buy_button.name = "BuyButton"
	buy_button.text = "Comprar"
	buy_button.custom_minimum_size = Vector2(0, 30)
	buy_button.pressed.connect(_on_buy_button_pressed.bind(upgrade["id"]))
	vbox.add_child(buy_button)
	
	return panel

func _update_upgrades_ui() -> void:
	for upgrade_id in upgrade_panels:
		_update_upgrade_panel(upgrade_id)

func _update_upgrade_panel(upgrade_id: String) -> void:
	var panel = upgrade_panels.get(upgrade_id)
	if panel == null:
		return
	
	var upgrade = Upgrades.get_upgrade_data(upgrade_id)
	if upgrade.is_empty():
		return
	
	var level = Upgrades.get_level(upgrade_id)
	var max_level = upgrade["max_level"]
	var cost = Upgrades.get_cost(upgrade_id)
	var is_locked = Upgrades.is_locked(upgrade_id)
	var is_maxed = Upgrades.is_maxed(upgrade_id)
	var can_buy = Upgrades.can_buy(upgrade_id)
	
	# Update level label
	var level_label = panel.find_child("LevelLabel", true, false) as Label
	if level_label:
		level_label.text = "Nivel: %d/%d" % [level, max_level]
	
	# Update cost label
	var cost_label = panel.find_child("CostLabel", true, false) as Label
	if cost_label:
		if is_maxed:
			cost_label.text = "MAX"
		else:
			cost_label.text = "Coste: %.0f minerales" % cost
	
	# Update buy button
	var buy_button = panel.find_child("BuyButton", true, false) as Button
	if buy_button:
		if is_maxed:
			buy_button.text = "MAXED"
			buy_button.disabled = true
		elif is_locked:
			buy_button.text = "LOCKED"
			buy_button.disabled = true
		elif can_buy:
			buy_button.text = "Comprar"
			buy_button.disabled = false
		else:
			buy_button.text = "Sin recursos"
			buy_button.disabled = true
	
	# Visual feedback for state
	var style = StyleBoxFlat.new()
	if is_maxed:
		style.bg_color = Color(0.2, 0.6, 0.2, 0.3)  # Green tint
	elif is_locked:
		style.bg_color = Color(0.3, 0.3, 0.3, 0.3)  # Gray tint
	elif can_buy:
		style.bg_color = Color(0.2, 0.4, 0.8, 0.3)  # Blue tint
	else:
		style.bg_color = Color(0.2, 0.2, 0.2, 0.3)  # Dark tint
	
	panel.add_theme_stylebox_override("panel", style)

func _on_buy_button_pressed(upgrade_id: String) -> void:
	Upgrades.buy(upgrade_id)

func _on_start_button_pressed() -> void:
	Game.start_expedition()

func _create_reset_button() -> void:
	# Create a reset button and add it to the VBoxContainer
	var reset_button = Button.new()
	reset_button.name = "ResetButton"
	reset_button.text = "Resetear Partida"
	reset_button.custom_minimum_size = Vector2(300, 50)
	reset_button.add_theme_font_size_override("font_size", 20)
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	# Add it to the end of the VBoxContainer
	var vbox = $CenterContainer/VBoxContainer
	vbox.add_child(reset_button)

func _create_confirmation_dialog() -> void:
	# Create confirmation dialog
	reset_confirmation_dialog = ConfirmationDialog.new()
	reset_confirmation_dialog.title = "Confirmar Reset"
	reset_confirmation_dialog.dialog_text = "¿Estás seguro de que quieres resetear toda tu partida?\nSe perderán todos los minerales y mejoras."
	reset_confirmation_dialog.ok_button_text = "Sí, resetear"
	reset_confirmation_dialog.cancel_button_text = "Cancelar"
	reset_confirmation_dialog.confirmed.connect(_on_reset_confirmed)
	add_child(reset_confirmation_dialog)

func _on_reset_button_pressed() -> void:
	# Show confirmation dialog
	reset_confirmation_dialog.popup_centered()

func _on_reset_confirmed() -> void:
	# Reset the save
	Save.reset_save()
	# Recreate the upgrade UI to reflect the reset
	_create_upgrade_ui()

