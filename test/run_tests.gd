extends SceneTree

# Command line test runner for GUT
# This script can be executed with: godot --headless -s test/run_tests.gd

func _init():
	var gut = load("res://addons/gut/gut.gd").new()
	add_child(gut)
	
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
