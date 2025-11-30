extends Node2D
class_name Grid

# Grid configuration
const GRID_WIDTH = 8
const GRID_HEIGHT = 8
const CELL_SIZE = 90

# Grid data - 2D array of Critter objects
var grid_data: Array = []

# References
var critter_scene = preload("res://scenes/critter.tscn")
var match_controller: MatchController

# Selection
var selected_critter: Critter = null
var processing_matches: bool = false
var last_swap_target: Vector2 = Vector2(-1, -1)

# Touch/drag support
var drag_start_pos: Vector2 = Vector2.ZERO
var drag_start_grid_pos: Vector2i = Vector2i(-1, -1)
var is_dragging: bool = false
const DRAG_THRESHOLD: float = 20.0  # Minimum pixels to trigger a drag

# Safety timeout for processing state
const PROCESSING_TIMEOUT: float = 10.0
var _processing_start_time: float = 0.0

func _ready():
	match_controller = MatchController.new(self)
	initialize_grid()
	generate_board()

func _process(_delta: float):
	# Safety timeout: if processing_matches stays true for too long, reset it
	if processing_matches and _processing_start_time > 0.0:
		var elapsed = Time.get_ticks_msec() / 1000.0 - _processing_start_time
		if elapsed > PROCESSING_TIMEOUT:
			push_warning("Grid: Processing timeout reached, resetting state")
			_reset_processing_state()

func initialize_grid():
	# Initialize 2D array
	grid_data.clear()
	for x in range(GRID_WIDTH):
		grid_data.append([])
		for y in range(GRID_HEIGHT):
			grid_data[x].append(null)

func generate_board():
	# Fill the board with random Level 1 critters, ensuring no initial matches
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			spawn_critter_no_match(x, y)

func spawn_critter_no_match(x: int, y: int):
	var possible_types = []
	for i in range(Critter.CritterType.size()):
		possible_types.append(i)
	
	# Remove types that would create a match
	# Check left (horizontal match)
	if x >= 2:
		var c1 = grid_data[x-1][y]
		var c2 = grid_data[x-2][y]
		if c1 and c2 and c1.critter_type == c2.critter_type and c1.critter_level == Critter.CritterLevel.LEVEL_1 and c2.critter_level == Critter.CritterLevel.LEVEL_1:
			possible_types.erase(c1.critter_type)
			
	# Check up (vertical match)
	if y >= 2:
		var c1 = grid_data[x][y-1]
		var c2 = grid_data[x][y-2]
		if c1 and c2 and c1.critter_type == c2.critter_type and c1.critter_level == Critter.CritterLevel.LEVEL_1 and c2.critter_level == Critter.CritterLevel.LEVEL_1:
			possible_types.erase(c1.critter_type)
	
	# Pick a random valid type
	if possible_types.size() > 0:
		var type = possible_types[randi() % possible_types.size()]
		var critter = critter_scene.instantiate()
		$CritterContainer.add_child(critter)
		critter.initialize(type, Critter.CritterLevel.LEVEL_1, x, y)
		grid_data[x][y] = critter
	else:
		# Fallback if somehow no valid types (shouldn't happen with 4 types)
		spawn_critter(x, y)

func spawn_critter(x: int, y: int, level: Critter.CritterLevel = Critter.CritterLevel.LEVEL_1) -> Critter:
	# Random critter type
	var type = randi() % Critter.CritterType.size()
	
	var critter = critter_scene.instantiate()
	$CritterContainer.add_child(critter)
	critter.initialize(type, level, x, y)
	grid_data[x][y] = critter
	
	return critter

func remove_critter(x: int, y: int):
	if grid_data[x][y] != null:
		var critter = grid_data[x][y]
		grid_data[x][y] = null
		critter.queue_free()

func swap_critters(x1: int, y1: int, x2: int, y2: int):
	if processing_matches:
		return
		
	# Check if positions are adjacent
	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	
	if (dx == 1 and dy == 0) or (dx == 0 and dy == 1):
		# Positions are adjacent
		if match_controller.would_create_match(x1, y1, x2, y2):
			_start_processing()
			perform_swap(x1, y1, x2, y2)
		else:
			print("Swap would not create a match")
			perform_invalid_swap(x1, y1, x2, y2)
	else:
		print("Critters are not adjacent")

