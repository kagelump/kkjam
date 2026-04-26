extends GutTest

var critter_scene = preload("res://scenes/critter.tscn")
var stage_script = load("res://scripts/stage_display.gd") as Script

# Stage fly-in targets use the same count-based layout; successive planned positions
# (before the critter is appended) must be distinct.
func test_stage_flyin_positions_stay_distinct_for_many_same_type():
	var stage = ColorRect.new()
	stage.set_script(stage_script)
	var gm = Node.new()
	gm.set_script(load("res://scripts/game_manager.gd"))
	gm.name = "GameManager"
	var parent = add_child_autofree(Node2D.new())
	parent.add_child(gm)
	parent.add_child(stage)
	var seen: Dictionary = {}
	for i in 7:
		var p = stage.get_global_stage_position(Critter.CritterType.DRUMS)
		var k = "%.1f,%.1f" % [p.x, p.y]
		assert_false(seen.has(k), "Position should not repeat before reorganize (step %d)" % i)
		seen[k] = true
		var c = critter_scene.instantiate()
		stage.add_child(c)
		c.initialize(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_3, -1, -1)
		stage.stage_critters[Critter.CritterType.DRUMS].append(c)

func test_get_max_level_for_type_finds_highest():
	var stage = ColorRect.new()
	stage.set_script(stage_script)
	var gm = Node.new()
	gm.set_script(load("res://scripts/game_manager.gd"))
	gm.name = "GameManager"
	var parent = add_child_autofree(Node2D.new())
	parent.add_child(gm)
	parent.add_child(stage)
	var c1 = critter_scene.instantiate()
	stage.add_child(c1)
	c1.initialize(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_4, -1, -1)
	stage.stage_critters[Critter.CritterType.MELODY].append(c1)
	assert_eq(
		stage.get_max_level_for_type(Critter.CritterType.MELODY),
		Critter.CritterLevel.LEVEL_4
	)
