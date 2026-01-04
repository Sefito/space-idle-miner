extends Node2D

# Spawner configuration
@export var asteroid_scene: PackedScene
@export var min_asteroids: int = 5
@export var max_asteroids: int = 15
@export var spawn_area: Rect2 = Rect2(100, 100, 1720, 880)
@export var min_distance_to_ship: float = 300.0

var current_asteroids: Array = []
var target_asteroid_count: int = 10
var ship_ref: Node2D = null

func _ready() -> void:
	# Load asteroid scene if not set
	if not asteroid_scene:
		asteroid_scene = preload("res://scenes/Asteroid.tscn")

func spawn_initial_asteroids(ship: Node2D) -> void:
	ship_ref = ship
	# Set random target count for this expedition
	target_asteroid_count = randi_range(min_asteroids, max_asteroids)
	# Clear any existing asteroids
	clear_asteroids()
	
	# Spawn initial set
	for i in range(target_asteroid_count):
		spawn_asteroid()

func spawn_asteroid() -> void:
	if not asteroid_scene:
		return
	
	var asteroid = asteroid_scene.instantiate()
	
	# Find valid spawn position (not too close to ship)
	var valid_position = false
	var spawn_pos = Vector2.ZERO
	var max_attempts = 50
	var attempts = 0
	
	while not valid_position and attempts < max_attempts:
		spawn_pos = Vector2(
			randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
			randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
		)
		
		# Check distance from ship
		if is_instance_valid(ship_ref):
			var distance = spawn_pos.distance_to(ship_ref.position)
			if distance >= min_distance_to_ship:
				valid_position = true
		else:
			valid_position = true
		
		attempts += 1
	
	# If no valid position found after max attempts, use fallback position far from expected ship location
	if not valid_position:
		spawn_pos = Vector2(
			spawn_area.position.x + spawn_area.size.x * 0.75,
			spawn_area.position.y + spawn_area.size.y * 0.5
		)
	
	asteroid.position = spawn_pos
	
	# Connect signals
	asteroid.destroyed.connect(_on_asteroid_destroyed)
	asteroid.clicked.connect(_on_asteroid_clicked)
	
	# Add to scene and track
	add_child(asteroid)
	current_asteroids.append(asteroid)

func _on_asteroid_destroyed(asteroid: Area2D) -> void:
	# Remove from tracking
	current_asteroids.erase(asteroid)
	
	# Spawn replacement if below target
	if current_asteroids.size() < target_asteroid_count:
		# Use call_deferred to avoid spawning during physics processing
		call_deferred("spawn_asteroid")

func _on_asteroid_clicked(asteroid: Area2D) -> void:
	# Bubble up the click event to parent (Expedition controller)
	if get_parent().has_method("set_target"):
		get_parent().set_target(asteroid)

func clear_asteroids() -> void:
	for asteroid in current_asteroids:
		if is_instance_valid(asteroid):
			asteroid.queue_free()
	current_asteroids.clear()
	ship_ref = null

func get_nearest_asteroid(from_position: Vector2) -> Area2D:
	var nearest: Area2D = null
	var nearest_distance = INF
	
	for asteroid in current_asteroids:
		if is_instance_valid(asteroid):
			var distance = from_position.distance_to(asteroid.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = asteroid
	
	return nearest
