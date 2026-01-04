extends Node2D

# Scene references
@onready var ship: CharacterBody2D = $Ship
@onready var asteroid_spawner: Node2D = $AsteroidSpawner
@onready var laser: Line2D = $Laser
@onready var camera: Camera2D = $Camera2D
@onready var impact_particles: CPUParticles2D = $ImpactParticles

# Target system
var current_target: Area2D = null

# Mining visual feedback
var laser_visible_time: float = 0.0
const LASER_FLASH_DURATION: float = 0.1
const MINING_LASER_INTERVAL: float = 0.5

var time_since_last_laser: float = 0.0

func _ready() -> void:
	# Set up laser
	laser.default_color = Color(1.0, 0.2, 0.2, 0.8)  # Red laser
	laser.width = 3.0
	laser.visible = false
	
	# Setup camera
	var viewport_size := get_viewport_rect().size
	camera.position = viewport_size * 0.5  # Center of current viewport
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	
	# Setup impact particles
	impact_particles.emitting = false
	impact_particles.one_shot = true
	impact_particles.amount = 20
	impact_particles.lifetime = 0.5
	impact_particles.explosiveness = 0.8
	impact_particles.direction = Vector2(0, -1)
	impact_particles.spread = 180
	impact_particles.initial_velocity_min = 50
	impact_particles.initial_velocity_max = 150
	impact_particles.scale_amount_min = 2
	impact_particles.scale_amount_max = 5
	impact_particles.color = Color(0.9, 0.6, 0.3)
	
	# Connect to game state
	Game.state_changed.connect(_on_game_state_changed)
	_update_visibility()

func _exit_tree() -> void:
	# Clean up signal connection
	if Game.state_changed.is_connected(_on_game_state_changed):
		Game.state_changed.disconnect(_on_game_state_changed)

func _process(delta: float) -> void:
	if not visible or Game.state != Game.State.EXPEDITION:
		return
	
	# Ensure we have a target
	if not current_target or not is_instance_valid(current_target):
		find_nearest_asteroid()
	
	# Mine current target
	if current_target and is_instance_valid(current_target):
		# Deal damage based on mining rate
		var damage = Game.mining_rate * delta
		current_target.take_damage(damage)
		
		# Update laser
		time_since_last_laser += delta
		if time_since_last_laser >= MINING_LASER_INTERVAL:
			_show_laser()
			time_since_last_laser = 0.0
	
	# Update laser visibility timer
	if laser_visible_time > 0:
		laser_visible_time -= delta
		if laser_visible_time <= 0:
			laser.visible = false
	
	# Update camera to follow ship (smoothing is handled by Camera2D)
	if ship:
		camera.position = ship.position

func _on_game_state_changed(_new_state: Game.State) -> void:
	_update_visibility()
	if visible and Game.state == Game.State.EXPEDITION:
		# Start new expedition
		_start_expedition()
	elif Game.state == Game.State.SHOP:
		# Clean up when leaving expedition
		current_target = null
		laser.visible = false
		asteroid_spawner.clear_asteroids()

func _start_expedition() -> void:
	# Reset ship position
	ship.position = Vector2(400, 540)
	ship.velocity = Vector2.ZERO
	
	# Spawn asteroids
	asteroid_spawner.spawn_initial_asteroids(ship)
	
	# Find initial target
	find_nearest_asteroid()
	
	time_since_last_laser = 0.0

func _update_visibility() -> void:
	visible = (Game.state == Game.State.EXPEDITION)

func set_target(asteroid: Area2D) -> void:
	# Clear previous target highlight and disconnect signal
	if current_target and is_instance_valid(current_target):
		current_target.set_targeted(false)
		if current_target.destroyed.is_connected(_on_target_destroyed):
			current_target.destroyed.disconnect(_on_target_destroyed)
	
	# Set new target
	current_target = asteroid
	if current_target:
		current_target.set_targeted(true)
		# Connect to destroyed signal
		current_target.destroyed.connect(_on_target_destroyed)

func find_nearest_asteroid() -> void:
	var nearest = asteroid_spawner.get_nearest_asteroid(ship.position)
	if nearest:
		set_target(nearest)

func _on_target_destroyed(asteroid: Area2D) -> void:
	# Grant mineral reward
	Game.minerals_run += asteroid.reward_minerals
	Game.minerals_total += asteroid.reward_minerals
	Game.values_changed.emit()
	
	# Show impact effect
	if impact_particles:
		impact_particles.position = asteroid.position
		impact_particles.emitting = true
	
	# Clear target and find new one
	if current_target == asteroid:
		current_target = null
		find_nearest_asteroid()

func _show_laser() -> void:
	if not current_target or not is_instance_valid(current_target):
		laser.visible = false
		return
	
	# Update laser line from ship to current target
	laser.clear_points()
	laser.add_point(ship.position)
	laser.add_point(current_target.position)
	laser.visible = true
	laser_visible_time = LASER_FLASH_DURATION
	
	# Show particles at impact point (consistent feedback)
	if impact_particles:
		impact_particles.position = current_target.position
		impact_particles.emitting = true
