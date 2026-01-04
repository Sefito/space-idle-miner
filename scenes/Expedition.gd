extends Node2D

# Visual elements
@onready var ship: Polygon2D = $Ship
@onready var asteroid: Polygon2D = $Asteroid
@onready var laser: Line2D = $Laser

# Mining visual feedback
var laser_visible_time: float = 0.0
const LASER_FLASH_DURATION: float = 0.1
const MINING_LASER_INTERVAL: float = 0.5

var time_since_last_laser: float = 0.0

func _ready() -> void:
	# Set up ship visual (simple triangle/rocket shape)
	ship.polygon = PackedVector2Array([
		Vector2(0, -30),
		Vector2(-15, 15),
		Vector2(0, 10),
		Vector2(15, 15)
	])
	ship.color = Color(0.7, 0.8, 0.9)  # Light blue-gray
	ship.position = Vector2(400, 540)
	
	# Generate initial asteroid
	_generate_asteroid()
	
	# Set up laser
	laser.default_color = Color(1.0, 0.2, 0.2, 0.8)  # Red laser
	laser.width = 3.0
	laser.visible = false
	
	# Connect to game state
	Game.state_changed.connect(_on_game_state_changed)
	_update_visibility()

func _process(delta: float) -> void:
	if not visible:
		return
	
	# Handle laser visual feedback during mining
	if Game.state == Game.State.EXPEDITION:
		time_since_last_laser += delta
		
		# Show laser periodically to indicate mining
		if time_since_last_laser >= MINING_LASER_INTERVAL:
			_show_laser()
			time_since_last_laser = 0.0
		
		# Update laser visibility timer
		if laser_visible_time > 0:
			laser_visible_time -= delta
			if laser_visible_time <= 0:
				laser.visible = false

func _on_game_state_changed(_new_state: Game.State) -> void:
	_update_visibility()
	if visible:
		# Generate new asteroid when starting a new expedition
		_generate_asteroid()
		time_since_last_laser = 0.0

func _update_visibility() -> void:
	visible = (Game.state == Game.State.EXPEDITION)

func _generate_asteroid() -> void:
	# Procedurally generate asteroid shape
	var num_points = randi_range(8, 12)
	var base_radius = randf_range(80, 120)
	var points: PackedVector2Array = []
	
	for i in range(num_points):
		var angle = (TAU / num_points) * i
		# Add randomness to create irregular shape
		var radius_variation = randf_range(0.7, 1.3)
		var radius = base_radius * radius_variation
		var point = Vector2(cos(angle) * radius, sin(angle) * radius)
		points.append(point)
	
	asteroid.polygon = points
	asteroid.color = Color(0.5, 0.45, 0.4)  # Rocky brown-gray
	asteroid.position = Vector2(1520, 540)

func _show_laser() -> void:
	# Update laser line from ship to asteroid
	laser.clear_points()
	laser.add_point(ship.position)
	laser.add_point(asteroid.position)
	laser.visible = true
	laser_visible_time = LASER_FLASH_DURATION
