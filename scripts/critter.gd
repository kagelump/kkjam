extends Node2D
## Critter Piece
##
## Represents an individual critter on the game board.
## Each critter has a type, visual representation, and associated audio loop.

# Critter properties
var critter_type: int = 0
var grid_x: int = 0
var grid_y: int = 0
var is_selected: bool = false
var evolution_level: int = 0  # 0 = base, increases with matches

# Audio properties
var audio_loop: AudioStream = null
var is_playing_audio: bool = false

# Visual properties
var base_scale: Vector2 = Vector2.ONE
var color_palette: Array[Color] = [
	Color.CORAL,
	Color.CYAN,
	Color.YELLOW,
	Color.LIME_GREEN,
	Color.MAGENTA
]

@onready var sprite = $Sprite
@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	_setup_appearance()

func initialize(type: int, grid_pos_x: int, grid_pos_y: int):
	"""Initialize the critter with type and position"""
	critter_type = type
	grid_x = grid_pos_x
	grid_y = grid_pos_y
	evolution_level = 0
	_setup_appearance()

func _setup_appearance():
	"""Set up the visual appearance based on critter type"""
	# For now, use colored rectangles as placeholders
	# In a full implementation, this would load sprite sheets
	if sprite:
		sprite.modulate = color_palette[critter_type % color_palette.size()]
		# TODO: Load actual sprite based on critter_type and evolution_level

func evolve():
	"""Evolve the critter to next level"""
	evolution_level += 1
	_setup_appearance()
	_play_evolution_animation()
	
	# Enhance audio loop
	# TODO: Load evolved audio loop

func _play_evolution_animation():
	"""Play evolution animation"""
	# TODO: Create and play evolution animation
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale * 1.3, 0.2)
	tween.tween_property(self, "scale", base_scale, 0.2)

func select():
	"""Mark this critter as selected"""
	is_selected = true
	_play_select_animation()

func deselect():
	"""Unmark this critter as selected"""
	is_selected = false
	_play_deselect_animation()

func _play_select_animation():
	"""Play selection animation"""
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE * 1.1, 0.1)

func _play_deselect_animation():
	"""Play deselection animation"""
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)

func start_audio_loop():
	"""Start playing this critter's audio loop"""
	if audio_loop and audio_player and not is_playing_audio:
		audio_player.stream = audio_loop
		audio_player.play()
		is_playing_audio = true

func stop_audio_loop():
	"""Stop playing this critter's audio loop"""
	if audio_player and is_playing_audio:
		audio_player.stop()
		is_playing_audio = false

func get_music_layer_name() -> String:
	"""Get the name of this critter's music layer"""
	var type_names = ["Bass", "Melody", "Percussion", "Harmony", "Lead"]
	var base_name = type_names[critter_type % type_names.size()]
	if evolution_level > 0:
		return base_name + " Lv" + str(evolution_level)
	return base_name
