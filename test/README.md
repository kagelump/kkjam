# Test Suite Documentation

## Overview

This test suite provides comprehensive coverage for the KKJam Match-3 game using the GUT (Godot Unit Test) framework.

## Running Tests

### Using Makefile (Recommended)
```bash
make test           # Run all tests
make test-unit      # Run unit tests only
make test-int       # Run integration tests only
```

### Using GUT CLI Directly
```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/

# Run specific test directory
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/

# Run specific test file
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/test_critter.gd
```

### In Godot Editor
1. Open the project in Godot
2. Go to the bottom panel and select the "GUT" tab
3. Click "Run All" to run all tests

## Current Status
See `make test` for the live count. Baseline: **56 tests** (47 unit, 9 integration), per `AGENTS.md`.

## Test Organization

### Unit Tests (`test/unit/`)

Unit tests focus on testing individual components in isolation.

#### `test_critter.gd`
Tests the Critter class which represents individual game pieces.

**Test Cases:**
- `test_critter_initialization()` - Verifies proper initialization with type, level, and grid position
- `test_critter_type_names()` - Validates that each critter type has the correct name (MELODY, DRUMS, PAD)
- `test_critter_levels()` - Tests all three levels (LEVEL_1, LEVEL_2, LEVEL_3)
- `test_critter_selection()` - Validates selection and deselection mechanics
- `test_critter_position_update()` - Ensures correct position calculation based on grid coordinates
- `test_critter_color_types()` - Verifies each type has a unique color assigned

#### `test_match_controller.gd`
Tests the MatchController class responsible for detecting and resolving matches.

**Test Cases:**
- `test_horizontal_match_detection()` - Tests detection of horizontal matches (3+ in a row)
- `test_vertical_match_detection()` - Tests detection of vertical matches (3+ in a column)
- `test_no_match_with_different_types()` - Ensures different types don't match
- `test_no_match_with_different_levels()` - Ensures different levels don't match
- `test_match_of_four()` - Validates matches with 4 critters
- `test_match_of_five()` - Validates matches with 5 critters
- `test_multiple_matches()` - Tests detection of multiple simultaneous matches
- `test_would_create_match_horizontal()` - Tests match prediction before swap
- `test_would_not_create_match()` - Tests invalid swap prediction
- `test_check_matches_at_position()` - Tests position-specific match checking

#### `test_game_manager.gd`
Tests the GameManager class that handles game state and progression.

**Test Cases:**
- `test_game_manager_initialization()` - Verifies initial state (score, albums, BPM)
- `test_collection_state_initialization()` - Ensures all critters start uncollected
- `test_add_score()` - Tests score accumulation
- `test_collect_single_critter()` - Tests collecting a single critter and signal emission
- `test_collect_all_critters_triggers_concert()` - Validates concert trigger when all 3 types reach Level 5
- `test_concert_increments_album_count()` - Ensures album count increases after concert
- `test_concert_increases_bpm()` - Validates difficulty scaling (BPM increase)
- `test_reset_stage_clears_collection()` - Tests stage reset functionality
- `test_duplicate_collection_ignored()` - Ensures duplicate collections are handled correctly

### Integration Tests (`test/integration/`)

Integration tests verify that components work together correctly.

#### `test_game_flow.gd`
Tests the overall game flow and component interactions.

**Test Cases:**
- `test_scene_loads()` - Verifies the main scene loads without errors
- `test_scene_has_required_nodes()` - Checks all required nodes exist in scene tree
- `test_grid_initializes_with_critters()` - Ensures grid is fully populated on start
- `test_no_initial_matches()` - Validates no-initial-matches algorithm works
- `test_grid_contains_only_level_1_critters_initially()` - Confirms all start as Level 1
- `test_grid_contains_all_critter_types()` - Verifies variety in critter types
- `test_game_manager_references_grid()` - Tests proper node references
- `test_stage_display_connects_to_game_manager()` - Validates signal connections

