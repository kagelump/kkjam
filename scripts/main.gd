extends Node2D
## Main game controller
##
## Manages the overall game flow, coordinates between the game board,
## UI, and audio systems.

# Game state
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
var current_state: GameState = GameState.MENU

# References to child nodes
@onready var game_board = $GameBoard
@onready var ui_layer = $UILayer
@onready var audio_manager = $AudioManager

# Game variables
var score: int = 0
var moves: int = 0

func _ready():
	print("Critter Composer - Game Starting")
	_setup_game()

func _setup_game():
	"""Initialize game components"""
	current_state = GameState.PLAYING
	score = 0
	moves = 0
	
	# Connect signals from game board
	if game_board:
		game_board.pieces_matched.connect(_on_pieces_matched)
		game_board.board_settled.connect(_on_board_settled)
	
	# Connect UI signals
	if ui_layer:
		ui_layer.pause_requested.connect(_on_pause_requested)
		ui_layer.reset_requested.connect(_on_reset_requested)

func _on_pieces_matched(matched_pieces: Array, match_type: String):
	"""Handle when pieces are matched on the board"""
	var points = matched_pieces.size() * 10
	score += points
	
	if ui_layer:
		ui_layer.update_score(score)
	
	# Play audio feedback based on match type
	# This will be expanded with actual audio system
	print("Match detected: ", match_type, " for ", points, " points")

func _on_board_settled():
	"""Called when board has finished settling after matches"""
	moves += 1
	if ui_layer:
		ui_layer.update_moves(moves)

func _on_pause_requested():
	"""Handle pause request from UI"""
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
	elif current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false

func _on_reset_requested():
	"""Reset the game"""
	get_tree().paused = false
	get_tree().reload_current_scene()
