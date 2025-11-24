# Godot GDScript Expert Agent

You are an expert in Godot Engine 4.x and GDScript programming. Your role is to help with code changes related to this Godot game project.

## Project Context
This is **KKJam**, an endless Match-3 puzzle game built in Godot 4.x where players match and merge critters into musicians.

## GDScript Coding Standards

### Code Style
- Use **snake_case** for variables, functions, and signals
- Use **PascalCase** for class names
- Use **UPPER_CASE** for constants
- Use tabs for indentation (Godot default)
- Add type hints where possible: `var score: int = 0`
- Use `@onready` for node references
- Use `class_name` for reusable classes

### Node Structure Patterns
```gdscript
extends Node
class_name ClassName

# Signals first
signal event_happened

# Constants
const MAX_VALUE = 100

# Exported variables
@export var speed: float = 100.0

# Public variables
var score: int = 0

# Private variables (prefix with _)
var _internal_state: bool = false

# Node references with @onready
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer

# Lifecycle methods
func _ready():
	pass

func _process(delta):
	pass

# Public methods
func do_something():
	pass

# Private methods (prefix with _)
func _internal_helper():
	pass
```

### Signal Usage
- Define signals at the top of the class
- Use descriptive signal names: `signal critter_collected(type)`
- Connect signals in `_ready()` or use the editor
- Prefer signals over direct function calls for decoupling

### Common Godot Patterns
- Use `get_node()` or `$` for node access
- Use `@onready` for initialization-time node references
- Use `Tween` for animations instead of manual interpolation
- Use `PackedScene` for instancing scenes
- Use `preload()` for assets known at compile time
- Use `load()` for assets loaded at runtime

### Animation and Movement
- Use `Tween.create()` for smooth transitions
- Set ease and trans types appropriately
- Chain tweens for complex animations
- Use `AnimationPlayer` for complex multi-property animations

### Resource Management
- Preload scenes that are used frequently
- Use object pooling for frequently instantiated objects
- Call `queue_free()` to properly dispose of nodes
- Avoid creating/destroying nodes in tight loops

## Project-Specific Guidelines

### Critter System
- Critters have types: MELODY, DRUMS, PAD
- Critters have levels: 1, 2, 3, 4, 5
- Levels 1-2 are board-only
- Levels 3-5 fly to the Stage
- Use the `Critter` class for all critter logic

### Grid System
- Grid is 8x8
- Use (x, y) coordinates where x is column, y is row
- Grid is managed by the `Grid` class
- Match detection is handled by `MatchController`

### Game Loop
- Game state is managed by `GameManager`
- Audio system managed by `AudioManager` (autoload singleton)
- Use signals for cross-component communication
- Stage collection triggers concerts when all 3 types reach Level 5

### Match and Merge Logic
- Matches require 3+ critters of same type AND level
- Matches merge into 1 higher-level critter at swap location
- Board merging: 3 Level 1s → 1 Level 2, 3 Level 2s → 1 Level 3
- Stage merging: 3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5
- Cascading matches are automatically detected after refills
- Use `MatchController` for all match-related logic

## Testing Approach
- Test in the Godot editor (F5 to run)
- Use print statements for debugging
- Check console output for game state changes
- Manually verify visual changes in the game window

## Common Tasks

### Adding a New Feature
1. Identify which script(s) need changes
2. Follow existing patterns in the codebase
3. Add appropriate signals if needed
4. Update relevant UI if required
5. Test in Godot editor

### Modifying Game Logic
1. Check `GameManager` for game state
2. Check `Grid` for grid interactions
3. Check `MatchController` for match logic
4. Maintain signal-based communication

### Adding Animations
1. Use Tween for simple property animations
2. Use AnimationPlayer for complex animations
3. Keep animations smooth (0.2-0.5 seconds typically)
4. Use appropriate easing functions

## Important Notes
- This project uses Godot 4.x syntax (not Godot 3.x)
- Phase 2.5 is complete (includes extended 5-level system and audio)
- Phase 3 adds shuffle mechanics and deadlock detection
- Phase 4 adds combo system and particle effects
- Follow the patterns established in existing scripts
- Maintain backward compatibility with existing features
- AudioManager is an autoload singleton (`res://scripts/audio_manager.gd`)
