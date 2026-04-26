extends GutTest

var game_manager_script = preload("res://scripts/game_manager.gd")

func test_game_manager_initialization():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	assert_eq(game_manager.score, 0, "Initial score should be 0")
	assert_eq(game_manager.albums_completed, 0, "Initial albums should be 0")
	assert_eq(game_manager.current_bpm, 100, "Initial BPM should be 100")

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
	
	game_manager.collect_critter(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_3)
	
	assert_signal_emitted(game_manager, "critter_collected", "Should emit critter_collected signal")

func test_concert_increments_album_count():
	# Create parent node
	var parent = autofree(Node.new())
	add_child(parent)
	
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	game_manager.name = "GameManager"
	
	# Create stub Grid
	var grid_stub = autofree(Node2D.new())
	var container = Node2D.new()
	container.name = "CritterContainer"
	grid_stub.add_child(container)
	grid_stub.set_script(preload("res://scripts/grid.gd"))
	grid_stub.name = "Grid"
	
	var ui_stub = autofree(Control.new())
	ui_stub.name = "UI"
	
	parent.add_child(game_manager)
	parent.add_child(grid_stub)
	parent.add_child(ui_stub)
	
	var initial_albums = game_manager.albums_completed
	
	await game_manager.trigger_concert()
	
	assert_eq(game_manager.albums_completed, initial_albums + 1, "Album count should increment by 1")

func test_concert_increases_bpm():
	# Create parent node
	var parent = autofree(Node.new())
	add_child(parent)
	
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	game_manager.name = "GameManager"
	
	# Create stub Grid
	var grid_stub = autofree(Node2D.new())
	var container = Node2D.new()
	container.name = "CritterContainer"
	grid_stub.add_child(container)
	grid_stub.set_script(preload("res://scripts/grid.gd"))
	grid_stub.name = "Grid"
	
	var ui_stub = autofree(Control.new())
	ui_stub.name = "UI"
	
	parent.add_child(game_manager)
	parent.add_child(grid_stub)
	parent.add_child(ui_stub)
	
	var initial_bpm = game_manager.current_bpm
	
	await game_manager.trigger_concert()
	
	assert_eq(game_manager.current_bpm, initial_bpm + 10, "BPM should increase by 10")

func test_reset_stage_emits_signal():
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	
	watch_signals(game_manager)
	
	# Reset stage
	game_manager.reset_stage()
	
	assert_signal_emitted(game_manager, "stage_reset", "Should emit stage_reset signal")
