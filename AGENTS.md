# KKJam Agent Guide

This document consolidates all agent instructions for working on the KKJam project. It provides context, coding standards, testing procedures, and game design principles.

---

## Table of Contents
1. [Project Context & Overview](#project-context--overview)
2. [Repository Structure](#repository-structure)
3. [Development Workflow](#development-workflow)
4. [GDScript Coding Standards](#gdscript-coding-standards)
5. [Testing Guidelines](#testing-guidelines)
6. [Game Design Principles](#game-design-principles)

---

## Project Context & Overview

**KKJam** is an endless Match-3 puzzle game built in Godot 4.x where players match and merge critters into musicians to create the ultimate band.

### Current Status: Phase 2.5 Complete ✓

#### Working Features
- Complete match-3 gameplay with merge mechanics
- Full 5-level progression system (Level 1-5)
- Stage collection system for Level 3+ critters
- Stage-based merging (3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5)
- Concert trigger when all 3 types reach Level 5
- Visual feedback and animations
- Game loop with difficulty scaling
- Audio system integration
- **50 automated tests** (42 unit, 8 integration)

#### Known Limitations
- Placeholder visuals (colored squares)
- No shuffle mechanic yet (Phase 3)
- No combo system yet (Phase 4)

---

## Repository Structure

```
/home/runner/work/kkjam/kkjam/
├── .git/                    # Git repository data
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Pages deployment automation
├── .gitignore               # Git ignore rules
├── .gutconfig.json          # GUT test framework configuration
├── addons/
│   └── gut/                 # GUT test framework
├── BGM/                     # Background music and audio assets
│   ├── PLAN.md             # Music implementation plan
│   └── COMPRESSION_GUIDE.md # Audio compression guidelines
├── test/                    # Test suite
│   ├── unit/                # Unit tests (42 tests)
│   ├── integration/         # Integration tests (8 tests)
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
│   └── audio_manager.gd     # Audio system and music layering
├── progress_docs/           # Project progress documentation
│   ├── DEPLOYMENT.md        # GitHub Pages deployment guide
│   ├── TESTING.md           # Testing procedures
│   ├── PHASE1_SUMMARY.md    # Phase 1 completion summary
│   ├── TEST_FIX_SUMMARY.md  # Test suite setup documentation
│   └── TEST_IMPLEMENTATION_SUMMARY.md
├── Makefile                 # Development commands (test, run, export, clean)
├── export_presets.cfg       # Godot export configuration for web
├── icon.svg                 # Project icon
├── project.godot            # Godot project configuration
├── README.md                # Project overview and status
├── TODO.md                  # Complete game design document
└── AGENTS.md                # This file - consolidated agent instructions
```

---

## Development Workflow

### Prerequisites
- Godot Engine 4.2+
- No external dependencies
- Runs in editor (F5 to play)

### Common Development Commands

**All commands should use the Makefile when available:**

```bash
# Testing (ALWAYS use Makefile commands)
make test           # Run all 50 tests
make test-unit      # Run unit tests only (42 tests)
make test-int       # Run integration tests only (8 tests)

# Running the Game
make run            # Launch game in Godot

# Building & Deployment
make export-web     # Export game for web (release build)
make web-dev        # Export debug web build and serve locally
make serve          # Serve exported web build at localhost:8000

# Maintenance
make clean          # Clean temporary files and build artifacts
make help           # Show all available commands
```

### Before Committing
1. Run `make test` to ensure all tests pass
2. Manual gameplay test with `make run` (or F5 in Godot editor)
3. Check console for errors
4. (Optional) Test web export: `make export-web && make serve`

### Running Tests Directly (when Makefile not suitable)
```bash
# Direct GUT CLI usage (only if Makefile unavailable)
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/
```

### Automatic Deployment
- Push to `main` branch triggers GitHub Actions
- Workflow exports game and deploys to GitHub Pages
- Live at: `https://kagelump.github.io/kkjam/`
- See `progress_docs/DEPLOYMENT.md` for details

---

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

---

## Key Scripts and Their Roles

### game_manager.gd
- Central game state management
- Score and album tracking
- BPM (tempo) management
- Collection state for Level 3+ critters
- Concert trigger logic
- Signals: `concert_triggered`, `critter_collected`, `stage_reset`

### grid.gd
- 8x8 grid generation and management
- Click/input handling
- Critter selection and swapping
- Swap validation (adjacency, valid moves)
- Board reset functionality
- No-initial-matches algorithm

### critter.gd
- Critter type enumeration (MELODY, DRUMS, PAD)
- Level management (1, 2, 3, 4, 5)
- Color definitions per type
- Visual size scaling by level
- Animation triggers (select, shake, fly)

### match_controller.gd
- Match detection (horizontal/vertical)
- Match resolution and merging
- Gravity and refill logic
- Cascade detection
- Level 3+ stage collection coordination

### stage_display.gd
- Visual display of collected Level 3+ critters
- 3 dedicated positions for each critter type
- Multiple critters of same type can be on stage
- Stage merging logic (3 Level 3s → 1 Level 4, etc.)
- Bouncing animations
- Stage reset handling

### audio_manager.gd
- Audio system management
- Music layering based on stage state
- BPM control and scaling
- Stem playback (Drums, Bass, Melody layers)
- Volume control per layer

---

## Project-Specific Guidelines

### Critter System
- Critters have **3 types**: MELODY, DRUMS, PAD
- Critters have **5 levels**: 1, 2, 3, 4, 5
- Level 1-2 critters stay on the board
- Level 3+ critters fly to the Stage
- Use the `Critter` class for all critter logic

### Grid System
- Grid is 8x8
- Use (x, y) coordinates where x is column, y is row
- Grid is managed by the `Grid` class
- Match detection is handled by `MatchController`

### Game Loop
- Game state is managed by `GameManager`
- Use signals for cross-component communication
- Stage collection triggers concerts when all 3 types reach Level 5

### Match and Merge Logic
- Matches require 3+ critters of same type AND level
- **Board matches**: 3 Level 1s → 1 Level 2, 3 Level 2s → 1 Level 3
- **Stage matches**: 3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5
- Cascading matches are automatically detected after refills
- Use `MatchController` for all match-related logic

### Music System
- Music layers activate based on highest level on stage per type
- Level 1-2 critters: No music (silent practice)
- Level 3 on stage: Layer 1 (basic intensity)
- Level 4 on stage: Layer 2 (medium intensity)
- Level 5 on stage: Layer 3 (maximum intensity)

---

## Testing Guidelines

### Testing Framework
- **Engine**: Godot Engine 4.2+
- **Framework**: GUT (Godot Unit Test) 9.5.0
- **Coverage**: 50 automated tests (42 unit + 8 integration)
- **Total Assertions**: 201+ passing

### Testing Process

#### 1. Before Making Changes
- Run `make test` to verify all tests pass
- Run the game with `make run` to check current behavior
- Note baseline functionality

#### 2. During Development
- Write tests for new features (TDD approach when appropriate)
- Run relevant test subset: `make test-unit` or `make test-int`
- Use console output for debugging
- Test frequently after small changes

#### 3. After Changes
- Run full test suite: `make test`
- Ensure all 50 tests still pass
- Run manual gameplay test: `make run`
- Check for console errors or warnings
- Test edge cases specific to the change

### Test Organization

#### Unit Tests (`test/unit/`)
- `test_critter.gd` - Critter behavior
- `test_match_controller.gd` - Match detection and merge logic
- `test_game_manager.gd` - Game state management
- `test_edge_cases.gd` - Special scenarios and edge cases
- `test_audio_manager.gd` - Audio system and music layering
- `test_drag_swap.gd` - Drag and swap mechanics

#### Integration Tests (`test/integration/`)
- `test_game_flow.gd` - Full game workflows (8 tests)

### Manual Testing Checklist

#### Grid System Tests
- [ ] Grid generates as 8x8
- [ ] All cells are populated
- [ ] 3 critter types appear (MELODY, DRUMS, PAD)
- [ ] Visual differences between levels visible
- [ ] No initial matches on board generation

#### Selection & Swap Tests
- [ ] Click selects critter (brightens/bounces)
- [ ] Click again deselects
- [ ] Adjacent swap works (up/down/left/right)
- [ ] Non-adjacent swap rejected
- [ ] Diagonal swap rejected
- [ ] Invalid swap shows shake animation
- [ ] Valid swap creates smooth animation

#### Match Detection Tests
- [ ] Horizontal match of 3+ detected
- [ ] Vertical match of 3+ detected
- [ ] Both type AND level must match
- [ ] Console shows match details
- [ ] Multiple simultaneous matches handled

#### Merge System Tests
- [ ] 3 Level 1s merge into 1 Level 2
- [ ] 3 Level 2s merge into 1 Level 3
- [ ] 3 Level 3s merge into 1 Level 4 (on stage)
- [ ] 3 Level 4s merge into 1 Level 5 (on stage)
- [ ] Merge appears at correct location
- [ ] Merged critter has correct visual
- [ ] Level number displays correctly

#### Gravity & Refill Tests
- [ ] Critters fall to fill gaps
- [ ] New critters spawn from top
- [ ] All Level 1 on spawn
- [ ] Cascading matches work
- [ ] Console shows cascade messages

#### Stage Collection Tests
- [ ] Level 3+ critters fly to stage
- [ ] Animation is smooth
- [ ] Critter appears in correct stage slot
- [ ] Multiple of same type handled correctly
- [ ] Stage merging works correctly

#### Concert Trigger Tests
- [ ] Concert triggers when all 3 types reach Level 5
- [ ] Album counter increments
- [ ] Board resets completely
- [ ] Stage clears
- [ ] BPM increases
- [ ] Console shows concert message

### Expected Console Messages
```
"KKJam - Phase 2.5 Started"
"Match 3 to merge! Collect all 3 Level 5 critters to win!"
"Selected: [Type] at (x, y)"
"Match resolved: [count] [type] Level [level]"
"Found X matches"
"Cascade! Found X new matches"
"Swap would not create a match"
"Collected Level 3+ Critter: [type]"
"ULTIMATE CONCERT TRIGGERED!"
"Album completed! Total albums: X"
"Stage cleared for next tour stop"
```

---

## Game Design Principles

### Core Game Loop
1. Match 3 critters of same type AND level
2. Merge into 1 higher-level critter
3. Collect Level 3+ critters on the Stage
4. Stage critters can merge further (3 Level 3s → Level 4, 3 Level 4s → Level 5)
5. Trigger concert when all 3 types reach Level 5
6. Reset board and increase difficulty
7. Repeat

### Design Pillars

#### 1. Merge, Don't Remove
- Unlike traditional Match-3, critters don't disappear
- Matches merge into higher-level critters
- Creates strategic depth: fewer items on board over time
- Board: Level 1 → Level 2 → Level 3
- Stage: Level 3 → Level 4 → Level 5

#### 2. Collection System
- Level 3+ critters "fly" to the Stage
- Stage acts as permanent collection area
- Multiple critters of same type can be on stage
- Stage critters can merge into higher levels
- Collected critters persist until concert

#### 3. The Concert Loop
- Win condition: All 3 types reach Level 5 on stage
- Concert animation plays
- Album counter increments
- Board completely resets
- Difficulty increases (BPM, speed)

#### 4. Dynamic Music Integration
- 3 musical stems: Drums, Melody, Pad
- Music intensity reflects stage state
- Level 3: Basic layer, Level 4: Medium layer, Level 5: Maximum layer
- BPM increases with each album

### The Band Members

1. **Melody (Blue/Cyan)** - Lead melodies 🎹
   - Smooth, melodic
   
2. **Drums (Red/Pink)** - Percussion 🥁
   - Energetic, rhythmic
   
3. **Pad (Green)** - Atmospheric synth pad 🎛️
   - Deep, atmospheric

### Visual Progression
- **Level 1**: Baby/small, muted colors
- **Level 2**: Teen/medium, brighter colors
- **Level 3**: Musician/large, vibrant colors (goes to stage)
- **Level 4**: Star/larger, brilliant colors (stage only)
- **Level 5**: Legend/largest, maximum brilliance (stage only)

### Gameplay Balance

#### Board State Evolution
- Starts: 64 Level 1 critters
- After matches: Fewer, higher-level critters
- Creates strategic tension: harder to find matches
- Requires shuffle mechanic to prevent deadlocks (Phase 3)

#### Difficulty Scaling
- Each album completion increases:
  - BPM (tempo) by 10
  - Future: Shuffle cooldown
  - Future: Match requirements

#### Match Mechanics
- Only adjacent swaps allowed (no diagonals)
- Must create a match to be valid
- Swap location becomes merge location
- Cascading matches are encouraged

### Design Constraints

#### Must Maintain
- 8x8 grid size (balanced for gameplay)
- 3 critter types (one per instrument)
- 5 level system (progression clarity)
- Match-3 mechanic (genre familiarity)
- Merge system (unique twist)

#### Should Avoid
- Removing items permanently (breaks merge concept)
- More than 3 critter types (dilutes collection)
- Complex match patterns (keeps it accessible)
- Score-based win conditions (endless loop is the goal)

---

## Development Phases

### Phase 1: Core Match-3 ✅ Complete
- 8x8 grid generation
- Click-to-select mechanics
- Adjacent swap mechanics
- Match-3 detection
- Gravity and refill
- Cascading matches
- 3 critter types with distinct colors
- 3 levels with visual progression

### Phase 2: Merge & Stage Logic ✅ Complete
- Merge system (3 → 1 higher level)
- Stage collection for Level 3 critters
- Concert trigger (all 3 types collected at Level 3)
- Board reset and loop
- Animations (bounce, shake, fly)
- No-initial-matches generation
- Visual polish

### Phase 2.5: Extended Gameplay Loop ✅ Complete
- Extended to 5 levels (Level 1-5)
- Stage-based merging (Level 3 → 4 → 5)
- Multiple critters of same type on stage
- Updated concert trigger (requires Level 5 of each type)
- Music layering system
- Updated visual progression

### Phase 3: Loop & Shuffle ⏳ Planned
- Deadlock detection
- Auto-shuffle mechanic
- Manual shuffle button
- Full audio integration
- Dynamic music layering
- BPM scaling with difficulty

### Phase 4: Polish & Combos ⏳ Planned
- Combo counter
- Combo multiplier
- Particle effects
- Enhanced animations
- Musical feedback
- UI polish

---

## Common Tasks

### Adding a New Feature
1. Check `TODO.md` for design specs
2. Identify affected scripts
3. Follow existing code patterns
4. Use signals for communication
5. Test with `make run`
6. Add/update automated tests
7. Run `make test` before committing
8. Update README.md if user-facing

### Modifying Existing Code
1. Understand current implementation
2. Check for dependencies (signals, references)
3. Make minimal changes
4. Run `make test` to verify no regressions
5. Test affected features with `make run`
6. Update tests if behavior changes

### Adding Visual Elements
1. Create/modify .tscn in editor
2. Add script logic if needed
3. Use existing color/size patterns
4. Test animations
5. Verify performance
6. Test with `make run`

### Debugging
- Print statements to console
- Godot debugger (F6)
- Scene tree inspector
- Remote debugger for exports
- GUT test output for test failures

---

## Important Constraints

### Technical
- Godot 4.x only (not compatible with 3.x)
- GDScript only (no C#/C++)
- 720x1280 window size (portrait)
- 8x8 grid is fixed
- 3 critter types is fixed
- 5 level system

### Design
- Must maintain merge concept
- Must preserve concert loop
- Must keep 3-instrument theme
- Must support endless gameplay
- Must scale difficulty with albums

---

## Resources and References

### Internal Documentation
- `README.md` - Project overview and current status
- `TODO.md` - Complete game design specification
- `progress_docs/TESTING.md` - Detailed testing procedures
- `progress_docs/PHASE1_SUMMARY.md` - Phase 1 implementation details
- `progress_docs/DEPLOYMENT.md` - GitHub Pages deployment guide
- `test/README.md` - Test suite documentation
- `BGM/PLAN.md` - Music implementation plan

### External Resources
- Godot 4 Documentation: https://docs.godotengine.org/en/stable/
- GDScript Style Guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

---

## Quality Standards

### Code Quality
- Follow GDScript style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small
- Avoid code duplication

### Game Feel
- Smooth animations (0.2-0.5s)
- Immediate visual feedback
- Clear audio cues
- Responsive controls
- Satisfying interactions

### Performance
- Maintain 60 FPS
- Efficient node management
- No memory leaks
- Quick load times
- Smooth cascades

---

## Getting Help

### For Code Questions
- Check existing scripts for patterns
- Reference this AGENTS.md file
- Consult Godot documentation

### For Design Questions
- Check TODO.md for specifications
- Reference Game Design Principles section above
- Maintain design pillars

### For Testing Questions
- Check test/README.md for test documentation
- Reference Testing Guidelines section above
- Run `make test` for automated tests
- Use `make run` for manual testing

---

**This document consolidates all agent instructions. Individual agent files in `.github/agents/` are now deprecated. Use this single AGENTS.md file as the authoritative source for all project guidance.**

**Note**: This file reflects the current state of the project (Phase 2.5). The old individual agent files contained outdated information:
- Old files mentioned 4 critter types (BUNNY, CAT, FROG, BIRD), now there are 3 (MELODY, DRUMS, PAD)
- Old files mentioned 3 levels, now the system supports 5 levels (1-5)
- Old files mentioned 42 total tests (33 unit + 8 integration), now there are 50 tests (42 unit + 8 integration)
- Old files mentioned concert triggers at Level 3, now it requires Level 5 of each type

