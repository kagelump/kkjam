# KKJam - Endless Match-3 Critter Merger

An endless Match-3 puzzle game built in Godot 4 where you match and merge critters into musicians to create the ultimate band!

**🎮 [Play Live on GitHub Pages](https://kagelump.github.io/kkjam/)** | [Deployment Guide](progress_docs/DEPLOYMENT.md)

## Current Status: Phase 2.5 Complete ✓

### Implemented Features (Phase 1 & 2)
- ✅ 8x8 grid generation with randomized Level 1 critters
- ✅ No-initial-matches algorithm ensures clean board starts
- ✅ Click-to-select and swap mechanics
- ✅ Match-3 detection (horizontal and vertical)
- ✅ **Merge System**: 3 matching critters merge into 1 higher level
  - **On Board**: Level 1 + 1 + 1 → Level 2, Level 2 + 2 + 2 → Level 3
  - **On Stage**: Level 3 + 3 + 3 → Level 4, Level 4 + 4 + 4 → Level 5 (max)
- ✅ Gravity and refill logic (critters fall, new ones spawn from top)
- ✅ Cascading matches (new matches are detected after refills)
- ✅ 3 critter types with distinct colors:
  - 🎹 Melody (Blue/Cyan)
  - 🥁 Drums (Red/Pink)
  - 🎛️ Pad (Green)
- ✅ 5 critter levels with visual progression:
  - Level 1-2: Board only (no music)
  - Level 3-5: Stage critters (adds music layers)
  - Visual size increases with level
  - Brightness increases with level
  - Level numbers displayed on each critter
- ✅ **Stage Collection System**:
  - Level 3+ critters fly to the Stage area at the top
  - Multiple critters of same type can be on stage simultaneously
  - Stage critters can merge (3 Level 3s → 1 Level 4, etc.)
  - Each critter type has a dedicated stage position
  - Bouncing animations on stage critters
- ✅ **Concert Trigger**: When all 3 critter types reach Level 5 on stage
  - Requires 27+ Level 3s per type (81+ total matches)
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
   - **On Board**: 3 Level 1s → 1 Level 2, 3 Level 2s → 1 Level 3
   - **On Stage**: 3 Level 3s → 1 Level 4, 3 Level 4s → 1 Level 5
6. **Level 3+ critters fly to the Stage** at the top
7. **Build your band**: Collect multiple critters on stage and merge them to higher levels
8. **Music layers activate** based on highest level on stage:
   - Level 3: Basic layer, Level 4: Medium layer, Level 5: Maximum layer
9. **Trigger the Concert**: Get one Level 5 of each type (Melody, Drums, Pad)
10. After the concert, the board resets and the game gets faster

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
  - audio_manager.gd   # Autoload: dynamic music layering and SFX playback
  - game_manager.gd    # Main game logic coordinator
  - grid.gd            # Grid management and input handling
  - critter.gd         # Critter properties and behavior
  - match_controller.gd # Match detection and resolution
  - stage_display.gd   # Stage UI for collected Level 3 critters

/BGM/
  # Background music (.mp3) and SFX (.wav) assets
```

### Next Steps (Phase 3 - The Loop & Shuffle)
- [ ] Implement deadlock detection (check all possible swaps)
- [ ] Implement shuffle mechanic (randomize grid when no moves available)
- [ ] Add manual shuffle button with cooldown
- [ ] Implement full audio integration with loop/shuffle (3 stems: Drums, Melody, Pad; `AudioManager` autoload)
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