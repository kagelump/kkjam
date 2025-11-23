# KKJam - Endless Match-3 Critter Merger

An endless Match-3 puzzle game built in Godot 4 where you match and merge critters into musicians to create the ultimate band!

## Current Status: Phase 1 MVP Complete ✓

### Implemented Features (Phase 1)
- ✅ 8x8 grid generation with randomized Level 1 critters
- ✅ Click-to-select and swap mechanics
- ✅ Match-3 detection (horizontal and vertical)
- ✅ Gravity and refill logic (critters fall, new ones spawn from top)
- ✅ Cascading matches (new matches are detected after refills)
- ✅ 4 critter types with distinct colors:
  - 🥁 Bunny (Red/Pink) - Drummer
  - 🎹 Cat (Blue/Cyan) - Melody
  - 🎸 Frog (Green) - Bass
  - 🎤 Bird (Yellow/Orange) - Harmony
- ✅ 3 critter levels (visual size increases with level)
- ✅ Basic UI with title and instructions

### How to Play
1. Open the project in Godot 4.2+
2. Run the main scene (`scenes/main.tscn`)
3. Click a critter to select it (it will brighten)
4. Click an adjacent critter to swap them
5. Match 3 or more critters of the same type and level
6. Watch them disappear and new critters fall from the top!

### Project Structure
```
/scenes/
  - main.tscn          # Main game scene
  - critter.tscn       # Reusable critter scene

/scripts/
  - game_manager.gd    # Main game logic coordinator
  - grid.gd            # Grid management and input handling
  - critter.gd         # Critter properties and behavior
  - match_controller.gd # Match detection and resolution

/assets/
  - /sprites/          # (Placeholder - using colored squares for now)
  - /audio/            # (Placeholder for future music implementation)
```

### Next Steps (Phase 2)
- [ ] Implement merge mechanic (3 Level 1s → 1 Level 2, etc.)
- [ ] Create "The Stage" UI area for Level 3 critters
- [ ] Implement "fly to stage" animation
- [ ] Add concert trigger when all 4 Level 3s are collected
- [ ] Implement board reset and difficulty scaling

See [TODO.md](TODO.md) for the complete game design document.