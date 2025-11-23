extends Node2D
class_name Critter

# Critter types
enum CritterType {
	BUNNY,    # Drummer (Red/Pink)
	CAT,      # Melody (Blue/Cyan)
	FROG,     # Bass (Green)
	BIRD      # Harmony (Yellow/Orange)
}

# Critter levels
enum CritterLevel {
	LEVEL_1,  # Baby
	LEVEL_2,  # Teen
	LEVEL_3   # Star
}

# Properties
var critter_type: CritterType
var critter_level: CritterLevel
var grid_x: int
var grid_y: int
var is_selected: bool = false
var is_moving: bool = false

# Visual size
const CELL_SIZE = 64

# Color mapping for each type
const TYPE_COLORS = {
	CritterType.BUNNY: Color(1.0, 0.4, 0.4),  # Red/Pink
	CritterType.CAT: Color(0.4, 0.7, 1.0),    # Blue/Cyan
	CritterType.FROG: Color(0.4, 1.0, 0.4),   # Green
	CritterType.BIRD: Color(1.0, 0.9, 0.4)    # Yellow/Orange
}

@onready var sprite: ColorRect = $ColorRect

func _ready():
	update_visual()

func initialize(p_critter_type: CritterType, level: CritterLevel, x: int, y: int):
	critter_type = p_critter_type
	critter_level = level
	grid_x = x
	grid_y = y
	update_visual()
	update_position()

func update_visual():
	if not sprite:
		return
		
	# Set color based on type
	var base_color = TYPE_COLORS[critter_type]
	
	# Adjust brightness based on level
	var brightness_multiplier = 1.0 + (critter_level * 0.2)
	sprite.color = base_color * brightness_multiplier
	
	# Adjust size based on level (bigger = higher level)
	var size_multiplier = 0.7 + (critter_level * 0.15)
	var visual_size = CELL_SIZE * size_multiplier
	sprite.size = Vector2(visual_size, visual_size)
	sprite.position = Vector2(-visual_size / 2, -visual_size / 2)

func update_position():
	# Position in world space based on grid coordinates
	position = Vector2(grid_x * CELL_SIZE + CELL_SIZE / 2, grid_y * CELL_SIZE + CELL_SIZE / 2)

func move_to_grid_position(x: int, y: int, duration: float = 0.2):
	grid_x = x
	grid_y = y
	is_moving = true
	
	var target_pos = Vector2(x * CELL_SIZE + CELL_SIZE / 2, y * CELL_SIZE + CELL_SIZE / 2)
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, duration)
	tween.tween_callback(func(): is_moving = false)

func set_selected(selected: bool):
	is_selected = selected
	if sprite:
		# Visual feedback for selection
		if selected:
			sprite.modulate = Color(1.2, 1.2, 1.2)
		else:
			sprite.modulate = Color(1.0, 1.0, 1.0)

func get_type_name() -> String:
	match critter_type:
		CritterType.BUNNY: return "Bunny"
		CritterType.CAT: return "Cat"
		CritterType.FROG: return "Frog"
		CritterType.BIRD: return "Bird"
	return "Unknown"
