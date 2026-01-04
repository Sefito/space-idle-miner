extends Area2D

# Asteroid properties
@export var max_hp: float = 100.0
@export var reward_minerals: float = 10.0
@export var progress_bar_offset: Vector2 = Vector2(-60, -150)
@export var progress_bar_size: Vector2 = Vector2(120, 10)

var hp: float
var is_targeted: bool = false

# Visual elements
@onready var polygon: Polygon2D = $Polygon2D
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

# Signals
signal clicked(asteroid: Area2D)
signal destroyed(asteroid: Area2D)

func _ready() -> void:
	# Initialize health
	hp = max_hp
	
	# Generate procedural asteroid shape
	_generate_shape()
	
	# Setup progress bar
	progress_bar.max_value = max_hp
	progress_bar.value = hp
	progress_bar.position = progress_bar_offset
	progress_bar.size = progress_bar_size
	progress_bar.visible = false
	
	# Connect input signal
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	# Update progress bar
	if is_targeted and progress_bar:
		progress_bar.value = hp
		progress_bar.visible = true
	else:
		progress_bar.visible = false

func take_damage(damage: float) -> void:
	hp -= damage
	
	if hp <= 0:
		hp = 0
		_on_destroyed()

func _on_destroyed() -> void:
	# Disconnect signals connected in _ready() before freeing the node
	if input_event.is_connected(_on_input_event):
		input_event.disconnect(_on_input_event)
	if mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.disconnect(_on_mouse_entered)
	if mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.disconnect(_on_mouse_exited)
	
	# Grant minerals reward
	destroyed.emit(self)
	queue_free()

func _generate_shape() -> void:
	# Procedurally generate asteroid shape
	var num_points = randi_range(8, 12)
	var base_radius = randf_range(50, 80)
	var points: PackedVector2Array = []
	var angle_step = TAU / num_points
	
	for i in range(num_points):
		var angle = angle_step * i
		# Add randomness to create irregular shape
		var radius_variation = randf_range(0.7, 1.3)
		var radius = base_radius * radius_variation
		var point = Vector2(cos(angle) * radius, sin(angle) * radius)
		points.append(point)
	
	polygon.polygon = points
	polygon.color = Color(0.5, 0.45, 0.4)  # Rocky brown-gray
	
	# Use same points for collision
	collision.polygon = points

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)

func _on_mouse_entered() -> void:
	# Add hover effect
	polygon.color = Color(0.6, 0.55, 0.5)

func _on_mouse_exited() -> void:
	# Remove hover effect and restore color based on targeted state
	set_targeted(is_targeted)

func set_targeted(targeted: bool) -> void:
	is_targeted = targeted
	if targeted:
		polygon.color = Color(0.7, 0.3, 0.3)  # Red tint when targeted
	else:
		polygon.color = Color(0.5, 0.45, 0.4)  # Normal color
