extends SceneTree

# Command line test runner for GUT
# This script can be executed with: godot --headless -s test/run_tests.gd
# 
# However, it's recommended to use GUT's built-in CLI instead:
# godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/,res://test/integration/

func _init():
	var max_iter := 20
	var iter := 0
	
	# Wait for main loop to initialize
	while(Engine.get_main_loop() == null and iter < max_iter):
		await create_timer(.01).timeout
		iter += 1
	
	if(Engine.get_main_loop() == null):
		push_error('Main loop did not start in time.')
		quit(1)
		return
	
	var gut = load("res://addons/gut/gut.gd").new()
	get_root().add_child(gut)
	
	# Configure GUT
	gut.add_directory("res://test/unit")
	gut.add_directory("res://test/integration")
	gut.set_yield_between_tests(true)
	gut.set_should_maximize(false)
	gut.set_should_print_to_console(true)
	gut.set_log_level(gut.LOG_LEVEL_ALL_ASSERTS)
	
	# Run tests
	gut.test_scripts()
	
	# Wait for tests to complete
	await gut.tests_finished
	
	# Exit with proper code
	if gut.get_fail_count() > 0:
		quit(1)
	else:
		quit(0)
