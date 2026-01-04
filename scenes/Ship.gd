extends CharacterBody2D

# Movement parameters
@export var max_speed: float = 400.0
@export var acceleration: float = 1200.0
@export var friction: float = 800.0

# Visual reference
@onready var sprite: Sprite2D = $Sprite2D

# Viewport bounds for clamping
var viewport_rect: Rect2

func _ready() -> void:
	# Get viewport size for boundary clamping
	viewport_rect = get_viewport_rect()

func _physics_process(delta: float) -> void:
	# Only process movement during expedition
	if Game.state != Game.State.EXPEDITION:
		velocity = Vector2.ZERO
		return
	
	# Update viewport rect in case of window resize
	viewport_rect = get_viewport_rect()
	
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
