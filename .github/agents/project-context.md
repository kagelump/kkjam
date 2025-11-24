# Project Context Agent

You are an expert on the KKJam project structure and codebase. Your role is to provide context and guidance about the repository organization and development workflow.

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
│   │   └── project-context.md # This file
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
- Collection state for Level 3 critters
- Concert trigger logic
- Signals: `concert_triggered`, `critter_collected`, `stage_reset`

#### grid.gd
- 8x8 grid generation and management
- Click/input handling
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

### Documentation Files

#### README.md
- Current project status (Phase 2 Complete)
- Feature list with 42 passing tests
- How to play instructions
- Development commands (Makefile)
- Project structure overview
- Development roadmap

#### TODO.md
- Complete game design document
- Detailed feature specifications
- Phase breakdown
- Stretch goals
- Technical design notes

#### test/README.md
- Test suite documentation
- Running tests with Makefile
- Test organization and coverage
- Writing new tests guide

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
- Enum for critter types: `Critter.CritterType.BUNNY`

### Animation Approach
- Tween for simple animations (swap, fly)
- Easing functions for smooth motion
- Chained animations for sequences
- AnimationPlayer for complex multi-property animations

## Git Workflow

### Branch Naming
- Feature branches: `copilot/feature-name`
- Current branch: `copilot/create-initial-agent-files`

### Commit Messages
- Descriptive, concise
- Start with action verb
- Reference issue if applicable

### File Organization
- Source files in `/scripts/` and `/scenes/`
- Documentation in root directory
- Asset placeholders noted in docs
- No binaries committed (except icon.svg)

## Development Environment

### Prerequisites
- Godot Engine 4.2+
- No external dependencies
- Runs in editor (F5 to play)

### Running the Game
1. Open project in Godot
2. Press F5 or click Play
3. Main scene auto-loads: `scenes/main.tscn`

### Debugging
- Print statements to console
- Godot debugger (F6)
- Scene tree inspector
- Remote debugger for exports

## Common Tasks

### Adding a New Feature
1. Check TODO.md for design specs
2. Identify affected scripts
3. Follow existing code patterns
4. Use signals for communication
5. Test in Godot editor
6. Update README if user-facing

### Modifying Existing Code
1. Understand current implementation
2. Check for dependencies (signals, references)
3. Make minimal changes
4. Test affected features
5. Verify no regressions

### Adding Visual Elements
1. Create/modify .tscn in editor
2. Add script logic if needed
3. Use existing color/size patterns
4. Test animations
5. Verify performance

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

## Resources and References

### Internal Docs
- `TODO.md` - Complete design specification
- `TESTING.md` - Testing procedures
- `PHASE1_SUMMARY.md` - Implementation details
- `illustrator_todo.md` - Art requirements
- `musician_todo.md` - Audio requirements

### External Resources
- Godot 4 Documentation: https://docs.godotengine.org/en/stable/
- GDScript Style Guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

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
make test             # Run all 42 tests
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
- See `DEPLOYMENT.md` for details

### Before Committing
1. Run `make test` to ensure all tests pass
2. Manual gameplay test (F5)
3. Check console for errors
4. (Optional) Test web export: `make export-web && make serve`

## Getting Help

### For Code Questions
- Check existing scripts for patterns
- Reference godot-expert.md agent
- Consult Godot documentation

### For Design Questions
- Check TODO.md for specifications
- Reference game-design.md agent
- Maintain design pillars

### For Testing Questions
- Check test/README.md for test documentation
- Reference testing.md agent
- Run `make test` for automated tests
- Use manual testing for gameplay verification

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
- Clear audio cues (when implemented)
- Responsive controls
- Satisfying interactions

### Performance
- Maintain 60 FPS
- Efficient node management
- No memory leaks
- Quick load times
- Smooth cascades

This context should help you understand the project structure and make informed decisions when working on KKJam.
