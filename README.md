# KKJam - Endless Match-3 Critter Merger

An endless Match-3 puzzle game built in Godot 4 where you match and merge critters into musicians to create the ultimate band!

**🎮 [Play Live on GitHub Pages](https://kagelump.github.io/kkjam/)** | [Deployment Guide](DEPLOYMENT.md)

## Current Status: Phase 2 Complete ✓

### Implemented Features (Phase 1 & 2)
- ✅ 8x8 grid generation with randomized Level 1 critters
- ✅ No-initial-matches algorithm ensures clean board starts
- ✅ Click-to-select and swap mechanics
- ✅ Match-3 detection (horizontal and vertical)
- ✅ **Merge System**: 3 matching critters merge into 1 higher level
  - Level 1 + Level 1 + Level 1 → Level 2
  - Level 2 + Level 2 + Level 2 → Level 3
- ✅ Gravity and refill logic (critters fall, new ones spawn from top)
- ✅ Cascading matches (new matches are detected after refills)
- ✅ 4 critter types with distinct colors:
  - 🥁 Bunny (Red/Pink) - Drummer
  - 🎹 Cat (Blue/Cyan) - Melody
  - 🎸 Frog (Green) - Bass
  - 🎤 Bird (Yellow/Orange) - Harmony
- ✅ 3 critter levels with visual progression:
  - Visual size increases with level
  - Brightness increases with level
  - Level numbers displayed on each critter
- ✅ **Stage Collection System**:
  - Level 3 critters fly to the Stage area at the top
  - Collected critters persist visually on stage
  - Each critter type has a dedicated stage position
  - Bouncing animations on stage critters
- ✅ **Concert Trigger**: When all 4 Level 3 critters are collected
  - Album counter increments
  - Board completely resets
  - BPM increases for difficulty scaling
- ✅ **Polish & Juice**:
  - Smooth swap animations
  - Bounce animation on critter click
  - Shake animation on invalid swaps
  - Flying animation for Level 3 critters going to stage
- ✅ Basic UI with title and instructions

### How to Play
1. Open the project in Godot 4.2+
2. Run the main scene (`scenes/main.tscn`) or use `make run`
3. Click a critter to select it (it will brighten and bounce)
4. Click an adjacent critter to swap them
5. **Match 3 or more critters** of the same type AND level to merge them:
   - 3 Level 1s → 1 Level 2 (at the swap location)
   - 3 Level 2s → 1 Level 3
6. **Level 3 critters fly to the Stage** at the top and stay there
7. **Collect all 4 types** (Bunny, Cat, Frog, Bird) to trigger a Concert!
8. After the concert, the board resets and the game gets faster

### Development
```bash
make test       # Run all tests
make test-unit  # Run unit tests only
make run        # Launch the game
make help       # Show all commands
```

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
  - stage_display.gd   # Stage UI for collected Level 3 critters

/assets/
  - /sprites/          # (Placeholder - using colored squares for now)
  - /audio/            # (Placeholder for future music implementation)
```

### Next Steps (Phase 3 - The Loop & Shuffle)
- [ ] Implement deadlock detection (check all possible swaps)
- [ ] Implement shuffle mechanic (randomize grid when no moves available)
- [ ] Add manual shuffle button with cooldown
- [ ] Create MusicLayers node with 4 AudioStreamPlayer children
- [ ] Implement dynamic music layering based on grid state
- [ ] Add full audio integration (Drums, Bass, Melody, Harmony stems)
- [ ] Implement BPM scaling with Album count

### Next Steps (Phase 4 - Polish & Combo System)
- [ ] Implement combo counter for consecutive matches
- [ ] Add combo multiplier for score
- [ ] Create combo UI popup ("Combo x2", "Combo x3")
- [ ] Add musical feedback for combos (ascending pitches)
- [ ] Particle effects for merges and stage collection
- [ ] Enhanced animations and transitions
- [ ] UI polish and feedback improvements

See [TODO.md](TODO.md) for the complete game design document.