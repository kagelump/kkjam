# KKJam Agent Documentation

This document consolidates all agent-specific information for the KKJam project. It combines project context, coding guidelines, testing procedures, and game design principles to provide comprehensive guidance for development.

---

## Table of Contents
1. [Project Context](#project-context)
2. [Godot GDScript Expert](#godot-gdscript-expert)
3. [Testing Expert](#testing-expert)
4. [Game Design Expert](#game-design-expert)

---

# Project Context

## Project Overview
**KKJam** is an endless Match-3 puzzle game built in Godot 4.x where players match and merge critters into musicians to create the ultimate band. Players create Level 5 critters of all 3 types (Melody, Drums, Pad) to trigger concerts and progress through the game.

## Repository Structure

```
/home/runner/work/kkjam/kkjam/
├── .git/                    # Git repository data
├── .github/
│   ├── agents/              # GitHub Copilot agent configurations
│   │   ├── godot-expert.md  # GDScript coding guidance
│   │   ├── game-design.md   # Game design principles
│   │   ├── testing.md       # Testing procedures
│   │   └── project-context.md # Project context
│   └── workflows/
│       └── deploy.yml       # GitHub Pages deployment automation
├── .gitignore               # Git ignore rules
├── addons/
│   └── gut/                 # GUT test framework
├── test/                    # Test suite
│   ├── unit/                # Unit tests
│   │   ├── test_critter.gd
│   │   ├── test_match_controller.gd
│   │   ├── test_game_manager.gd
│   │   ├── test_edge_cases.gd
│   │   ├── test_audio_manager.gd
│   │   └── test_drag_swap.gd
│   ├── integration/         # Integration tests
│   │   └── test_game_flow.gd
│   ├── run_tests.gd         # Custom test runner
│   └── README.md            # Test documentation
├── scenes/                  # Godot scene files (.tscn)
│   ├── main.tscn            # Main game scene
│   └── critter.tscn         # Reusable critter scene
├── scripts/                 # GDScript files (.gd)
│   ├── game_manager.gd      # Game state and orchestration
│   ├── grid.gd              # Grid management and input handling
│   ├── critter.gd           # Critter properties and behavior
│   ├── match_controller.gd  # Match detection and merge logic
│   ├── stage_display.gd     # Stage UI for Level 3+ critters
│   └── audio_manager.gd     # BGM and SFX management
├── Makefile                 # Development commands (test, run, export, clean)
├── export_presets.cfg       # Godot export configuration for web
├── icon.svg                 # Project icon
├── project.godot            # Godot project configuration
├── README.md                # Project overview and status
├── TODO.md                  # Complete game design document
├── BGM/                     # Audio files (music layers and SFX)
│   ├── PLAN.md
│   ├── COMPRESSION_GUIDE.md
│   ├── c1_layer1.mp3, c1_layer2.mp3, c1_layer3.mp3  # Melody layers
│   ├── c2_layer1.mp3, c2_layer2.mp3, c2_layer3.mp3  # Drums layers
│   ├── c3_layer1.mp3, c3_layer2.mp3, c3_layer3.mp3  # Pad layers
│   ├── permanent_bgm.mp3    # Background music
│   └── sfx_*.wav            # Sound effects
└── progress_docs/           # Historical documentation
    ├── DEPLOYMENT.md        # GitHub Pages deployment guide
    ├── PHASE1_SUMMARY.md    # Phase 1 completion summary
    ├── TESTING.md           # Test suite setup documentation
    ├── TEST_FIX_SUMMARY.md
    └── TEST_IMPLEMENTATION_SUMMARY.md
```

## Key Files and Their Roles

### Core Scripts

#### game_manager.gd
- Central game state management
- Score and album tracking
- BPM (tempo) management
- Collection state for Level 3+ critters
- Concert trigger logic
- Signals: `concert_triggered`, `critter_collected`, `stage_reset`

#### grid.gd
- 8x8 grid generation and management
- Click/input handling (click and drag)
- Critter selection and swapping
- Swap validation (adjacency, valid moves)
- Board reset functionality
- No-initial-matches algorithm

#### critter.gd
- Critter type enumeration (MELODY, DRUMS, PAD)
- Level management (1, 2, 3, 4, 5)
- Color definitions per type
- Visual size scaling by level
- Visual brightness scaling by level
- Animation triggers (select, shake, fly)
- Level label display

#### match_controller.gd
- Match detection (horizontal/vertical)
- Match resolution and merging
- Gravity and refill logic
- Cascade detection
- Level 3+ stage collection coordination
- Stage-based merging (3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5)

#### stage_display.gd
- Visual display of collected Level 3+ critters
- 3 dedicated positions for each critter type (Melody, Drums, Pad)
- Multiple critters of same type supported
- Stage-based merging logic
- Bouncing animations
- Stage reset handling
- Concert trigger coordination

#### audio_manager.gd
- Dynamic BGM mixing with 9 layers (3 types × 3 levels)
- Permanent background music
- SFX playback system with sound pooling
- Fade-in/fade-out for music layers
- Music intensity based on stage critter levels
- Audio bus management (Music, SFX)

## Development Phases

### Phase 1: Core Match-3 ✅ Complete
- 8x8 grid generation
- Click-to-select mechanics
- Adjacent swap mechanics (click and drag)
- Match-3 detection
- Gravity and refill
- Cascading matches
- 3 critter types with distinct colors (Melody, Drums, Pad)
- 5 levels with visual progression

### Phase 2: Merge & Stage Logic ✅ Complete
- Merge system (3 → 1 higher level)
- Stage collection for Level 3+ critters
- Concert trigger (all 3 types at Level 5)
- Board reset and loop
- Animations (bounce, shake, fly)
- No-initial-matches generation
- Visual polish
- Stage-based merging (Level 3 → 4 → 5)

### Phase 2.5: Audio System ✅ Complete
- Audio Manager implementation
- Dynamic music layering (9 layers: 3 types × 3 levels)
- Permanent background music
- SFX system (match sounds, combo sounds)
- Music intensity based on stage state
- Fade transitions between layers

### Phase 3: Loop & Shuffle ⏳ Planned
- Deadlock detection
- Auto-shuffle mechanic
- Manual shuffle button
- BPM scaling with difficulty (currently scales but not fully integrated)

### Phase 4: Polish & Combos ⏳ Planned
- Combo counter
- Combo multiplier
- Particle effects
- Enhanced animations
- Musical feedback
- UI polish

## Coding Patterns

### Signal-Based Architecture
- Components communicate via signals
- Loose coupling between systems
- GameManager coordinates via signals
- Example: `emit_signal("critter_collected", type)`

### Scene-Script Separation
- Each .tscn has corresponding .gd script
- Node references via `@onready`
- Scene structure defined in editor
- Logic defined in scripts

### Type Safety
- Uses `class_name` for reusability
- Type hints on variables: `var score: int = 0`
- Enum for critter types: `Critter.CritterType.MELODY`

### Animation Approach
- Tween for simple animations (swap, fly)
- Easing functions for smooth motion
- Chained animations for sequences
- AnimationPlayer for complex multi-property animations

## Important Constraints

### Technical
- Godot 4.x only (not compatible with 3.x)
- GDScript only (no C#/C++)
- 720x1280 window size (portrait)
- 8x8 grid is fixed
- 3 critter types is fixed (Melody, Drums, Pad)
- 5 levels is fixed (1-2 on board, 3-5 on stage)

### Design
- Must maintain merge concept
- Must preserve concert loop
- Must keep 3-instrument theme (Melody, Drums, Pad)
- Must support endless gameplay
- Must scale difficulty with albums
- Must have 5 levels (1-2 board, 3-5 stage)

## Current Status

### Working Features
- Complete match-3 gameplay
- Full merge system (Level 1 → 2 → 3 → 4 → 5)
- Stage collection system (Level 3+ critters)
- Stage-based merging (3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5)
- Concert trigger (all 3 types at Level 5)
- Visual feedback and animations
- Game loop with difficulty scaling
- **Dynamic audio system** with 9 music layers
- **Sound effects** for matches and combos
- Drag-and-drop swapping
- Click-to-swap functionality
- **Comprehensive test suite** with automated tests

### Known Limitations
- Placeholder visuals (colored squares with level numbers)
- No shuffle mechanic (Phase 3)
- No deadlock detection yet
- No combo system (Phase 4)

### Next Priorities
1. Deadlock detection
2. Shuffle mechanics
3. Combo system
4. Particle effects
5. Enhanced visual art assets

## Development Workflow

### Running the Game
```bash
make run              # Launch in Godot
# Or press F5 in Godot editor
```

### Testing
```bash
make test             # Run all tests
make test-unit        # Run unit tests only
make test-int         # Run integration tests only
```

### Exporting & Deployment
```bash
make export-web       # Export game for web locally
make serve            # Serve web build at localhost:8000
```

**Automatic Deployment:**
- Push to `main` branch triggers GitHub Actions
- Workflow exports game and deploys to GitHub Pages
- Live at: `https://kagelump.github.io/kkjam/`

### Before Committing
1. Run `make test` to ensure all tests pass
2. Manual gameplay test (F5)
3. Check console for errors
4. (Optional) Test web export: `make export-web && make serve`

---

# Godot GDScript Expert

## GDScript Coding Standards

### Code Style
- Use **snake_case** for variables, functions, and signals
- Use **PascalCase** for class names
- Use **UPPER_CASE** for constants
- Use tabs for indentation (Godot default)
- Add type hints where possible: `var score: int = 0`
- Use `@onready` for node references
- Use `class_name` for reusable classes

### Node Structure Pattern
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

---

# Testing Expert

## Testing Approach for KKJam

### Testing Environment
- **Engine**: Godot Engine 4.2+
- **Framework**: GUT (Godot Unit Test) 9.5.0
- **Coverage**: Comprehensive automated tests (unit + integration)
- **Manual Testing**: Play mode (F5) for gameplay verification

### Automated Test Suite
This project uses GUT for automated testing with comprehensive test coverage:
- **Unit Tests**: Tests covering Critter, MatchController, GameManager, AudioManager, DragSwap, and edge cases
- **Integration Tests**: Tests for full game flow scenarios
- Tests are in `test/unit/` and `test/integration/`

### Running Tests
```bash
# Using Makefile (recommended)
make test           # Run all tests
make test-unit      # Run unit tests only
make test-int       # Run integration tests only

# Direct GUT CLI usage
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/
```

## Testing Process

### 1. Before Making Changes
- Run automated tests: `make test`
- Verify all tests pass
- Run the game (F5) to check current behavior
- Note baseline functionality

### 2. During Development
- Write tests for new features (TDD approach when appropriate)
- Run relevant test subset: `make test-unit` or specific test file
- Use console output for debugging
- Test frequently after small changes

### 3. After Changes
- Run full test suite: `make test`
- Ensure all tests still pass
- Run manual gameplay test (F5)
- Check for console errors or warnings
- Test edge cases specific to the change

## Test Organization

### Unit Tests (`test/unit/`)
- `test_critter.gd` - Critter behavior
- `test_match_controller.gd` - Match detection
- `test_game_manager.gd` - Game state management
- `test_edge_cases.gd` - Special scenarios
- `test_audio_manager.gd` - Audio system
- `test_drag_swap.gd` - Drag-and-drop mechanics

### Integration Tests (`test/integration/`)
- `test_game_flow.gd` - Full game workflows

## Manual Testing Checklist by System

### Grid System Tests
- [ ] Grid generates as 8x8
- [ ] All cells are populated
- [ ] 3 critter types appear (MELODY, DRUMS, PAD)
- [ ] Visual differences between levels visible
- [ ] No initial matches on board generation

### Selection & Swap Tests
- [ ] Click selects critter (brightens/bounces)
- [ ] Click again deselects
- [ ] Adjacent swap works (up/down/left/right)
- [ ] Drag-and-drop swap works
- [ ] Non-adjacent swap rejected
- [ ] Diagonal swap rejected
- [ ] Invalid swap shows shake animation
- [ ] Valid swap creates smooth animation

### Match Detection Tests
- [ ] Horizontal match of 3+ detected
- [ ] Vertical match of 3+ detected
- [ ] Both type AND level must match
- [ ] Console shows match details
- [ ] Multiple simultaneous matches handled

### Merge System Tests
- [ ] 3 Level 1s merge into 1 Level 2
- [ ] 3 Level 2s merge into 1 Level 3
- [ ] Merge appears at swap location
- [ ] Merged critter has correct visual
- [ ] Level number displays correctly

### Stage Collection Tests
- [ ] Level 3+ critters fly to stage
- [ ] Animation is smooth
- [ ] Critter appears in correct stage slot
- [ ] Stage critters persist
- [ ] Multiple of same type handled correctly
- [ ] Stage merging works (3 Level 3s → 1 Level 4)
- [ ] Maximum level (Level 5) works correctly

### Concert Trigger Tests
- [ ] Concert triggers when all 3 types at Level 5
- [ ] Album counter increments
- [ ] Board resets completely
- [ ] Stage clears
- [ ] BPM increases
- [ ] Console shows concert message

### Audio Tests
- [ ] Music layers activate based on stage levels
- [ ] Music fades smoothly
- [ ] SFX plays for matches
- [ ] No audio glitches or stuttering

## Testing by Phase

### Phase 1 (Complete)
- Grid generation
- Selection mechanics
- Swap mechanics
- Match detection
- Gravity & refill

### Phase 2 (Complete)
- Merge system
- Stage collection
- Concert trigger
- Board reset
- Visual polish (bounce, shake, fly animations)
- Stage-based merging (Level 3 → 4 → 5)
- Audio system with dynamic layering

### Phase 3 (Planned)
- Deadlock detection
- Shuffle mechanics
- Enhanced BPM scaling

### Phase 4 (Planned)
- Combo system
- Particle effects
- Enhanced animations
- UI polish

## Testing Best Practices

1. **Test incrementally**: After each small change
2. **Use console**: Print statements are your friend
3. **Test edge cases**: Corners, edges, extremes
4. **Test the loop**: Play through multiple concerts
5. **Watch animations**: Verify smoothness and correctness
6. **Check state**: Verify game state matches expectations
7. **Test combinations**: Multiple features interacting

---

# Game Design Expert

## Game Overview
**KKJam** is an endless Match-3 puzzle game where players merge critters into musicians to create the ultimate band. Players need to create one Level 5 critter of each of the 3 types (Melody, Drums, Pad) to trigger a concert.

## Core Game Loop
1. Match 3 critters of same type AND level
2. Merge into 1 higher-level critter
3. Collect Level 3+ critters on the Stage
4. Merge on stage: 3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5
5. Trigger concert when all 3 types reach Level 5
6. Reset board and increase difficulty
7. Repeat

## Design Pillars

### 1. Merge, Don't Remove
- Unlike traditional Match-3, critters don't disappear
- Matches merge into higher-level critters
- Creates strategic depth: fewer items on board over time
- Level 1 + Level 1 + Level 1 → Level 2 (on board)
- Level 2 + Level 2 + Level 2 → Level 3 (on board)
- Level 3 + Level 3 + Level 3 → Level 4 (on stage)
- Level 4 + Level 4 + Level 4 → Level 5 (on stage, max level)

### 2. Collection System
- Level 3+ critters "fly" to the Stage
- Stage acts as permanent collection area
- One slot per critter type (3 total: Melody, Drums, Pad)
- Multiple critters of same type can be on stage
- Stage critters can merge (3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5)
- Collected critters persist until concert

### 3. The Concert Loop
- Win condition: Collect one Level 5 of all 3 types
- Concert animation plays
- Album counter increments
- Board completely resets
- Difficulty increases (BPM, speed)

### 4. Dynamic Music Integration
- 3 musical instruments: Melody, Drums, Pad
- Each has 3 intensity layers (Level 3, 4, 5 on stage)
- Music intensity reflects stage state
- Level 3 critter on stage = basic layer
- Level 4 critter on stage = medium layer
- Level 5 critter on stage = maximum layer
- BPM increases with each album
- Permanent background music layer always plays

## Critter Types and Themes

### The Band Members
1. **Melody (Blue/Cyan)** - Melody 🎹
  - Lead melody layer
  - Smooth, melodic

2. **Drums (Red/Pink)** - Drummer 🥁
  - Percussion/Drums layer
  - Energetic, rhythmic

3. **Pad (Green)** - Pad 🎛️
  - Atmospheric synth pad layer
  - Ambient, atmospheric

### Visual Progression
- **Level 1**: Baby/small, muted colors
- **Level 2**: Teen/medium, brighter colors
- **Level 3**: Musician/large, vibrant colors (flies to stage)
- **Level 4**: Star/larger, very bright (stage only)
- **Level 5**: Legend/largest, maximum brightness (stage only, max level)

## Gameplay Balance

### Board State Evolution
- Starts: 64 Level 1 critters
- After matches: Fewer, higher-level critters
- Creates strategic tension: harder to find matches
- Requires shuffle mechanic to prevent deadlocks

### Difficulty Scaling
- Each album completion increases:
  - BPM (tempo) by 10
  - Future: Hype meter drain rate
  - Future: Shuffle cooldown

### Match Mechanics
- Only adjacent swaps allowed (no diagonals)
- Must create a match to be valid
- Swap location becomes merge location
- Cascading matches are encouraged (combos)

## Future Features (Planned)

### Phase 3: Loop & Shuffle
- Deadlock detection
- Auto-shuffle when no moves available
- Manual shuffle button with cooldown
- ~~Dynamic music layering~~ (✅ Complete)
- ~~BPM scaling~~ (✅ Complete)

### Phase 4: Polish & Combos
- Combo counter for consecutive matches
- Combo multiplier for score
- Particle effects
- Enhanced animations
- Musical feedback for combos

### Stretch Goals
- Hype Meter (lose condition)
- Special tiles (wildcards)
- Fever mode
- Unlockable costumes
- Power-ups

## Design Constraints

### Must Maintain
- 8x8 grid size (balanced for gameplay)
- 3 critter types (Melody, Drums, Pad - one per instrument)
- 5 level system (1-2 board, 3-5 stage for progression clarity)
- Match-3 mechanic (genre familiarity)
- Merge system (unique twist)
- Stage-based advanced merging

### Should Avoid
- Removing items permanently (breaks merge concept)
- More than 3 critter types (dilutes collection and music)
- Complex match patterns (keeps it accessible)
- Score-based win conditions (endless loop is the goal)

## Player Experience Goals

### Flow State
- Easy to learn, hard to master
- Satisfying merge animations
- Musical feedback for actions
- Clear visual/audio progression

### Juiciness
- Smooth animations (0.2-0.5s)
- Particle effects on merges
- Screen shake on concerts
- Bouncy, playful feel

### Accessibility
- Color-blind friendly (patterns/shapes)
- Clear visual feedback
- No time pressure (turn-based)
- Forgiving shuffle mechanic

## Quality Guidelines

### When Adding Features
1. Does it support the core loop?
2. Does it enhance the musical theme?
3. Is it intuitive for players?
4. Does it maintain game balance?
5. Is it visually/aurally satisfying?

### When Modifying Mechanics
1. Preserve the merge concept
2. Maintain 3-type collection system
3. Keep the concert trigger meaningful
4. Ensure difficulty scales smoothly
5. Test for edge cases and deadlocks

### Polish Priorities
1. Animation smoothness
2. Audio feedback
3. Visual clarity
4. Responsive controls
5. Satisfying game feel

## Current Status: Phase 2.5 Complete
- ✅ Core match-3 mechanics
- ✅ Merge system (5 levels total)
- ✅ Stage collection
- ✅ Stage-based merging (Level 3 → 4 → 5)
- ✅ Concert trigger
- ✅ Basic animations
- ✅ Audio system (dynamic music layering, SFX)
- ⏳ Shuffle mechanics (Phase 3)
- ⏳ Deadlock detection (Phase 3)
- ⏳ Combo system (Phase 4)
