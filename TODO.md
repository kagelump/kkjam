# Game Design Document: Merge & Play

## Overview
**Merge & Play** is a 2D endless puzzle game built in Godot where players combine adorable critters to create and evolve music loops. The gameplay blends Tetris-style falling mechanics with dynamic music composition. As critters merge, their music evolves, and the player races against rising tempo to create "Ultimate Songs" by assembling 4 Level 3 critters.

This game is designed for a short development timeline, focusing on polished mechanics, charming visuals, and an escalating musical challenge.

---

## Core Features
### 1. **Tetris-Style Falling Mechanics**
- **Grid**: A 6x12 grid (6 columns wide, 12 rows tall) where critters fall from the top.
- **Falling**: Random Level 1 critters spawn at the top and fall at regular intervals.
- **Player Control**: Players can move falling critters left/right and rotate their position before they land.
- **Gravity**: Critters stack from the bottom up; when a row is full or matches occur, critters merge.
- **Game Over**: When the stack reaches the top of the grid, the game ends.

### 2. **Merging System**
- **3-Match Evolution**: When 3+ identical critters touch horizontally or vertically, they merge into 1 critter of the next tier.
- **Progression**: Level 1 → Level 2 → Level 3
- **Ultimate Song**: When 4 different Level 3 critters are on the board simultaneously, they create an "Ultimate Song" (special visual/audio effect), then disappear, clearing significant space.

### 3. **Dynamic Music & Rising Tempo**
- **Music Layers**: Each critter type plays a continuous loop layer (drums, bass, melody, harmony).
- **Evolving Loops**: Higher-level critters have richer, more complex audio.
- **Escalating BPM**: Every 30 seconds (or after each Ultimate Song), the global BPM increases by 5-10, making music faster and fall speed quicker.
- **Seamless Syncing**: All loops stay in sync despite tempo changes.

### 4. **Cute Critters**
- **Drummer Bunny**: Percussion layer.
- **Melody Cat**: Melodic layer.
- **Bass Frog**: Bassline layer.
- **Harmony Bird**: Harmony/vocal support.
- Each critter has 3 evolution stages, with corresponding visual and audio upgrades.

### 5. **Endless Scoring**
- **Points**: Earned by merging critters, creating Ultimate Songs, and surviving longer.
- **Combo System**: Consecutive merges or chain reactions multiply points.
- **High Score**: The goal is to survive as long as possible and achieve the highest score.

---

## Art and Style
### **Visuals**
- **Art Style**: Minimalist, flat colors with an emphasis on adorable character design.
- **Characters**: Bouncy, lively animations for each critter (e.g., idle bounce, dancing while playing music).
- **Environment**: Simple gradient backgrounds to keep the focus on the grid and critters.
- **Merging Animations**: Fun visual effects when critters evolve (e.g., sparkles, glows, or small explosions).

### **Sound and Music**
- **Focus on Loops**: Each critter's audio is a short loop that harmonizes with other critters.
- **Mood**: Music will be upbeat, bouncy, and playful, with layers that build as the game progresses.
- **Sound Effects**: Satisfying feedback for merging, placements, and combos (e.g., soft pops, jingles).

---

## Gameplay Mechanics
### **Grid System**
- **Size**: 6 columns × 12 rows (similar to Tetris dimensions).
- **Falling Mechanic**: Every X seconds (based on BPM), a new random Level 1 critter spawns at the top.
- **Player Control**: 
  - Move left/right with arrow keys
  - Soft drop (speed up fall) with down arrow
  - Hard drop (instant placement) with spacebar
- **Stacking**: Critters land on the bottom or on top of other critters.
- **Match Detection**: After each placement, check for 3+ identical adjacent critters (horizontal/vertical).
- **Gravity After Merge**: When critters merge and disappear, critters above fall down to fill gaps.

### **Critter Evolution**
Each critter evolves through 3 tiers:
#### Drummer Bunny
- Level 1: Soft kicks (BOOM ... BOOM).
- Level 2: Drum and hi-hat combo (BOOM-TSS ... BOOM-TSS).
- Level 3: Full drum groove with rhythmic fills.

