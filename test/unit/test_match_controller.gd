extends GutTest

var grid_scene = preload("res://scenes/main.tscn")
var critter_scene = preload("res://scenes/critter.tscn")

class MockGrid:
	extends Node2D
	
	const GRID_WIDTH = 8
	const GRID_HEIGHT = 8
	var grid_data: Array = []
	var critter_container
	var game_manager
	
	func _init():
		critter_container = Node2D.new()
		add_child(critter_container)
		
		# Create mock GameManager as sibling so get_node("../GameManager") works
		game_manager = Node.new()
		game_manager.name = "GameManager"
		game_manager.set_script(load("res://scripts/game_manager.gd"))
		
		initialize_grid()
	
	func _ready():
		# Add GameManager as sibling after being added to tree
		if get_parent():
			get_parent().add_child(game_manager)
	
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

	func spawn_critter(x: int, y: int, level: Critter.CritterLevel = Critter.CritterLevel.LEVEL_1) -> Critter:
		var cs = preload("res://scenes/critter.tscn")
		var c = cs.instantiate()
		critter_container.add_child(c)
		var t = randi() % Critter.CritterType.size()
		c.initialize(t, level, x, y)
		grid_data[x][y] = c
		return c

	func handle_level_3_created(_c: Critter) -> void:
		pass

	func add_match_score(points: int) -> void:
		game_manager.add_score(points)

	func remove_critter(x: int, y: int):
		if grid_data[x][y] != null:
			var critter = grid_data[x][y]
			grid_data[x][y] = null
			critter.queue_free()

func test_horizontal_match_detection():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a horizontal match of 3 DRUMS at level 1
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 3, "Match should contain 3 critters")
	assert_eq(matches[0]["type"], Critter.CritterType.DRUMS, "Match type should be DRUMS")
	assert_eq(matches[0]["level"], Critter.CritterLevel.LEVEL_1, "Match level should be LEVEL_1")

func test_vertical_match_detection():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a vertical match of 3 MELODY at level 1
	mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 0, 1)
	mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 0, 2)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 3, "Match should contain 3 critters")
	assert_eq(matches[0]["type"], Critter.CritterType.MELODY, "Match type should be MELODY")

func test_no_match_with_different_types():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create 3 different types in a row
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.PAD, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 0, "Should find no matches with different types")

func test_no_match_with_different_levels():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create 3 same types but different levels
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_2, 1, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 0, "Should find no matches with different levels")

func test_match_of_four():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a match of 4
	for i in range(4):
		mock_grid.create_critter(Critter.CritterType.PAD, Critter.CritterLevel.LEVEL_1, i, 0)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 4, "Match should contain 4 critters")

func test_match_of_five():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a match of 5
	for i in range(5):
		mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_2, 0, i)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 1, "Should find exactly 1 match")
	assert_eq(matches[0]["critters"].size(), 5, "Match should contain 5 critters")

func test_multiple_matches():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create two separate horizontal matches
	for i in range(3):
		mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, i, 0)
		mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, i, 2)
	
	var matches = match_controller.find_matches()
	
	assert_eq(matches.size(), 2, "Should find exactly 2 matches")

func test_l_shape_resolves_to_one_merged_critter():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	var match_controller = MatchController.new(mock_grid)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 2, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 1)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 2)
	var matches = match_controller.find_matches()
	assert_eq(matches.size(), 2, "L-shape is two line matches that share a corner")
	match_controller.resolve_matches(matches, Vector2(-1, -1))
	var count = 0
	var only: Critter = null
	for x in range(8):
		for y in range(8):
			if mock_grid.grid_data[x][y] != null:
				count += 1
				only = mock_grid.grid_data[x][y]
	assert_eq(count, 1, "Overlapping line matches should merge into a single L2")
	assert_eq(only.critter_level, Critter.CritterLevel.LEVEL_2)

func test_disjoint_line_matches_resolve_separately():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	var match_controller = MatchController.new(mock_grid)
	for i in range(3):
		mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, i, 0)
		mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, i, 2)
	var matches = match_controller.find_matches()
	assert_eq(matches.size(), 2)
	match_controller.resolve_matches(matches, Vector2(-1, -1))
	var count = 0
	for x in range(8):
		for y in range(8):
			if mock_grid.grid_data[x][y] != null:
				count += 1
	assert_eq(count, 2, "Non-overlapping matches produce two merged critters")

func test_would_create_match_horizontal():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Setup: BB_B pattern (swap positions 2 and 3 to make BBBB)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 2, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 3, 0)
	
	var would_match = match_controller.would_create_match(2, 0, 3, 0)
	
	assert_true(would_match, "Swapping should create a match")

func test_would_not_create_match():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Setup: BC pattern (swap won't create match)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 1, 0)
	
	var would_match = match_controller.would_create_match(0, 0, 1, 0)
	
	assert_false(would_match, "Swapping should not create a match")

func test_check_matches_at_position():
	var mock_grid = autofree(MockGrid.new())
	add_child_autofree(mock_grid)
	
	var match_controller = MatchController.new(mock_grid)
	
	# Create a horizontal match
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 1, 0)
	mock_grid.create_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 2, 0)
	
	# Check each position in the match
	assert_true(match_controller.check_matches_at_position(0, 0), "Position 0,0 should be part of a match")
	assert_true(match_controller.check_matches_at_position(1, 0), "Position 1,0 should be part of a match")
	assert_true(match_controller.check_matches_at_position(2, 0), "Position 2,0 should be part of a match")
	
	# Check a position not in a match
	mock_grid.create_critter(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 3, 0)
	assert_false(match_controller.check_matches_at_position(3, 0), "Position 3,0 should not be part of a match")