func _start_processing():
	processing_matches = true
	_processing_start_time = Time.get_ticks_msec() / 1000.0

func _reset_processing_state():
	processing_matches = false
	_processing_start_time = 0.0
	last_swap_target = Vector2(-1, -1)
	if selected_critter and is_instance_valid(selected_critter):
		selected_critter.set_selected(false)
	selected_critter = null

func perform_swap(x1: int, y1: int, x2: int, y2: int):
	var critter1 = grid_data[x1][y1]
	var critter2 = grid_data[x2][y2]
	
	# Store swap target (the second clicked critter)
	last_swap_target = Vector2(x2, y2)
	
	# Swap in grid data
	grid_data[x1][y1] = critter2
	grid_data[x2][y2] = critter1
	
	# Animate swap
	if critter1 and is_instance_valid(critter1):
		critter1.move_to_grid_position(x2, y2)
	if critter2 and is_instance_valid(critter2):
		critter2.move_to_grid_position(x1, y1)
	
	# Wait for animation, then process matches
	var tree = get_tree()
	if tree:
		await tree.create_timer(0.25).timeout
		if is_inside_tree():
			process_matches()
		else:
			_reset_processing_state()

func perform_invalid_swap(x1: int, y1: int, x2: int, y2: int):
	# Animate trying to swap and swapping back
	_start_processing()
	var critter1 = grid_data[x1][y1]
	var critter2 = grid_data[x2][y2]
	
	# Swap positions visually (but not in grid data)
	var pos1 = Vector2(x1 * CELL_SIZE + CELL_SIZE / 2.0, y1 * CELL_SIZE + CELL_SIZE / 2.0)
	var pos2 = Vector2(x2 * CELL_SIZE + CELL_SIZE / 2.0, y2 * CELL_SIZE + CELL_SIZE / 2.0)
	
	if critter1 and is_instance_valid(critter1):
		var tween1 = create_tween()
		tween1.tween_property(critter1, "position", pos2, 0.15)
		tween1.tween_property(critter1, "position", pos1, 0.15)
	
	if critter2 and is_instance_valid(critter2):
		var tween2 = create_tween()
		tween2.tween_property(critter2, "position", pos1, 0.15)
		tween2.tween_property(critter2, "position", pos2, 0.15)
	
	# Wait for animation to finish
	var tree = get_tree()
	if tree:
		await tree.create_timer(0.3).timeout
	_reset_processing_state()

func process_matches():
	if not is_inside_tree():
		_reset_processing_state()
		return
	
	var matches = match_controller.find_matches()
	
	if matches.size() > 0:
		print("Found ", matches.size(), " matches")
		match_controller.resolve_matches(matches, last_swap_target)
		
		# Reset swap target
		last_swap_target = Vector2(-1, -1)
		
		# Wait a bit before refilling
		var tree = get_tree()
		if tree:
			await tree.create_timer(0.3).timeout
			if is_inside_tree():
				refill_board()
			else:
				_reset_processing_state()
	else:
		_reset_processing_state()

func refill_board():
	if not is_inside_tree():
		_reset_processing_state()
		return
	
	# Apply gravity - move critters down
	apply_gravity()
	
	# Fill empty spaces at the top
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if grid_data[x][y] == null:
				spawn_critter(x, y)
	
	# Wait for falling animation
	var tree = get_tree()
	if tree:
		await tree.create_timer(0.3).timeout
	
	if not is_inside_tree():
		_reset_processing_state()
		return
	
	# Check for new matches created by refill
	var matches = match_controller.find_matches()
	if matches.size() > 0:
		print("Cascade! Found ", matches.size(), " new matches")
		match_controller.resolve_matches(matches) # No swap target for cascades
		if tree:
			await tree.create_timer(0.3).timeout
			if is_inside_tree():
				refill_board()
			else:
				_reset_processing_state()
	else:
		_reset_processing_state()
		# Music is now updated from stage, not from board

