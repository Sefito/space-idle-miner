extends CharacterBody2D

# Movement parameters
@export var max_speed: float = 400.0
@export var acceleration: float = 1200.0
@export var friction: float = 800.0

# Visual reference
@onready var polygon: Polygon2D = $Polygon2D

# Viewport bounds for clamping
var viewport_rect: Rect2

func _ready() -> void:
	# Set up ship visual (simple triangle/rocket shape)
	polygon.polygon = PackedVector2Array([
		Vector2(0, -30),
		Vector2(-15, 15),
		Vector2(0, 10),
		Vector2(15, 15)
	])
	polygon.color = Color(0.7, 0.8, 0.9)  # Light blue-gray
	
	# Get viewport size for boundary clamping
	viewport_rect = get_viewport_rect()

func _physics_process(delta: float) -> void:
	# Get input direction
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	
	# Normalize diagonal movement
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	# Apply acceleration or friction
	if input_dir.length() > 0:
		# Accelerate towards input direction
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Move the ship
	move_and_slide()
	
	# Clamp position to viewport bounds
	position.x = clamp(position.x, 0, viewport_rect.size.x)
	position.y = clamp(position.y, 0, viewport_rect.size.y)
