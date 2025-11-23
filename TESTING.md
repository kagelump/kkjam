# Testing Guide - Phase 1 MVP

## How to Run the Project

### Prerequisites
- Godot Engine 4.2 or later
- Download from: https://godotengine.org/download

### Steps to Run
1. Clone the repository
2. Open Godot Engine
3. Click "Import" and navigate to the project folder
4. Select the `project.godot` file
5. Click "Import & Edit"
6. Press F5 or click the "Play" button to run the game

## Manual Testing Checklist

### Grid Generation ✓
- [ ] Verify 8x8 grid appears on screen
- [ ] Verify grid is filled with colored squares (critters)
- [ ] Verify 4 different colors appear (red/pink, blue/cyan, green, yellow/orange)
- [ ] Verify critters have slightly different sizes (levels)

### Selection Mechanics ✓
- [ ] Click a critter - it should brighten (selected state)
- [ ] Click the same critter again - it should deselect
- [ ] Click a different critter while one is selected - should attempt swap

### Swap Mechanics ✓
- [ ] Select a critter and click an adjacent critter (up/down/left/right)
- [ ] If the swap creates a match, critters should swap positions
- [ ] If the swap doesn't create a match, nothing happens (message in console)
- [ ] Diagonal swaps should not work

### Match Detection ✓
- [ ] When 3 or more critters of same color and size align horizontally, they disappear
- [ ] When 3 or more critters of same color and size align vertically, they disappear
- [ ] Console shows "Match resolved" message with details

### Gravity & Refill ✓
- [ ] After matches are removed, critters above fall down
- [ ] New critters spawn from the top to fill empty spaces
- [ ] Multiple cascading matches can occur (chain reactions)

### Edge Cases to Test
- [ ] Swapping at grid edges (top, bottom, left, right)
- [ ] Matching 4 or 5 in a row (should work same as 3)
- [ ] Multiple matches from a single swap
- [ ] Board state after several moves

## Console Output
The game prints helpful debug messages:
- "Selected: [Type] at (x, y)" - when selecting a critter
- "Match resolved: [count] [type] Level [level]" - when matches are found
- "Found X matches" - match detection results
- "Cascade! Found X new matches" - when refill creates new matches
- "Swap would not create a match" - invalid swap attempt

## Known Limitations (Phase 1)
This is the MVP for Phase 1 only. The following are NOT yet implemented:
- ❌ Merging (critters just disappear instead of merging into higher levels)
- ❌ The Stage UI (where Level 3 critters perform)
- ❌ Concert mechanic
- ❌ Difficulty scaling
- ❌ Score tracking
- ❌ Audio/music layers
- ❌ Animations (beyond basic movement tweens)
- ❌ Shuffle mechanic
- ❌ Proper sprites (currently using colored rectangles)

These features will be added in Phase 2 and beyond.