## Running Tests

### In Godot Editor
1. Open the project in Godot 4.2+
2. Go to `Project → Tools → Gut`
3. Click "Run All" to execute all tests
4. View results in the GUT panel

### From Command Line
Use `make test` (recommended) or the GUT examples at the top of this file.

### In CI/CD
Tests automatically run via GitHub Actions on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

See `.github/workflows/tests.yml` for CI configuration.

## Writing New Tests

### Test File Naming
- Unit tests: `test/unit/test_<class_name>.gd`
- Integration tests: `test/integration/test_<feature_name>.gd`

### Test Structure
```gdscript
extends GutTest

# Test function naming: test_<what_is_being_tested>
func test_example():
    # Arrange - Set up test conditions
    var object = create_test_object()
    
    # Act - Execute the code being tested
    var result = object.do_something()
    
    # Assert - Verify the result
    assert_eq(result, expected_value, "Description of what should happen")
```

### Common GUT Assertions
- `assert_eq(a, b, msg)` - Assert equality
- `assert_ne(a, b, msg)` - Assert inequality
- `assert_true(value, msg)` - Assert true
- `assert_false(value, msg)` - Assert false
- `assert_null(value, msg)` - Assert null
- `assert_not_null(value, msg)` - Assert not null
- `assert_signal_emitted(object, signal_name, msg)` - Assert signal was emitted
- `assert_signal_emit_count(object, signal_name, count, msg)` - Assert signal emission count

### Memory Management
- Use `add_child_autofree(node)` to automatically free nodes after test
- Use `autofree(object)` to automatically free objects after test
- Always clean up resources to prevent memory leaks

### Async Testing
```gdscript
func test_async_operation():
    var object = create_test_object()
    object.start_async_operation()
    
    # Wait for a certain number of frames
    await wait_frames(5)
    
    # Or wait for a signal
    await wait_for_signal(object.operation_completed, 2.0)
    
    assert_true(object.is_complete)
```

## Test Coverage

Current test coverage includes:

### Core Game Components
- ✅ Critter (initialization, types, levels, selection, positioning)
- ✅ MatchController (match detection, validation, prediction)
- ✅ GameManager (scoring, collection, concert mechanics, difficulty scaling)
- ✅ Game Flow (scene loading, initialization, component integration)

### Remaining Coverage Gaps
- ⏳ Grid class (swap mechanics, gravity, refill)
- ⏳ StageDisplay class (visual representation, animations)
- ⏳ UI interactions
- ⏳ Audio system (when implemented)
- ⏳ Shuffle mechanics (when implemented)

## Continuous Integration

Tests run automatically on every push and pull request via GitHub Actions. The workflow:
1. Downloads Godot 4.2.2
2. Runs all tests headlessly
3. Uploads test results as artifacts
4. Fails the build if any tests fail

## Best Practices

1. **Keep tests focused** - Each test should verify one specific behavior
2. **Use descriptive names** - Test names should clearly describe what is being tested
3. **Arrange-Act-Assert pattern** - Structure tests clearly
4. **Test edge cases** - Don't just test the happy path
5. **Clean up resources** - Use autofree to prevent memory leaks
6. **Avoid test interdependence** - Tests should be able to run in any order
7. **Use meaningful assertions** - Provide clear messages for failures
8. **Mock dependencies** - Isolate the code under test from external dependencies

## Debugging Failed Tests

When a test fails:
1. Read the assertion message - it tells you what was expected vs. what happened
2. Check the test output for stack traces or error messages
3. Run the specific test in isolation to reproduce
4. Use print statements or the debugger to inspect state
5. Verify test assumptions are correct
6. Check if recent changes broke the test

## Resources

- [GUT Documentation](https://gut.readthedocs.io/en/latest/)
- [Godot Testing Best Practices](https://docs.godotengine.org/en/stable/engine_details/architecture/unit_testing.html)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
