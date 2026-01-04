extends Node

# Game states
enum State { EXPEDITION, SHOP }

# Signals
signal state_changed(new_state: State)
signal values_changed()

# State variables
var state: State = State.SHOP
var minerals_total: float = 0.0
var minerals_run: float = 0.0

# Base stats (can be modified by upgrades)
var mining_rate: float = 1.0
var expedition_duration: float = 30.0
var time_left: float = 0.0

func _ready() -> void:
	print("Game autoload initialized")

func _process(delta: float) -> void:
	if state == State.EXPEDITION:
		# Decrease time
		var prev_time = int(time_left)
		time_left -= delta
		
		# Emit values changed only when time changes significantly (every second)
		if int(time_left) != prev_time:
			values_changed.emit()
		
		# Check if expedition ended
		if time_left <= 0.0:
			end_expedition()

func start_expedition() -> void:
	print("Starting expedition")
	reset_run_values()
	state = State.EXPEDITION
	time_left = expedition_duration
	state_changed.emit(state)
	values_changed.emit()

func end_expedition() -> void:
	print("Ending expedition. Minerals mined this run: ", minerals_run)
	state = State.SHOP
	time_left = 0.0
	state_changed.emit(state)
	values_changed.emit()
	# Save progress after expedition
	Save.save_game()

func reset_run_values() -> void:
	minerals_run = 0.0