#### Melody Cat
- Level 1: Simple melody loop.
- Level 2: Adds harmony and complexity.
- Level 3: Full, bouncing melodic verse.

#### Bass Frog
- Level 1: Basic bass plucks (dum ... dum ...).
- Level 2: Groovy bassline with syncopation.
- Level 3: Funky slap bass with vibrato.

#### Harmony Bird
- Level 1: Ethereal humming (ahhh...).
- Level 2: Two-part harmony.
- Level 3: Full choir with dynamic movement.

### **Ultimate Song Mechanic**
- **Trigger**: When 4 different critter types all reach Level 3 on the board at the same time.
- **Effect**: 
  - A special 2-4 bar "ultimate" music phrase plays (all loops harmonize into a climax)
  - Visual celebration (particles, screen shake, glow effects)
  - All 4 Level 3 critters disappear, clearing major board space
  - Player earns a large point bonus (e.g., 1000 points)
- **Strategy**: Players must balance evolving different critter types vs. managing board space.

### **Escalating Difficulty**
- **BPM Increase**: Every 30 seconds or after each Ultimate Song, global BPM increases by 5-10 BPM.
- **Faster Falling**: Fall speed tied to BPM, so critters drop faster as music speeds up.
- **Tension**: Music becomes more frantic, forcing faster decisions.
- **Score Multiplier**: Higher BPM tiers grant score multipliers (1.5x at 140 BPM, 2x at 160 BPM, etc.).

### **Scoring System**
- **Merging**: 
  - Level 1 → Level 2: 10 points × combo multiplier
  - Level 2 → Level 3: 50 points × combo multiplier
- **Ultimate Song**: 1000 points + current BPM tier bonus
- **Survival Bonus**: Points per second survived
- **Combo Multiplier**: Chain merges within 3 seconds for 2x, 3x, 4x bonuses

---

## Technical Design
### **Godot Project Structure**
#### Scenes
1. **Main Menu Scene**
   - `Control` node for the UI.
   - Buttons: Start Game, High Scores, Settings, Credits.

2. **Game Scene**
   - `Node2D` root.
   - **Grid**: 6×12 `TileMap` or 2D array representation.
   - **Active Critter**: The currently falling critter (separate node).
   - **Stacked Critters**: Grid positions filled with critter instances.
   - **UI Overlay**: Score, current BPM, next critter preview.
   - `MusicPlayer` node for dynamic audio layering.

3. **Critter Scene (Reusable)**
   - **Nodes**:
     - `Sprite`: Displays the critter (with 3 frames for evolution stages).
     - `AnimationPlayer`: Handles animations (idle bounce, merge effect, ultimate song celebration).
     - Properties: `critter_type` (Bunny/Cat/Frog/Bird), `level` (1/2/3).

4. **Audio Manager (Autoload Singleton)**
   - Manages 4 base loops (one per critter type, 3 variations per type).
   - BPM controller: Adjusts `AudioStreamPlayer.pitch_scale` to speed up loops.
   - Functions:
     - `update_layers()`: Turn on/off loops based on active critters.
     - `increase_bpm(amount)`: Speed up all loops simultaneously.
     - `play_ultimate_song()`: Trigger special victory phrase.

#### Nodes and Systems
- **Grid System**:
  - 2D array `grid[12][6]` to track critter positions.
  - Functions:
    - `spawn_critter()`: Create new random Level 1 critter at top.
    - `move_active_critter(direction)`: Handle player input (left/right/down).
    - `lock_critter()`: Place active critter into grid when it lands.
    - `check_matches()`: Flood-fill or BFS to find 3+ adjacent identical critters.
    - `merge_critters(positions)`: Remove matched critters, spawn higher-tier one.
    - `apply_gravity()`: Drop floating critters after merges.
    - `check_ultimate_song()`: Detect if 4 different Level 3 types exist.
    - `check_game_over()`: Return true if top row is blocked.

- **Fall Timer**:
  - `Timer` node that ticks based on current BPM.
  - Every tick, active critter moves down one row.
  - Recalculates interval when BPM increases: `interval = 60.0 / (BPM * ticks_per_beat)`

