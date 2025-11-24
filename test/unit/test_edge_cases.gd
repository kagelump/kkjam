extends GutTest

# Additional unit tests for edge cases and specific scenarios

var critter_scene = preload("res://scenes/critter.tscn")

# Test Critter edge cases
func test_critter_move_animation():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	var initial_pos = critter.position
	
	# Start moving
	critter.move_to_grid_position(3, 4, 0.1)
	assert_true(critter.is_moving, "Critter should be marked as moving")
	
	# Wait for animation to complete
	await wait_seconds(0.15)
	
	assert_false(critter.is_moving, "Critter should not be marked as moving after animation")
	assert_ne(critter.position, initial_pos, "Critter position should have changed")

func test_all_critter_type_combinations():
	# Test all combinations of types and levels
	for type in [Critter.CritterType.BUNNY, Critter.CritterType.CAT, Critter.CritterType.FROG, Critter.CritterType.BIRD]:
		for level in [Critter.CritterLevel.LEVEL_1, Critter.CritterLevel.LEVEL_2, Critter.CritterLevel.LEVEL_3]:
			var critter = critter_scene.instantiate()
			add_child_autofree(critter)
			
			critter.initialize(type, level, 0, 0)
			
			assert_eq(critter.critter_type, type, "Type should be set correctly")
			assert_eq(critter.critter_level, level, "Level should be set correctly")
			
			# Verify sprite exists and is visible
			assert_not_null(critter.sprite, "Sprite should exist")
			assert_not_null(critter.level_label, "Level label should exist")

func test_critter_size_increases_with_level():
	var sizes = []
	
	for level in [Critter.CritterLevel.LEVEL_1, Critter.CritterLevel.LEVEL_2, Critter.CritterLevel.LEVEL_3]:
		var critter = critter_scene.instantiate()
		add_child_autofree(critter)
		
		critter.initialize(Critter.CritterType.BUNNY, level, 0, 0)
		
		await wait_frames(1)
		
		if critter.sprite:
			sizes.append(critter.sprite.size.x)
	
	# Verify sizes increase
	if sizes.size() == 3:
		assert_true(sizes[1] > sizes[0], "Level 2 should be larger than Level 1")
		assert_true(sizes[2] > sizes[1], "Level 3 should be larger than Level 2")

# Test GameManager edge cases
func test_concert_triggers_exactly_once_with_duplicates():
	# Create a proper node hierarchy
	var parent = autofree(Node.new())
	add_child(parent)
	
	var game_manager = autofree(Node.new())
	game_manager.set_script(preload("res://scripts/game_manager.gd"))
	game_manager.name = "GameManager"
	
	# Create a stub Grid with reset_board method
	var grid_stub = autofree(double(Grid).new())
	stub(grid_stub, "reset_board").to_do_nothing()
	grid_stub.name = "Grid"
	
	# Create stub UI
	var ui_stub = autofree(Control.new())
	ui_stub.name = "UI"
	
	parent.add_child(game_manager)
	parent.add_child(grid_stub)
	parent.add_child(ui_stub)
	
	watch_signals(game_manager)
	
	# Collect all 4 types
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	game_manager.collect_critter(Critter.CritterType.CAT)
	game_manager.collect_critter(Critter.CritterType.FROG)
	game_manager.collect_critter(Critter.CritterType.BIRD)
	
	await wait_physics_frames(2)
	
	# Try to collect again (should not trigger another concert)
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	game_manager.collect_critter(Critter.CritterType.CAT)
	
	await wait_physics_frames(2)
	
	# Should only have triggered concert once
	assert_signal_emit_count(game_manager, "concert_triggered", 1, 
		"Concert should only trigger once despite duplicate collections")

