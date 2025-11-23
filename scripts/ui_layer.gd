extends CanvasLayer
## UI Layer Controller
##
## Manages all UI elements including score display, moves counter,
## and music layer indicators.

# Signals
signal pause_requested()
signal reset_requested()

# References to UI elements
@onready var score_label = $TopBar/HBoxContainer/ScoreLabel
@onready var moves_label = $TopBar/HBoxContainer/MovesLabel
@onready var pause_button = $TopBar/ButtonsContainer/PauseButton
@onready var layers_list = $AudioIndicator/VBoxContainer/LayersList

# Active music layers
var active_layers: Array = []

func _ready():
	print("UI Layer initialized")

func update_score(new_score: int):
	"""Update the score display"""
	score_label.text = "Score: " + str(new_score)

func update_moves(new_moves: int):
	"""Update the moves counter"""
	moves_label.text = "Moves: " + str(new_moves)

func add_music_layer(layer_name: String):
	"""Add a music layer indicator to the UI"""
	if layer_name not in active_layers:
		active_layers.append(layer_name)
		_refresh_layers_display()

func remove_music_layer(layer_name: String):
	"""Remove a music layer indicator from the UI"""
	if layer_name in active_layers:
		active_layers.erase(layer_name)
		_refresh_layers_display()

func _refresh_layers_display():
	"""Refresh the music layers display"""
	# Clear existing labels
	for child in layers_list.get_children():
		layers_list.remove_child(child)
		child.queue_free()
	
	# Add new labels
	for layer in active_layers:
		var label = Label.new()
		label.text = "♪ " + layer
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		layers_list.add_child(label)

func _on_pause_button_pressed():
	"""Handle pause button press"""
	pause_requested.emit()
	
	# Toggle button text
	if pause_button.text == "Pause":
		pause_button.text = "Resume"
	else:
		pause_button.text = "Pause"

func _on_reset_button_pressed():
	"""Handle reset button press"""
	reset_requested.emit()
