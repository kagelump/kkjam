extends SceneTree

# Command line test runner for GUT
# 
# RECOMMENDED: Use GUT's built-in CLI instead:
#   godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/
#
# This file exists for reference but the official GUT CLI is more reliable.

func _init():
	# Wait for main loop
	var max_iter := 20
	var iter := 0
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
	
	# Connect to finished signal
	gut.tests_finished.connect(_on_tests_finished.bind(gut))
	
	# Run tests
	gut.test_scripts()

func _on_tests_finished(gut):
	# Exit with proper code
	if gut.get_fail_count() > 0:
		quit(1)
	else:
		quit(0)