func test_bpm_scaling_multiple_albums():
	# Create a proper node hierarchy
	var parent = autofree(Node.new())
	add_child(parent)
	
	var game_manager = autofree(Node.new())
	game_manager.set_script(preload("res://scripts/game_manager.gd"))
	game_manager.name = "GameManager"
	
	# Create a stub Grid with reset_board method
	var grid_stub = autofree(double(Grid).new())
	stub(grid_stub, "reset_board").to_do_nothing()
	grid_stub.name = "Grid"
	
	# Create stub UI
	var ui_stub = autofree(Control.new())
	ui_stub.name = "UI"
	
	parent.add_child(game_manager)
	parent.add_child(grid_stub)
	parent.add_child(ui_stub)
	
	var initial_bpm = game_manager.current_bpm
	
	# Complete 3 albums
	for i in range(3):
		game_manager.collect_critter(Critter.CritterType.BUNNY)
		game_manager.collect_critter(Critter.CritterType.CAT)
		game_manager.collect_critter(Critter.CritterType.FROG)
		game_manager.collect_critter(Critter.CritterType.BIRD)
		await wait_physics_frames(2)
	
	# BPM should have increased by 30 (10 per album)
	assert_eq(game_manager.current_bpm, initial_bpm + 30, 
		"BPM should increase by 10 for each album completed")
	assert_eq(game_manager.albums_completed, 3, 
		"Should have completed 3 albums")

# Test MatchController edge cases
class MockGridForEdgeCases:
	extends Node2D
	
	const GRID_WIDTH = 8
	const GRID_HEIGHT = 8
	var grid_data: Array = []
	var critter_container
	
	func _init():
		critter_container = Node2D.new()
		add_child(critter_container)
		initialize_grid()
	
	func initialize_grid():
		grid_data.clear()
		for x in range(GRID_WIDTH):
			grid_data.append([])
			for y in range(GRID_HEIGHT):
				grid_data[x].append(null)
	
	func create_critter(type, level, x, y):
		var critter_scene = preload("res://scenes/critter.tscn")
		var critter = critter_scene.instantiate()
		critter_container.add_child(critter)
		critter.initialize(type, level, x, y)
		grid_data[x][y] = critter
		return critter
	
	@warning_ignore("native_method_override")
	func get_node(_path):
		var mock = Node.new()
		mock.set_script(load("res://scripts/game_manager.gd"))
		return mock

func test_l_shaped_matches_dont_count():
	# L-shaped formations should not be considered matches
	var mock_grid = autofree(MockGridForEdgeCases.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create an L shape:
	# B B B
	# B
	# B
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 2, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 1)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 2)
	
	var matches = match_controller.find_matches()
	
	# Should find 2 separate matches (one horizontal, one vertical)
	assert_eq(matches.size(), 2, "L-shape should be detected as 2 separate lines")

func test_t_shaped_matches():
	# T-shaped formations should be detected as multiple matches
	var mock_grid = autofree(MockGridForEdgeCases.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a T shape:
	# C C C
	#   C
	#   C
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 2, 0)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 1, 1)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 1, 2)
	
	var matches = match_controller.find_matches()
	
	# Should find 2 separate matches
	assert_eq(matches.size(), 2, "T-shape should be detected as 2 separate lines")

func test_edge_position_matches():
	# Test matches at the edges of the grid
	var mock_grid = autofree(MockGridForEdgeCases.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create match at top edge (y = 0)
	for x in range(3):
		mock_grid.create_critter(Critter.CritterType.FROG, Critter.CritterLevel.LEVEL_1, x, 0)
	
	# Create match at right edge (x = 7)
	for y in range(3):
		mock_grid.create_critter(Critter.CritterType.BIRD, Critter.CritterLevel.LEVEL_1, 7, y)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 2, "Should detect matches at grid edges")

func test_corner_matches():
	# Test matches that include corner positions
	var mock_grid = autofree(MockGridForEdgeCases.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create match in top-left corner
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_2, 0, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_2, 0, 1)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_2, 0, 2)
	
	# Create match in bottom-right corner
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_2, 7, 7)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_2, 6, 7)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_2, 5, 7)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 2, "Should detect matches in corners")