- **Audio System**:
  - 4 `AudioStreamPlayer` nodes (one per critter type).
  - Each has 3 looped audio files (Level 1, 2, 3 variations).
  - Dynamically switch which file plays based on highest level of that critter type on board.
  - All loops pre-synced to same bar length (e.g., 4 bars at 120 BPM).
  - Pitch scaling handles BPM changes without re-importing audio.

---

## Development Plan
### **Phase 1**: Core Falling Mechanics (Day 1-2)
- Set up 6×12 grid system.
- Implement critter spawning at top.
- Implement player controls (left/right/drop).
- Implement gravity and stacking.
- Add basic critter sprites (simple colored squares as placeholders).
- Implement game over detection.

### **Phase 2**: Merging Logic (Day 2-3)
- Implement match detection (flood-fill algorithm for 3+ adjacent).
- Implement critter evolution (Level 1 → 2 → 3).
- Implement gravity after merges (fill gaps).
- Add visual feedback for merges (simple particle effect).
- Test merge chains and combos.

### **Phase 3**: Ultimate Song & Scoring (Day 3-4)
- Implement Ultimate Song detection (4 different Level 3 critters).
- Add special effects for Ultimate Song (screen shake, particles, sound).
- Implement scoring system (merges, combos, survival, Ultimate Songs).
- Add UI: score display, BPM display, next critter preview.

### **Phase 4**: Audio Integration (Day 4-5)
- Create/source 4 base loops (drums, bass, melody, harmony).
- Create 3 variations per loop (Level 1/2/3).
- Implement Audio Manager with layer switching.
- Sync all loops to same bar length (120 BPM, 4 bars = 8 seconds).
- Implement BPM escalation system (pitch scaling).
- Add sound effects (merge, drop, ultimate song trigger).

### **Phase 5**: Art & Animation (Day 5-6)
- Design 4 critter types (Bunny, Cat, Frog, Bird).
- Create 3 evolution stages per critter (12 sprites total).
- Add idle animations (bounce/wiggle).
- Add merge animation (shrink + poof + grow).
- Add Ultimate Song animation (all 4 critters glow/dance).
- Polish background (gradient or subtle pattern).

### **Phase 6**: Polish & Juice (Day 6-7)
- Add particle effects (merge sparkles, ultimate song explosion).
- Add screen shake on Ultimate Song.
- Polish UI (fonts, layout, high score display).
- Add combo feedback (visual multiplier text).
- Implement persistent high score (saved to file).
- Add simple tutorial overlay on first play.

### **Phase 7**: Testing & Export (Day 7)
- Playtest and balance (BPM increase rate, scoring, difficulty curve).
- Fix bugs.
- Export to Web (HTML5) and desktop builds.
- Write itch.io page description.

---

## Team Responsibilities
- **Programmer**: Set up Godot project, implement grid logic, match detection, and critter evolution.
- **Illustrator**: Design critter art/animations, background assets, and UI visuals.
- **Sound Designer**: Compose critter loops, sound effects, and synchronize audio layers.

---

## Balancing & Tuning Notes
- **Starting BPM**: 100 BPM (comfortable, relaxed pace).
- **BPM Increase Rate**: +10 BPM every 30 seconds or after each Ultimate Song.
- **Max BPM**: Cap at 200 BPM to prevent unplayable speeds.
- **Fall Speed Formula**: `fall_interval = 60.0 / (BPM / 30)` (at 120 BPM, critter falls 1 row every 0.5 seconds).
- **Spawn Randomness**: Equal chance for each of the 4 critter types (25% each).
- **Grid Size Rationale**: 6 columns gives space for strategy without overwhelming, 12 rows provides buffer before game over.

---

## Stretch Goals
- **Power-ups**: Rare "wildcard" critters that can match with any type.
- **Special Critters**: Synth Owl or Guitar Fox that add bonus layers.
- **Daily Challenge Mode**: Fixed seed with global leaderboard.
- **Custom Skins**: Unlock alternate visual styles for critters.
- **Replay System**: Save and share your best runs with a replay file.
