# Game Design Document: KKJam (Endless Match-3)

## Overview
**KKJam** is an endless Match-3 puzzle game built in Godot. Players swap adjacent critters on a grid to match 3 of the same type. Unlike standard Match-3 games where items disappear, matches here merge critters into higher-level musicians (Level 1 → 2 → 3).

The goal is to create one Level 3 critter of each type (Drum, Bass, Melody, Harmony). Once all four occupy the "Stage," an "Ultimate Concert" triggers, the song completes, an "Album" is recorded (score counter), and the game loops to the next "Tour Stop" with higher difficulty and tempo.

---

## Core Features
### 1. Match & Merge Mechanics
- **Grid**: An 8x8 grid filled with randomized Level 1 critters.
- **Swapping**: Players click and drag (or click-click) to swap two adjacent critters.
- **Matching Rule**: Aligning 3 or more identical critters (same type AND level) causes a merge.
- **The Merge**:
  - 3 Level 1s → Merge into 1 Level 2 (at the swap location).
  - 3 Level 2s → Merge into 1 Level 3.
- **Cascading**: The extra empty spaces created by the merge are filled by new Level 1 critters dropping from the top.

### 2. The "Stage" & Collection System
- **Banking Critters**: When a player creates a Level 3 Critter, it immediately "flies" off the board and takes its spot on the **Stage** (UI area above the grid).
- **Music Layering**:
  - As soon as a Level 3 critter hits the Stage, its specific "Maximum Intensity" music layer stays permanently active for the rest of the round.
  - While playing on the grid, the background music reflects the highest level critters currently on the board.

### 3. The Loop: Concerts & Tours
- **Trigger**: When the player collects all 4 unique Level 3 critters (Bunny, Cat, Frog, Bird) on the Stage.
- **The Concert**:
  - The board locks.
  - "Ultimate Song" animation plays (fireworks, crowd cheering).
  - **Album Count** increments by 1.
- **The Reset (New Tour Stop)**:
  - The Stage clears.
  - The grid completely refreshes/scrambles.
  - Global BPM increases.
  - Hype Meter drains faster.

### 4. Shuffle Mechanic (Deadlock Prevention)
- **Deadlock Detection**: Since merging reduces the number of items, the board can sometimes reach a state with no possible matches.
- **Auto-Shuffle**: If the game detects zero valid moves, the board automatically shuffles all critters to new positions to create new match opportunities.
- **Manual Shuffle**: A button allows players to manually shuffle the board if they feel stuck (potentially with a cooldown or score cost).

---

## Art and Style
### **Visuals**
- **Art Style**: Minimalist, flat colors, adorable character design.
- **The Stage**: A spotlight area above the grid where collected Level 3s perform.
- **Feedback**: Juicy animations for merging (popping, combining) and "flying" to the stage.

### **Sound and Music**
- **Dynamic Layers**: 4 stems (Drums, Bass, Melody, Harmony).
- **Progression**: Music starts sparse. As Level 2s appear on grid, intensity rises. When Level 3s hit the Stage, that layer goes full volume.
- **Tempo**: Increases with each "Album" completed.

---

## Gameplay Mechanics
### **Grid System**
- **Size**: 8x8.
- **Input**: Mouse/Touch drag or click-swap.
- **Match Logic**:
  - Check for horizontal/vertical lines of 3+.
  - Prioritize the "swap target" as the merge location.
  - Remove matched items, spawn 1 higher-tier item, shift columns down, spawn new Lvl 1s at top.

### **Critter Evolution**
- **Drummer Bunny** (Percussion)
- **Melody Cat** (Melody)
- **Bass Frog** (Bass)
- **Harmony Bird** (Harmony)
- **Evolution**: Lvl 1 (Baby) → Lvl 2 (Teen/Cool) → Lvl 3 (Star).

### **Shuffle Logic**
- **Trigger**: 
  - Automatic: When `find_matches()` returns 0 potential swaps.
  - Manual: Player clicks "Shuffle" button.
- **Effect**: 
  - All critters on the grid play a "jump" animation.
  - Their positions are randomized.
  - Check for immediate matches (optional: prevent immediate matches to force player interaction, or allow them for a "lucky" bonus).

---

## Technical Design
### **Godot Project Structure**
#### Scenes
1. **Main Game Scene**
   - `StageUI`: Top bar showing collected Level 3s and Album Count.
   - `ShuffleButton`: UI button for manual shuffle.
   - `Grid`: 8x8 Node2D container.
   - `AudioSystem`: Manages stems and BPM.

2. **Critter Scene**
   - `Sprite`: Changes texture based on Type/Level.
   - `AnimationPlayer`: Swap, Merge, Fly-to-Stage animations.
   - `Tween`: For smooth falling/swapping movement.

#### Systems
- **MatchController**:
  - `find_matches()`: Scans grid for 3+ sequences.
  - `resolve_matches()`: Handles removal, score, and merge creation.
  - `refill_board()`: Spawns new items.
  - `check_deadlock()`: If no moves possible, auto-shuffle.

- **GameLoopManager**:
  - Tracks "Stage" state (which Lvl 3s are collected).
  - Triggers "Concert" event.
  - Handles difficulty scaling (BPM, Drain Rate).

---

## Development Plan
### **Phase 1**: Core Match-3 (Day 1-2)
- 8x8 Grid generation.
- Swap mechanics.
- Basic Match-3 detection (remove 3).
- Gravity/Refill logic.

### **Phase 2**: Merge & Stage Logic (Day 3-4)
- Change "Remove 3" to "Merge 3 into 1".
- Implement "Fly to Stage" for Level 3s.
- Implement "Concert" trigger and Board Reset.

### **Phase 3: The Loop & Shuffle (Day 5)**
- Implement Deadlock Detection (check all possible swaps).
- Implement Shuffle Mechanic (randomize grid array).
- Implement Difficulty Scaling (Album count -> Speed/BPM).
- Add Audio Layering system.

### **Phase 4**: Polish (Day 6-7)
- Animations (Swap, Pop, Fly).
- Particle effects.
- UI Polish.
- Bug fixing.

---

## Stretch Goals
- **Lose Condition (Hype Meter)**: A timer that drains over time. If it hits 0, game over. Refilled by matches.
- **Special Tiles**: "Wildcard" microphone that matches anything.
- **Fever Mode**: Hype Meter overflows, doubling score for a short time.
- **Unlockable Costumes**: Different outfits for the band.
- **Power-ups**: Rare "wildcard" critters that can match with any type.
- **Special Critters**: Synth Owl or Guitar Fox that add bonus layers.
- **Daily Challenge Mode**: Fixed seed with global leaderboard.
- **Replay System**: Save and share your best runs with a replay file.
