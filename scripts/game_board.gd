extends Node2D
## Game Board Controller
##
## Manages the grid-based game board for Match-3 mechanics.
## Handles piece placement, matching, and board state.

# Signals
signal pieces_matched(matched_pieces: Array, match_type: String)
signal board_settled()
signal piece_selected(piece)
signal piece_swapped(piece1, piece2)

# Board configuration
const GRID_WIDTH: int = 8
const GRID_HEIGHT: int = 8
const CELL_SIZE: int = 64
const CRITTER_TYPES: int = 5  # Number of different critter types

# Grid state
var grid: Array = []  # 2D array of critter pieces
var selected_piece = null
var is_processing: bool = false

@onready var grid_container = $GridContainer
@onready var match_detector = $MatchDetector
@onready var animation_player = $AnimationPlayer

func _ready():
	_initialize_grid()
	_populate_board()

func _initialize_grid():
	"""Create empty grid structure"""
	grid = []
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(null)
		grid.append(row)
	
	print("Grid initialized: ", GRID_WIDTH, "x", GRID_HEIGHT)

func _populate_board():
	"""Fill board with initial critters ensuring no starting matches"""
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var critter_type = _get_safe_critter_type(x, y)
			_create_critter_at(x, y, critter_type)

func _get_safe_critter_type(x: int, y: int) -> int:
	"""Get a critter type that won't create immediate matches"""
	var forbidden_types = []
	
	# Check horizontal
	if x >= 2 and grid[y][x-1] and grid[y][x-2]:
		if grid[y][x-1].critter_type == grid[y][x-2].critter_type:
			forbidden_types.append(grid[y][x-1].critter_type)
	
	# Check vertical
	if y >= 2 and grid[y-1][x] and grid[y-2][x]:
		if grid[y-1][x].critter_type == grid[y-2][x].critter_type:
			forbidden_types.append(grid[y-1][x].critter_type)
	
	# Get random type not in forbidden list
	var type = randi() % CRITTER_TYPES
	while type in forbidden_types:
		type = randi() % CRITTER_TYPES
	
	return type

func _create_critter_at(x: int, y: int, critter_type: int):
	"""Create a critter piece at the specified grid position"""
	# This will be replaced with actual critter scene instance
	# For now, create a placeholder node
	var critter = {
		"critter_type": critter_type,
		"grid_x": x,
		"grid_y": y,
		"position": Vector2(x * CELL_SIZE, y * CELL_SIZE)
	}
	grid[y][x] = critter
	
	# TODO: Instance actual critter scene and add to grid_container

func _input(event):
	"""Handle player input for selecting and swapping pieces"""
	if is_processing:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var grid_pos = _screen_to_grid(event.position - global_position)
		if _is_valid_position(grid_pos.x, grid_pos.y):
			_handle_piece_click(grid_pos.x, grid_pos.y)

func _screen_to_grid(screen_pos: Vector2) -> Vector2i:
	"""Convert screen position to grid coordinates"""
	var grid_x = int(screen_pos.x / CELL_SIZE)
	var grid_y = int(screen_pos.y / CELL_SIZE)
	return Vector2i(grid_x, grid_y)

func _is_valid_position(x: int, y: int) -> bool:
	"""Check if grid position is valid"""
	return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT

func _handle_piece_click(x: int, y: int):
	"""Handle click on a grid piece"""
	var clicked_piece = grid[y][x]
	
	if selected_piece == null:
		# First selection
		selected_piece = clicked_piece
		piece_selected.emit(clicked_piece)
	else:
		# Second selection - try to swap
		if _are_adjacent(selected_piece, clicked_piece):
			await _swap_pieces(selected_piece, clicked_piece)
			await _check_matches()
		selected_piece = null

func _are_adjacent(piece1, piece2) -> bool:
	"""Check if two pieces are adjacent"""
	var dx = abs(piece1.grid_x - piece2.grid_x)
	var dy = abs(piece1.grid_y - piece2.grid_y)
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

func _swap_pieces(piece1, piece2):
	"""Swap two pieces on the board"""
	is_processing = true
	
	# Swap grid positions
	var temp_x = piece1.grid_x
	var temp_y = piece1.grid_y
	
	piece1.grid_x = piece2.grid_x
	piece1.grid_y = piece2.grid_y
	piece2.grid_x = temp_x
	piece2.grid_y = temp_y
	
	# Update grid array
	grid[piece1.grid_y][piece1.grid_x] = piece1
	grid[piece2.grid_y][piece2.grid_x] = piece2
	
	piece_swapped.emit(piece1, piece2)
	
	# TODO: Animate the swap
	await get_tree().create_timer(0.3).timeout

func _check_matches() -> void:
	"""Check for matches on the board"""
	var matches = _find_all_matches()
	
	if matches.size() > 0:
		# Emit signal with match information
		var match_type = "horizontal" if matches[0].size() > 2 else "special"
		pieces_matched.emit(matches, match_type)
		
		# Remove matched pieces
		await _remove_matches(matches)
		
		# Drop pieces and fill empty spaces
		await _settle_board()
		
		# Check for new matches (recursive)
		await _check_matches()
	else:
		is_processing = false
		board_settled.emit()

func _find_all_matches() -> Array:
	"""Find all matching groups on the board"""
	var all_matches = []
	
	# Check horizontal matches
	for y in range(GRID_HEIGHT):
		var match_length = 1
		for x in range(1, GRID_WIDTH):
			if grid[y][x] and grid[y][x-1] and grid[y][x].critter_type == grid[y][x-1].critter_type:
				match_length += 1
			else:
				if match_length >= 3:
					var match_group = []
					for i in range(match_length):
						match_group.append(grid[y][x-1-i])
					all_matches.append(match_group)
				match_length = 1
		
		if match_length >= 3:
			var match_group = []
			for i in range(match_length):
				match_group.append(grid[y][GRID_WIDTH-1-i])
			all_matches.append(match_group)
	
	# Check vertical matches
	for x in range(GRID_WIDTH):
		var match_length = 1
		for y in range(1, GRID_HEIGHT):
			if grid[y][x] and grid[y-1][x] and grid[y][x].critter_type == grid[y-1][x].critter_type:
				match_length += 1
			else:
				if match_length >= 3:
					var match_group = []
					for i in range(match_length):
						match_group.append(grid[y-1-i][x])
					all_matches.append(match_group)
				match_length = 1
		
		if match_length >= 3:
			var match_group = []
			for i in range(match_length):
				match_group.append(grid[GRID_HEIGHT-1-i][x])
			all_matches.append(match_group)
	
	return all_matches

func _remove_matches(matches: Array):
	"""Remove matched pieces from the board"""
	for match_group in matches:
		for piece in match_group:
			if piece:
				grid[piece.grid_y][piece.grid_x] = null
				# TODO: Play removal animation
	
	await get_tree().create_timer(0.3).timeout

func _settle_board():
	"""Drop pieces down and fill empty spaces"""
	# Drop existing pieces
	for x in range(GRID_WIDTH):
		var empty_spaces = 0
		for y in range(GRID_HEIGHT - 1, -1, -1):
			if grid[y][x] == null:
				empty_spaces += 1
			elif empty_spaces > 0:
				# Move piece down
				var piece = grid[y][x]
				grid[y][x] = null
				grid[y + empty_spaces][x] = piece
				piece.grid_y = y + empty_spaces
				# TODO: Animate drop
	
	# Fill empty spaces with new pieces
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if grid[y][x] == null:
				var critter_type = randi() % CRITTER_TYPES
				_create_critter_at(x, y, critter_type)
	
	await get_tree().create_timer(0.5).timeout
