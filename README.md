# Critter Composer

A 2D puzzle game built in Godot where players combine adorable critters to create and evolve music loops. The gameplay blends Match-3 mechanics with dynamic music composition.

## 🎮 Game Concept

**Critter Composer** is a music-driven Match-3 puzzle game where:
- Players match 3+ critters of the same type to create music loops
- Matched critters evolve and their music becomes richer
- Multiple matches layer different music loops for a dynamic soundtrack
- The game is designed for a short development timeline with polished mechanics

## 🏗️ Project Structure

```
kkjam/
├── project.godot           # Godot project configuration
├── icon.svg               # Project icon
├── scenes/                # Game scenes
│   ├── main.tscn         # Main game scene
│   ├── game_board.tscn   # Grid-based game board
│   ├── ui_layer.tscn     # UI overlay
│   └── critter.tscn      # Individual critter piece
├── scripts/               # GDScript files
│   ├── main.gd           # Main game controller
│   ├── game_board.gd     # Board logic and matching
│   ├── ui_layer.gd       # UI management
│   ├── critter.gd        # Critter behavior
│   └── audio_manager.gd  # Audio system manager
├── assets/                # Game assets
│   ├── sprites/          # Visual assets
│   │   ├── critters/     # Critter sprites
│   │   └── ui/           # UI elements
│   └── audio/            # Audio assets
│       ├── music/        # Music loops
│       └── sfx/          # Sound effects
└── audio/                 # Audio configuration
    └── default_bus_layout.tres  # Audio bus setup
```

## 🎯 Core Features

### Match-3 Mechanics
- **8x8 Grid**: Standard Match-3 board with 5 critter types
- **Swap-Based Matching**: Players swap adjacent critters to create matches
- **Cascade System**: New critters fall from the top after matches
- **Combo Detection**: Multiple consecutive matches for bonus points

### Music System
- **Dynamic Layers**: Each critter type represents a music layer (Bass, Melody, Percussion, Harmony, Lead)
- **Evolution**: Matched critters evolve, enhancing their musical contribution
- **Real-time Mixing**: Audio manager blends active music layers
- **Synchronized Loops**: All loops sync to a common BPM

### Game Flow
1. Player selects a critter
2. Player selects an adjacent critter to swap
3. System checks for matches (3+ in a row)
4. Matched critters are removed and contribute to the music
5. New critters fall to fill gaps
6. Process repeats with potential cascades

## 🚀 Getting Started

### Requirements
- Godot Engine 4.2 or later
- No additional dependencies required

### Running the Game
1. Open the project in Godot Engine
2. Press F5 or click the Play button
3. The game will start with `scenes/main.tscn`

### Development
The project is structured for easy expansion:
- Add critter sprites to `assets/sprites/critters/`
- Add music loops to `assets/audio/music/`
- Configure audio buses in `audio/default_bus_layout.tres`
- Extend game logic in the respective script files

## 📋 Current Implementation Status

### ✅ Implemented
- [x] Basic project structure
- [x] Main scene hierarchy
- [x] Game board grid system (8x8)
- [x] Match-3 detection logic
- [x] Critter piece structure
- [x] UI layer with score/moves tracking
- [x] Audio manager framework
- [x] Signal-based communication
- [x] Placeholder asset structure

### 🔨 To Be Added
- [ ] Actual critter sprites (currently using colored rectangles)
- [ ] Music loop audio files
- [ ] Sound effects
- [ ] Critter swap animations
- [ ] Match removal animations
- [ ] Particle effects
- [ ] Game over conditions
- [ ] Menu screens
- [ ] Settings/options

## 🎨 Design Notes

### Visual Style
- Charming, colorful critter designs
- Clean, readable UI
- Smooth animations for swaps and matches
- Particle effects for evolution

### Audio Design
- 5 base music layers (one per critter type)
- Each layer has 3 evolution levels
- All loops at 120 BPM, 4 measures
- Seamless looping and mixing

### Game Balance
- Starting with 5 critter types for manageable complexity
- Evolution system rewards consecutive matches
- Score multipliers for combos and cascades

## 📝 Script Documentation

All scripts include doc comments explaining their purpose and key functions:
- `main.gd`: Game state management and coordination
- `game_board.gd`: Match-3 logic and board state
- `ui_layer.gd`: Score, moves, and music layer display
- `critter.gd`: Individual critter behavior and animation
- `audio_manager.gd`: Music layer mixing and sound effects

## 🎵 Audio System

The audio system uses Godot's AudioBusLayout with two buses:
- **Music Bus**: For all music loops
- **SFX Bus**: For sound effects

The AudioManager coordinates:
- Adding/removing music layers dynamically
- Syncing loops to the beat grid
- Fading layers in/out smoothly
- Playing one-shot sound effects

## 🤝 Contributing

This is a game jam project focused on rapid development. Key areas for contribution:
1. **Art Assets**: Critter sprites, UI elements, backgrounds
2. **Audio Assets**: Music loops, sound effects
3. **Game Balance**: Difficulty tuning, scoring system
4. **Polish**: Animations, particles, juice

## 📄 License

This is a game jam project. License to be determined.