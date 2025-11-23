# Development Guide - Critter Composer

This guide provides next steps for developing the Critter Composer game.

## Quick Start

1. **Open in Godot**
   - Launch Godot Engine 4.2+
   - Click "Import" and select the `project.godot` file
   - The project will open with the main scene

2. **Test the Structure**
   - Press F5 to run the project
   - You should see a colored background (the game board is currently invisible as critters are placeholders)

## Next Development Steps

### Phase 1: Visual Assets (High Priority)
The game currently uses colored rectangles as placeholders. Add actual graphics:

1. **Critter Sprites**
   - Create 5 critter types (one for each music layer)
   - Each needs 3 evolution levels (base, evolved 1, evolved 2)
   - Recommended size: 64x64 pixels, PNG format
   - Place in: `assets/sprites/critters/`
   - Naming: `critter_[type]_[level].png` (e.g., `critter_0_base.png`)

2. **Update Critter Scene**
   - Open `scenes/critter.tscn`
   - Add Sprite2D node with actual textures
   - Update `scripts/critter.gd` to load appropriate sprites based on type and evolution

3. **UI Graphics**
   - Button graphics
   - Background image
   - Panel decorations
   - Place in: `assets/sprites/ui/`

### Phase 2: Audio Assets (High Priority)
The audio system is ready but needs actual audio files:

1. **Music Loops**
   - Create 5 base music loops (one per critter type):
     * Bass/Rhythm
     * Melody
     * Percussion
     * Harmony
     * Lead
   - Each loop should have 3 evolution levels
   - Format: OGG or WAV
   - Length: 4 measures at 120 BPM (~8 seconds)
   - Place in: `assets/audio/music/`
   - Naming: `[type]_[level].ogg` (e.g., `bass_base.ogg`)

2. **Sound Effects**
   - Match sound (satisfying pop/chime)
   - Swap sound (whoosh)
   - Evolution sound (magical sparkle)
   - Combo sound (escalating notes)
   - Place in: `assets/audio/sfx/`

3. **Link Audio to Critters**
   - Update `scripts/critter.gd` to load appropriate audio loops
   - Connect critter creation to audio manager
   - Test layering and mixing

### Phase 3: Animations (Medium Priority)

1. **Critter Swap Animation**
   - In `scripts/game_board.gd`, find `_swap_pieces()`
   - Add tween animation to smoothly move critters
   - Duration: 0.3 seconds

2. **Match Removal Animation**
   - In `scripts/game_board.gd`, find `_remove_matches()`
   - Add particle effects
   - Fade out animation
   - Scale up effect

3. **Drop Animation**
   - In `scripts/game_board.gd`, find `_settle_board()`
   - Animate critters falling down
   - Add bounce effect on landing

4. **Evolution Animation**
   - Already has basic scale animation in `scripts/critter.gd`
   - Add particle effects
   - Color transition
   - Musical notes sprite

### Phase 4: Game Logic Enhancements (Medium Priority)

1. **Critter Instance Integration**
   - Update `_create_critter_at()` in `game_board.gd`
   - Actually instance the critter scene
   - Add to grid_container as child
   - Connect signals

2. **Audio Integration**
   - When critters match, play their audio loops
   - Connect AudioManager to Main scene
   - Add methods to trigger sound effects

3. **Evolution System**
   - Track how many times each critter type has been matched
   - Trigger evolution at thresholds
   - Upgrade audio loops accordingly

4. **Game Over Conditions**
   - Define win/loss conditions
   - Add move limit or time limit
   - Target score system

### Phase 5: Menus and UI (Low Priority)

1. **Main Menu**
   - Create `scenes/menu.tscn`
   - Start game button
   - Options button
   - Credits

2. **Game Over Screen**
   - Show final score
   - Display music composition created
   - Replay button
   - Menu button

3. **Settings**
   - Volume controls (Master, Music, SFX)
   - Graphics options
   - Controls help

### Phase 6: Polish (Final Phase)

1. **Juice**
   - Screen shake on big matches
   - Particle effects everywhere
   - Color flashes on matches
   - Smooth camera movements

2. **Tutorial**
   - First-time player guide
   - Highlight interactive elements
   - Explain music system

3. **Balance Testing**
   - Adjust scoring
   - Tune difficulty
   - Test match frequency
   - Ensure musical progression feels rewarding

## Testing Checklist

- [ ] Can start the game
- [ ] Can select critters
- [ ] Can swap adjacent critters
- [ ] Matches are detected correctly
- [ ] Score increases on matches
- [ ] New critters fall from top
- [ ] Cascades work correctly
- [ ] Audio layers add properly
- [ ] Evolution triggers at right time
- [ ] UI updates correctly
- [ ] Game can be paused
- [ ] Game can be reset

## Technical Notes

### Current Limitations
1. Critters are placeholders (colored rectangles)
2. No actual sprite rendering yet
3. Audio loops not connected
4. Animations are timing-only (no visual movement)
5. Match detection works but needs visual feedback

### Architecture Decisions
- **Signal-based**: Uses Godot signals for loose coupling
- **Modular**: Each system (board, UI, audio) is independent
- **Data-driven**: Critter types and properties can be easily expanded
- **Scene-based**: Uses Godot's scene instancing for critters

### Performance Considerations
- Grid is only 8x8, so performance should be excellent
- Audio layer limit might need testing (5+ simultaneous loops)
- Particle effects should be pooled if performance issues arise

## Common Tasks

### Adding a New Critter Type
1. Increase `CRITTER_TYPES` in `game_board.gd`
2. Add new color to `color_palette` in `critter.gd`
3. Add new name to `type_names` in `critter.gd`
4. Create sprites for all evolution levels
5. Create audio loops for all evolution levels

### Changing Grid Size
1. Update `GRID_WIDTH` and `GRID_HEIGHT` in `game_board.gd`
2. Update `CELL_SIZE` if needed for screen fit
3. Adjust camera or viewport settings in `project.godot`

### Adjusting Audio
1. Change `base_bpm` in `audio_manager.gd`
2. Update loop lengths accordingly
3. Re-export all audio files at new BPM

## Resources

- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Match-3 Tutorial](https://docs.godotengine.org/en/stable/community/tutorials.html)
- [Audio in Godot](https://docs.godotengine.org/en/stable/tutorials/audio/index.html)

## Getting Help

If you encounter issues:
1. Check the Godot console for errors (Output panel)
2. Review signal connections in the Scene panel
3. Add print statements for debugging
4. Check that scene paths are correct in .tscn files
