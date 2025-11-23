# Project Context Agent

You are an expert on the KKJam project structure and codebase. Your role is to provide context and guidance about the repository organization and development workflow.

## Project Overview
**KKJam** is an endless Match-3 puzzle game built in Godot 4.x where players match and merge critters into musicians to create the ultimate band.

## Repository Structure

```
/home/runner/work/kkjam/kkjam/
├── .git/                    # Git repository data
├── .github/
│   └── agents/              # GitHub Copilot agent configurations
│       ├── godot-expert.md  # GDScript coding guidance
│       ├── game-design.md   # Game design principles
│       ├── testing.md       # Testing procedures
│       └── project-context.md # This file
├── .gitignore               # Git ignore rules
├── scenes/                  # Godot scene files (.tscn)
│   ├── main.tscn            # Main game scene
│   └── critter.tscn         # Reusable critter scene
├── scripts/                 # GDScript files (.gd)
│   ├── game_manager.gd      # Game state and orchestration
│   ├── grid.gd              # Grid management and input handling
│   ├── critter.gd           # Critter properties and behavior
│   ├── match_controller.gd  # Match detection and merge logic
│   └── stage_display.gd     # Stage UI for Level 3 critters
├── icon.svg                 # Project icon
├── project.godot            # Godot project configuration
├── README.md                # Project overview and status
├── TODO.md                  # Complete game design document
├── TESTING.md               # Testing guide
├── PHASE1_SUMMARY.md        # Phase 1 completion summary
├── illustrator_todo.md      # Art asset TODO list
└── musician_todo.md         # Music asset TODO list
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
- Critter type enumeration (BUNNY, CAT, FROG, BIRD)
- Level management (1, 2, 3)
- Color definitions per type
- Visual size scaling by level
- Animation triggers (select, shake, fly)

#### match_controller.gd
- Match detection (horizontal/vertical)
- Match resolution and merging
- Gravity and refill logic
- Cascade detection
- Level 3 stage collection coordination

#### stage_display.gd
- Visual display of collected Level 3 critters
- 4 dedicated positions for each critter type
- Bouncing animations
- Stage reset handling

### Documentation Files

#### README.md
- Current project status (Phase 2 Complete)
- Feature list
- How to play instructions
- Project structure overview
- Development roadmap

#### TODO.md
- Complete game design document
- Detailed feature specifications
- Phase breakdown
- Stretch goals
- Technical design notes

#### TESTING.md
- Manual testing procedures
- Test checklists
- Known limitations
- How to run the project

## Development Phases

### Phase 1: Core Match-3 ✅ Complete
- 8x8 grid generation
- Click-to-select mechanics
- Adjacent swap mechanics
- Match-3 detection
- Gravity and refill
- Cascading matches
- 4 critter types with distinct colors
- 3 levels with visual progression

### Phase 2: Merge & Stage Logic ✅ Complete
- Merge system (3 → 1 higher level)
- Stage collection for Level 3 critters
- Concert trigger (all 4 types collected)
- Board reset and loop
- Animations (bounce, shake, fly)
- No-initial-matches generation
- Visual polish

### Phase 3: Loop & Shuffle ⏳ Planned
- Deadlock detection
- Auto-shuffle mechanic
- Manual shuffle button
- Audio system (4 music layers)
- Dynamic music layering
- BPM scaling with difficulty

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
- 4 critter types is fixed

### Design
- Must maintain merge concept
- Must preserve concert loop
- Must keep 4-instrument theme
- Must support endless gameplay
- Must scale difficulty with albums

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
- Full merge system (Level 1 → 2 → 3)
- Stage collection system
- Concert trigger and reset
- Visual feedback and animations
- Game loop with difficulty scaling

### Known Limitations
- No audio implementation yet
- Placeholder visuals (colored squares)
- No shuffle mechanic (Phase 3)
- No combo system (Phase 4)
- Manual testing only

### Next Priorities
1. Deadlock detection
2. Shuffle mechanics
3. Audio system implementation
4. Music layer dynamics

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
- Check TESTING.md for procedures
- Reference testing.md agent
- Use manual testing approach

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
