extends GutTest

# Integration tests for the full game flow

var main_scene = preload("res://scenes/main.tscn")

func test_scene_loads():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	assert_not_null(scene, "Main scene should load")

func test_scene_has_required_nodes():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	var grid = scene.get_node("Grid")
	var game_manager = scene.get_node("GameManager")
	var ui = scene.get_node("UI")
	
	assert_not_null(grid, "Grid node should exist")
	assert_not_null(game_manager, "GameManager node should exist")
	assert_not_null(ui, "UI node should exist")

func test_status_label_is_current_and_below_grid():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	await wait_frames(5)
	
	var grid_background = scene.get_node("GridBackground") as ColorRect
	var score_label = scene.get_node("UI/ScoreLabel") as Label
	var instructions_label = scene.get_node("UI/InstructionsLabel") as Label
	
	assert_not_null(score_label, "ScoreLabel should exist")
	assert_false(score_label.text.contains("Phase 1 MVP"), "ScoreLabel should not show stale Phase 1 copy")
	assert_true(score_label.text.contains("Score: 0"), "ScoreLabel should show current score")
	assert_true(score_label.text.contains("Albums: 0"), "ScoreLabel should show album count")
	assert_true(score_label.offset_top >= grid_background.offset_bottom, "ScoreLabel should sit below the grid")
	assert_true(instructions_label.text.contains("type and level"), "Instructions should describe current merge rules")

func test_grid_initializes_with_critters():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	await wait_frames(5)
	
	var grid = scene.get_node("Grid")
	var critter_count = 0
	
	# Count non-null critters
	for x in range(grid.GRID_WIDTH):
		for y in range(grid.GRID_HEIGHT):
			if grid.grid_data[x][y] != null:
				critter_count += 1
	
	assert_eq(critter_count, grid.GRID_WIDTH * grid.GRID_HEIGHT, "Grid should be fully populated")

func test_no_initial_matches():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	await wait_frames(5)
	
	var grid = scene.get_node("Grid")
	var matches = grid.match_controller.find_matches()
	
	assert_eq(matches.size(), 0, "There should be no initial matches")

func test_grid_contains_only_level_1_critters_initially():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	await wait_frames(5)
	
	var grid = scene.get_node("Grid")
	
	for x in range(grid.GRID_WIDTH):
		for y in range(grid.GRID_HEIGHT):
			var critter = grid.grid_data[x][y]
			if critter != null:
				assert_eq(critter.critter_level, Critter.CritterLevel.LEVEL_1, 
					"All initial critters should be Level 1")

func test_grid_contains_all_critter_types():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	await wait_frames(5)
	
	var grid = scene.get_node("Grid")
	var types_found = {}
	
	for x in range(grid.GRID_WIDTH):
		for y in range(grid.GRID_HEIGHT):
			var critter = grid.grid_data[x][y]
			if critter != null:
				types_found[critter.critter_type] = true
	
	# We should have all 3 types (high probability with 64 cells and 3 types)
	assert_eq(types_found.size(), 3, "Should have all 3 critter types")

func test_game_manager_references_grid():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	await wait_frames(5)
	
	var game_manager = scene.get_node("GameManager")
	
	assert_not_null(game_manager.grid, "GameManager should have reference to Grid")

func test_stage_display_connects_to_game_manager():
	var scene = main_scene.instantiate()
	add_child_autofree(scene)
	
	await wait_frames(5)
	
	var game_manager = scene.get_node("GameManager")
	var stage_bg = scene.get_node("StageBackground")
	
	# Check if signals are connected
	assert_true(game_manager.critter_collected.is_connected(stage_bg._on_critter_collected), 
		"Stage should be connected to critter_collected signal")
	assert_true(game_manager.stage_reset.is_connected(stage_bg._on_stage_reset), 
		"Stage should be connected to stage_reset signal")