func handle_level_3_created(critter: Critter):
	if not is_instance_valid(critter):
		return
	
	print("Level 3+ Created! Flying to stage...")
	
	# Notify Game Manager with level
	var game_manager = get_node_or_null("../GameManager")
	if game_manager:
		game_manager.collect_critter(critter.critter_type, critter.critter_level)
	
	# Get target position from StageDisplay
	var stage_bg = get_node_or_null("../StageBackground")
	var target_pos = Vector2(360, -100) # Default fallback
	if stage_bg and stage_bg.has_method("get_global_stage_position"):
		target_pos = stage_bg.get_global_stage_position(critter.critter_type)
	
	# Remove from grid data immediately so it doesn't block gravity
	if critter.grid_x >= 0 and critter.grid_x < GRID_WIDTH and critter.grid_y >= 0 and critter.grid_y < GRID_HEIGHT:
		grid_data[critter.grid_x][critter.grid_y] = null
	
	# Animate flying to stage
	var tween = create_tween()
	if not tween:
		if is_instance_valid(critter):
			critter.queue_free()
		return
	
	tween.set_parallel(true)
	# Use global_position for movement between containers
	tween.tween_property(critter, "global_position", target_pos, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	# Scale up to match stage size
	tween.tween_property(critter, "scale", Vector2(1.2, 1.2), 0.6)
	# Ensure z_index is high so it flies over everything
	critter.z_index = 100
	
	# Wait for animation then free
	await tween.finished
	if is_instance_valid(critter):
		critter.queue_free()

func reset_board():
	print("Resetting board...")
	_start_processing()
	
	# Clear all critters
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			remove_critter(x, y)
	
	# Wait a bit
	var tree = get_tree()
	if tree:
		await tree.create_timer(0.5).timeout
	
	# Regenerate
	generate_board()
	_reset_processing_state()

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
	if processing_matches:
		return
	
	# Handle mouse/touch press (start of interaction)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var grid_x = int(mouse_pos.x / CELL_SIZE)
		var grid_y = int(mouse_pos.y / CELL_SIZE)
		
		if grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT:
			# Store drag start position
			drag_start_pos = mouse_pos
			drag_start_grid_pos = Vector2i(grid_x, grid_y)
			is_dragging = false
	
	# Handle mouse/touch release (end of interaction)
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_dragging:
			# Drag release - already handled in motion
			is_dragging = false
			if selected_critter:
				selected_critter.set_selected(false)
				selected_critter = null
		elif drag_start_grid_pos.x >= 0:
			# This was a tap/click, not a drag
			handle_click(drag_start_grid_pos.x, drag_start_grid_pos.y)
		
		drag_start_grid_pos = Vector2i(-1, -1)
	
	# Handle mouse/touch drag motion
	elif event is InputEventMouseMotion:
		if drag_start_grid_pos.x >= 0 and not is_dragging and not processing_matches:
			var current_pos = get_local_mouse_position()
			var drag_distance = drag_start_pos.distance_to(current_pos)
			
			# Check if we've dragged far enough to trigger a swap
			if drag_distance > DRAG_THRESHOLD:
				is_dragging = true
				var drag_delta = current_pos - drag_start_pos
				
				# Get the dragged critter and show selection border
				var dragged_critter = grid_data[drag_start_grid_pos.x][drag_start_grid_pos.y]
				if dragged_critter:
					# Clear previous selection if any
					if selected_critter and selected_critter != dragged_critter:
						selected_critter.set_selected(false)
					selected_critter = dragged_critter
					selected_critter.set_selected(true)
				
				# Determine primary direction (horizontal or vertical)
				var swap_x = drag_start_grid_pos.x
				var swap_y = drag_start_grid_pos.y
				
				if abs(drag_delta.x) > abs(drag_delta.y):
					# Horizontal drag
					swap_x += 1 if drag_delta.x > 0 else -1
				else:
					# Vertical drag
					swap_y += 1 if drag_delta.y > 0 else -1
				
				# Validate target position
				if swap_x >= 0 and swap_x < GRID_WIDTH and swap_y >= 0 and swap_y < GRID_HEIGHT:
					# Attempt swap (this will set processing_matches if valid)
					if dragged_critter:
						swap_critters(drag_start_grid_pos.x, drag_start_grid_pos.y, swap_x, swap_y)
				
				# Reset drag state immediately
				drag_start_grid_pos = Vector2i(-1, -1)
				is_dragging = false

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
