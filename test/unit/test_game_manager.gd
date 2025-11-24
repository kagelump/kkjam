extends GutTest

var game_manager_script = preload("res://scripts/game_manager.gd")

func test_game_manager_initialization():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	assert_eq(game_manager.score, 0, "Initial score should be 0")
	assert_eq(game_manager.albums_completed, 0, "Initial albums should be 0")
	assert_eq(game_manager.current_bpm, 100, "Initial BPM should be 100")

func test_collection_state_initialization():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	# All critters should start uncollected
	assert_false(game_manager.collected_critters[Critter.CritterType.BUNNY], "BUNNY should not be collected initially")
	assert_false(game_manager.collected_critters[Critter.CritterType.CAT], "CAT should not be collected initially")
	assert_false(game_manager.collected_critters[Critter.CritterType.FROG], "FROG should not be collected initially")
	assert_false(game_manager.collected_critters[Critter.CritterType.BIRD], "BIRD should not be collected initially")

func test_add_score():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	game_manager.add_score(100)
	assert_eq(game_manager.score, 100, "Score should be 100 after adding 100")
	
	game_manager.add_score(50)
	assert_eq(game_manager.score, 150, "Score should be 150 after adding 50 more")

func test_collect_single_critter():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	watch_signals(game_manager)
	
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	
	assert_true(game_manager.collected_critters[Critter.CritterType.BUNNY], "BUNNY should be collected")
	assert_signal_emitted(game_manager, "critter_collected", "Should emit critter_collected signal")

func test_collect_all_critters_triggers_concert():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	# Mock the grid node
	var mock_grid = Node.new()
	mock_grid.name = "Grid"
	mock_grid.set_script(load("res://scripts/grid.gd"))
	game_manager.add_child(mock_grid)
	
	watch_signals(game_manager)
	
	# Collect first 3 critters - should not trigger concert
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	game_manager.collect_critter(Critter.CritterType.CAT)
	game_manager.collect_critter(Critter.CritterType.FROG)
	
	assert_signal_emit_count(game_manager, "concert_triggered", 0, "Concert should not trigger with only 3 critters")
	
	# Collect 4th critter - should trigger concert
	game_manager.collect_critter(Critter.CritterType.BIRD)
	
	assert_signal_emitted(game_manager, "concert_triggered", "Should emit concert_triggered signal")

func test_concert_increments_album_count():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	# Mock the grid node
	var mock_grid = Node.new()
	mock_grid.name = "Grid"
	mock_grid.set_script(load("res://scripts/grid.gd"))
	game_manager.add_child(mock_grid)
	
	var initial_albums = game_manager.albums_completed
	
	# Collect all critters to trigger concert
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	game_manager.collect_critter(Critter.CritterType.CAT)
	game_manager.collect_critter(Critter.CritterType.FROG)
	game_manager.collect_critter(Critter.CritterType.BIRD)
	
	await wait_frames(2)
	
	assert_eq(game_manager.albums_completed, initial_albums + 1, "Album count should increment by 1")

func test_concert_increases_bpm():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	# Mock the grid node
	var mock_grid = Node.new()
	mock_grid.name = "Grid"
	mock_grid.set_script(load("res://scripts/grid.gd"))
	game_manager.add_child(mock_grid)
	
	var initial_bpm = game_manager.current_bpm
	
	# Trigger concert
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	game_manager.collect_critter(Critter.CritterType.CAT)
	game_manager.collect_critter(Critter.CritterType.FROG)
	game_manager.collect_critter(Critter.CritterType.BIRD)
	
	await wait_frames(2)
	
	assert_eq(game_manager.current_bpm, initial_bpm + 10, "BPM should increase by 10")

func test_reset_stage_clears_collection():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	watch_signals(game_manager)
	
	# Collect some critters
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	game_manager.collect_critter(Critter.CritterType.CAT)
	
	assert_true(game_manager.collected_critters[Critter.CritterType.BUNNY], "BUNNY should be collected")
	assert_true(game_manager.collected_critters[Critter.CritterType.CAT], "CAT should be collected")
	
	# Reset stage
	game_manager.reset_stage()
	
	# All should be uncollected again
	assert_false(game_manager.collected_critters[Critter.CritterType.BUNNY], "BUNNY should not be collected after reset")
	assert_false(game_manager.collected_critters[Critter.CritterType.CAT], "CAT should not be collected after reset")
	assert_false(game_manager.collected_critters[Critter.CritterType.FROG], "FROG should not be collected after reset")
	assert_false(game_manager.collected_critters[Critter.CritterType.BIRD], "BIRD should not be collected after reset")
	
	assert_signal_emitted(game_manager, "stage_reset", "Should emit stage_reset signal")

func test_duplicate_collection_ignored():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	watch_signals(game_manager)
	
	# Collect same critter twice
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	game_manager.collect_critter(Critter.CritterType.BUNNY)
	
	# Signal should only be emitted once
	assert_signal_emit_count(game_manager, "critter_collected", 1, "Signal should only emit once for same critter")
