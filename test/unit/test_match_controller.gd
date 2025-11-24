extends GutTest

var grid_scene = preload("res://scenes/main.tscn")
var critter_scene = preload("res://scenes/critter.tscn")

class MockGrid:
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
	
	func remove_critter(x: int, y: int):
		if grid_data[x][y] != null:
			var critter = grid_data[x][y]
			grid_data[x][y] = null
			critter.queue_free()
	
	func get_node(path):
		# Mock GameManager
		var mock = Node.new()
		mock.set_script(load("res://scripts/game_manager.gd"))
		return mock

func test_horizontal_match_detection():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a horizontal match of 3 bunnies at level 1
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 3, "Match should contain 3 critters")
	assert_eq(matches[0]["type"], Critter.CritterType.BUNNY, "Match type should be BUNNY")
	assert_eq(matches[0]["level"], Critter.CritterLevel.LEVEL_1, "Match level should be LEVEL_1")

func test_vertical_match_detection():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a vertical match of 3 cats at level 1
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 0, 1)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 0, 2)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 3, "Match should contain 3 critters")
	assert_eq(matches[0]["type"], Critter.CritterType.CAT, "Match type should be CAT")

func test_no_match_with_different_types():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create 3 different types in a row
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.FROG, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 0, "Should find no matches with different types")

func test_no_match_with_different_levels():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create 3 same types but different levels
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_2, 1, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 0, "Should find no matches with different levels")

func test_match_of_four():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a match of 4
	for i in range(4):
		mock_grid.create_critter(Critter.CritterType.FROG, Critter.CritterLevel.LEVEL_1, i, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 4, "Match should contain 4 critters")

func test_match_of_five():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a match of 5
	for i in range(5):
		mock_grid.create_critter(Critter.CritterType.BIRD, Critter.CritterLevel.LEVEL_2, 0, i)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 5, "Match should contain 5 critters")

func test_multiple_matches():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create two separate horizontal matches
	for i in range(3):
		mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, i, 0)
		mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, i, 2)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 2, "Should find exactly 2 matches")

func test_would_create_match_horizontal():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Setup: BB_B pattern (swap positions 2 and 3 to make BBBB)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 2, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 3, 0)
	
	var would_match = match_controller.would_create_match(2, 0, 3, 0)
	
	assert_true(would_match, "Swapping should create a match")

func test_would_not_create_match():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Setup: BC pattern (swap won't create match)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 1, 0)
	
	var would_match = match_controller.would_create_match(0, 0, 1, 0)
	
	assert_false(would_match, "Swapping should not create a match")

func test_check_matches_at_position():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a horizontal match
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	# Check each position in the match
	assert_true(match_controller.check_matches_at_position(0, 0), "Position 0,0 should be part of a match")
	assert_true(match_controller.check_matches_at_position(1, 0), "Position 1,0 should be part of a match")
	assert_true(match_controller.check_matches_at_position(2, 0), "Position 2,0 should be part of a match")
	
	# Check a position not in a match
	mock_grid.create_critter(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 3, 0)
	assert_false(match_controller.check_matches_at_position(3, 0), "Position 3,0 should not be part of a match")
