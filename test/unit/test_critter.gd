extends GutTest

var critter_scene = preload("res://scenes/critter.tscn")

func test_critter_initialization():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	
	assert_eq(critter.critter_type, Critter.CritterType.DRUMS, "Critter type should be DRUMS")
	assert_eq(critter.critter_level, Critter.CritterLevel.LEVEL_1, "Critter level should be LEVEL_1")
	assert_eq(critter.grid_x, 0, "Grid X should be 0")
	assert_eq(critter.grid_y, 0, "Grid Y should be 0")

func test_critter_type_names():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	assert_eq(critter.get_type_name(), "Drums", "Type name should be Drums")
	
	critter.initialize(Critter.CritterType.MELODY, Critter.CritterLevel.LEVEL_1, 0, 0)
	assert_eq(critter.get_type_name(), "Melody", "Type name should be Melody")
	
	critter.initialize(Critter.CritterType.PAD, Critter.CritterLevel.LEVEL_1, 0, 0)
	assert_eq(critter.get_type_name(), "Pad", "Type name should be Pad")

func test_critter_levels():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	for level in [
		Critter.CritterLevel.LEVEL_1, Critter.CritterLevel.LEVEL_2, Critter.CritterLevel.LEVEL_3,
		Critter.CritterLevel.LEVEL_4, Critter.CritterLevel.LEVEL_5
	]:
		critter.initialize(Critter.CritterType.DRUMS, level, 0, 0)
		assert_eq(critter.critter_level, level, "Critter level should be set correctly")

func test_critter_selection():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 0, 0)
	
	# Initially not selected
	assert_false(critter.is_selected, "Critter should not be selected initially")
	
	# Select
	critter.set_selected(true)
	assert_true(critter.is_selected, "Critter should be selected")
	
	# Deselect
	critter.set_selected(false)
	assert_false(critter.is_selected, "Critter should not be selected")

func test_critter_position_update():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.DRUMS, Critter.CritterLevel.LEVEL_1, 3, 4)
	
	var expected_x = float(3 * critter.CELL_SIZE + critter.CELL_SIZE / 2)
	var expected_y = float(4 * critter.CELL_SIZE + critter.CELL_SIZE / 2)
	
	assert_eq(critter.position.x, expected_x, "X position should be calculated correctly")
	assert_eq(critter.position.y, expected_y, "Y position should be calculated correctly")

func test_critter_color_types():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	# Test that each type has a unique color
	var colors = {}
	for type in [Critter.CritterType.MELODY, Critter.CritterType.DRUMS, Critter.CritterType.PAD]:
		assert_true(Critter.TYPE_COLORS.has(type), "Type should have a color defined")
		var color = Critter.TYPE_COLORS[type]
		assert_false(colors.has(color), "Each type should have a unique color")
		colors[color] = true
