extends GutTest

# Test drag-to-swap functionality

var grid: Grid
var critter_scene = preload("res://scenes/critter.tscn")

func before_each():
	grid = autofree(Grid.new())
	add_child_autofree(grid)
	
	# Add CritterContainer child
	var container = Node2D.new()
	container.name = "CritterContainer"
	grid.add_child(container)
	
	# Initialize the grid
	grid.initialize_grid()

func test_drag_state_initialization():
	# Verify drag state is properly initialized
	assert_false(grid.is_dragging, "Should not be dragging initially")
	assert_eq(grid.drag_start_grid_pos, Vector2i(-1, -1), "Drag start should be unset")
	assert_eq(grid.DRAG_THRESHOLD, 20.0, "Drag threshold should be 20 pixels")

func test_drag_threshold_value():
	# Verify the drag threshold constant exists and has correct value
	assert_eq(grid.DRAG_THRESHOLD, 20.0, "Drag threshold should prevent accidental swaps")

func test_is_processing_blocks_input():
	# Setup: Set processing flag
	grid.is_processing = true
	
	# Create a mock input event
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	
	# Call _input directly
	grid._input(press_event)
	
	# Drag state should not change when processing
	assert_eq(grid.drag_start_grid_pos, Vector2i(-1, -1), "Should not start drag during processing")

func test_drag_state_variables_exist():
	# Verify all drag-related variables exist by accessing them
	assert_not_null(grid.drag_start_pos, "Grid should have drag_start_pos")
	assert_not_null(grid.drag_start_grid_pos, "Grid should have drag_start_grid_pos")
	assert_false(grid.is_dragging, "Grid should have is_dragging (initialized to false)")
	assert_eq(grid.DRAG_THRESHOLD, 20.0, "Grid should have DRAG_THRESHOLD constant")

func test_grid_cell_size_matches_layout():
	# With 90px cells, grid should be 720px wide (8 cells)
	assert_eq(grid.CELL_SIZE, 90, "Cell size should be 90px for full-width layout")
	assert_eq(grid.GRID_WIDTH * grid.CELL_SIZE, 720, "Grid width should be 720px")
