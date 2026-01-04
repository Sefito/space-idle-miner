extends Node

@onready var expedition_screen: Control = $ExpeditionScreen
@onready var end_expedition_screen: Control = $EndExpeditionScreen
@onready var upgrade_tree_ui: Control = $UpgradeTreeUI

func _ready() -> void:
	# Connect signals
	GameManager.expedition_ended.connect(_on_expedition_ended)
	end_expedition_screen.go_to_shop_pressed.connect(_on_go_to_shop)
	upgrade_tree_ui.start_expedition_pressed.connect(_on_start_expedition_from_shop)
	
	# Show expedition screen initially
	_show_expedition_screen()

func _show_expedition_screen() -> void:
	expedition_screen.show()
	end_expedition_screen.hide()
	upgrade_tree_ui.hide()

func _show_end_expedition_screen(minerals_gained: int) -> void:
	expedition_screen.hide()
	end_expedition_screen.show_results(minerals_gained, GameManager.total_minerals)
	upgrade_tree_ui.hide()

func _show_shop() -> void:
	expedition_screen.hide()
	end_expedition_screen.hide()
	upgrade_tree_ui.show()

func _on_expedition_ended(minerals_gained: int) -> void:
	_show_end_expedition_screen(minerals_gained)

func _on_go_to_shop() -> void:
	_show_shop()

func _on_start_expedition_from_shop() -> void:
	_show_expedition_screen()
