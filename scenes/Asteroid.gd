extends Area2D

# Asteroid properties
@export var max_hp: float = 100.0
@export var reward_minerals: float = 10.0
# NOTE: The default offset and size are tuned for the asteroid sprite size.
# Adjust these values if you change the sprite scale.
@export var progress_bar_offset: Vector2 = Vector2(-40, -30)
@export var progress_bar_size: Vector2 = Vector2(80, 8)

var hp: float
var is_targeted: bool = false

# Visual elements
@onready var sprite: Sprite2D = $Sprite2D
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var collision: CollisionShape2D = $CollisionShape2D

# Signals
signal clicked(asteroid: Area2D)
signal destroyed(asteroid: Area2D)

func _ready() -> void:
	# Initialize health
	hp = max_hp
	
	# Randomize asteroid appearance
	_randomize_appearance()
	
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
	# Disconnect signals before freeing the node
	if input_event.is_connected(_on_input_event):
		input_event.disconnect(_on_input_event)
	if mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.disconnect(_on_mouse_entered)
	if mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.disconnect(_on_mouse_exited)
	
	# Emit destroyed signal; reward handling is done by the signal listener
	destroyed.emit(self)
	queue_free()

func _randomize_appearance() -> void:
	# Select random asteroid frame (0-5 for 6 different asteroids in spritesheet)
	# The asteroids.png contains 6 asteroids arranged in a 3x2 grid
	sprite.hframes = 3  # 3 columns
	sprite.vframes = 2  # 2 rows
	sprite.frame = randi_range(0, 5)  # Select one of the 6 asteroids
	
	# Random rotation for variety
	sprite.rotation = randf() * TAU
	
	# Base scale is 1/3 of original, then apply random variation (0.8 to 1.2)
	var scale_factor = (1.0 / 3.0) * randf_range(0.8, 1.2)
	sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Slight color tint variation for more variety
	var color_variation = randf_range(0.9, 1.1)
	sprite.modulate = Color(color_variation, color_variation, color_variation)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)

func _on_mouse_entered() -> void:
	# Add hover effect only if not targeted (slight brightness increase)
	if not is_targeted:
		sprite.modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited() -> void:
	# Remove hover effect and restore color based on targeted state
	set_targeted(is_targeted)

func set_targeted(targeted: bool) -> void:
	is_targeted = targeted
	if targeted:
		sprite.modulate = Color(1.5, 0.8, 0.8)  # Red tint when targeted
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0)  # Normal color
