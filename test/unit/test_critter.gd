extends GutTest

var critter_scene = preload("res://scenes/critter.tscn")

func test_critter_initialization():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	
	assert_eq(critter.critter_type, Critter.CritterType.BUNNY, "Critter type should be BUNNY")
	assert_eq(critter.critter_level, Critter.CritterLevel.LEVEL_1, "Critter level should be LEVEL_1")
	assert_eq(critter.grid_x, 0, "Grid X should be 0")
	assert_eq(critter.grid_y, 0, "Grid Y should be 0")

func test_critter_type_names():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	assert_eq(critter.get_type_name(), "Bunny", "Type name should be Bunny")
	
	critter.initialize(Critter.CritterType.CAT, Critter.CritterLevel.LEVEL_1, 0, 0)
	assert_eq(critter.get_type_name(), "Cat", "Type name should be Cat")
	
	critter.initialize(Critter.CritterType.FROG, Critter.CritterLevel.LEVEL_1, 0, 0)
	assert_eq(critter.get_type_name(), "Frog", "Type name should be Frog")
	
	critter.initialize(Critter.CritterType.BIRD, Critter.CritterLevel.LEVEL_1, 0, 0)
	assert_eq(critter.get_type_name(), "Bird", "Type name should be Bird")

func test_critter_levels():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	# Test all three levels
	for level in [Critter.CritterLevel.LEVEL_1, Critter.CritterLevel.LEVEL_2, Critter.CritterLevel.LEVEL_3]:
		critter.initialize(Critter.CritterType.BUNNY, level, 0, 0)
		assert_eq(critter.critter_level, level, "Critter level should be set correctly")

func test_critter_selection():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	critter.initialize(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 0, 0)
	
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
	
	critter.initialize(Critter.CritterType.BUNNY, Critter.CritterLevel.LEVEL_1, 3, 4)
	
	var expected_x = 3 * critter.CELL_SIZE + critter.CELL_SIZE / 2
	var expected_y = 4 * critter.CELL_SIZE + critter.CELL_SIZE / 2
	
	assert_eq(critter.position.x, expected_x, "X position should be calculated correctly")
	assert_eq(critter.position.y, expected_y, "Y position should be calculated correctly")

func test_critter_color_types():
	var critter = critter_scene.instantiate()
	add_child_autofree(critter)
	
	# Test that each type has a unique color
	var colors = {}
	for type in [Critter.CritterType.BUNNY, Critter.CritterType.CAT, Critter.CritterType.FROG, Critter.CritterType.BIRD]:
		assert_true(Critter.TYPE_COLORS.has(type), "Type should have a color defined")
		var color = Critter.TYPE_COLORS[type]
		assert_false(colors.has(color), "Each type should have a unique color")
		colors[color] = true
