extends GutTest

var critter_scene = preload("res://scenes/critter.tscn")
var game_manager_script = load("res://scripts/game_manager.gd") as Script

class StubGridConcert:
	extends Node2D
	var processing_matches: bool = false

	func reset_board() -> void:
		await get_tree().create_timer(0.01).timeout

func test_concert_triggers_from_check_when_each_type_is_level5():
	var parent = add_child_autofree(Node2D.new())
	var game_manager = autofree(Node.new())
	game_manager.set_script(game_manager_script)
	game_manager.name = "GameManager"
	var grid_stub = autofree(StubGridConcert.new())
	grid_stub.name = "Grid"
	var ui = autofree(Control.new())
	ui.name = "UI"
	var stage = autofree(ColorRect.new())
	stage.set_script(load("res://scripts/stage_display.gd") as Script)
	stage.name = "StageBackground"
	parent.add_child(grid_stub)
	parent.add_child(ui)
	parent.add_child(game_manager)
	parent.add_child(stage)
	for typ in [Critter.CritterType.MELODY, Critter.CritterType.DRUMS, Critter.CritterType.PAD]:
		var c = critter_scene.instantiate()
		stage.add_child(c)
		c.initialize(typ, Critter.CritterLevel.LEVEL_5, -1, -1)
		stage.stage_critters[typ].append(c)
	if game_manager.stage_display == null:
		game_manager.stage_display = stage
	if game_manager.grid == null:
		game_manager.grid = grid_stub
	var before: int = game_manager.albums_completed
	await game_manager.check_concert_condition()
	assert_eq(game_manager.albums_completed, before + 1, "Concert should complete one album")
