extends Node2D
class_name Grid

# Grid configuration
const GRID_WIDTH = 8
const GRID_HEIGHT = 8
const CELL_SIZE = 64

# Grid data - 2D array of Critter objects
var grid_data: Array = []

# References
var critter_scene = preload("res://scenes/critter.tscn")
var match_controller: MatchController

# Selection
var selected_critter: Critter = null
var is_processing: bool = false

func _ready():
	match_controller = MatchController.new(self)
	initialize_grid()
	generate_board()

func initialize_grid():
	# Initialize 2D array
	grid_data.clear()
	for x in range(GRID_WIDTH):
		grid_data.append([])
		for y in range(GRID_HEIGHT):
			grid_data[x].append(null)

func generate_board():
	# Fill the board with random Level 1 critters
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			spawn_critter(x, y)

func spawn_critter(x: int, y: int, level: int = Critter.CritterLevel.LEVEL_1) -> Critter:
	# Random critter type
	var type = randi() % 4  # 0-3 for the 4 types
	
	var critter = critter_scene.instantiate()
	add_child(critter)
	critter.initialize(type, level, x, y)
	grid_data[x][y] = critter
	
	return critter

func remove_critter(x: int, y: int):
	if grid_data[x][y] != null:
		var critter = grid_data[x][y]
		grid_data[x][y] = null
		critter.queue_free()

func swap_critters(x1: int, y1: int, x2: int, y2: int):
	if is_processing:
		return
		
	# Check if positions are adjacent
	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	
	if (dx == 1 and dy == 0) or (dx == 0 and dy == 1):
		# Positions are adjacent
		if match_controller.would_create_match(x1, y1, x2, y2):
			is_processing = true
			perform_swap(x1, y1, x2, y2)
		else:
			print("Swap would not create a match")
			# Could add animation for invalid swap here
	else:
		print("Critters are not adjacent")

func perform_swap(x1: int, y1: int, x2: int, y2: int):
	var critter1 = grid_data[x1][y1]
	var critter2 = grid_data[x2][y2]
	
	# Swap in grid data
	grid_data[x1][y1] = critter2
	grid_data[x2][y2] = critter1
	
	# Animate swap
	if critter1:
		critter1.move_to_grid_position(x2, y2)
	if critter2:
		critter2.move_to_grid_position(x1, y1)
	
	# Wait for animation, then process matches
	await get_tree().create_timer(0.25).timeout
	process_matches()

func process_matches():
	var matches = match_controller.find_matches()
	
	if matches.size() > 0:
		print("Found ", matches.size(), " matches")
		match_controller.resolve_matches(matches)
		
		# Wait a bit before refilling
		await get_tree().create_timer(0.3).timeout
		refill_board()
	else:
		is_processing = false

func refill_board():
	# Apply gravity - move critters down
	apply_gravity()
	
	# Fill empty spaces at the top
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if grid_data[x][y] == null:
				spawn_critter(x, y)
	
	# Wait for falling animation
	await get_tree().create_timer(0.3).timeout
	
	# Check for new matches created by refill
	var matches = match_controller.find_matches()
	if matches.size() > 0:
		print("Cascade! Found ", matches.size(), " new matches")
		match_controller.resolve_matches(matches)
		await get_tree().create_timer(0.3).timeout
		refill_board()
	else:
		is_processing = false

func apply_gravity():
	# Move critters down to fill empty spaces
	for x in range(GRID_WIDTH):
		# Start from bottom and work up
		var write_y = GRID_HEIGHT - 1
		for read_y in range(GRID_HEIGHT - 1, -1, -1):
			if grid_data[x][read_y] != null:
				if read_y != write_y:
					# Move critter down
					var critter = grid_data[x][read_y]
					grid_data[x][read_y] = null
					grid_data[x][write_y] = critter
					critter.move_to_grid_position(x, write_y, 0.2)
				write_y -= 1

func _input(event):
	if is_processing:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var grid_x = int(mouse_pos.x / CELL_SIZE)
		var grid_y = int(mouse_pos.y / CELL_SIZE)
		
		if grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT:
			handle_click(grid_x, grid_y)

func handle_click(x: int, y: int):
	var clicked_critter = grid_data[x][y]
	
	if clicked_critter == null:
		return
	
	if selected_critter == null:
		# First selection
		selected_critter = clicked_critter
		selected_critter.set_selected(true)
		print("Selected: ", selected_critter.get_type_name(), " at (", x, ",", y, ")")
	else:
		# Second selection - try to swap
		if selected_critter == clicked_critter:
			# Clicked same critter - deselect
			selected_critter.set_selected(false)
			selected_critter = null
		else:
			# Try to swap
			var old_x = selected_critter.grid_x
			var old_y = selected_critter.grid_y
			selected_critter.set_selected(false)
			
			swap_critters(old_x, old_y, x, y)
			selected_critter = null
