# Game Design Document: KKJam (Endless Match-3)

## Overview
**KKJam** is an endless Match-3 puzzle game built in Godot. Players swap adjacent critters on a grid to match 3 of the same type. Unlike standard Match-3 games where items disappear, matches here merge critters into higher-level musicians (Level 1 → 2 → 3 → 4 → 5).

The goal is to create one Level 5 critter of each type (Melody, Drums, Pad). Level 3+ critters fly to the "Stage" where they can merge further (3× Level 3 → Level 4, 3× Level 4 → Level 5). Once all three types reach Level 5 on stage, an "Ultimate Concert" triggers, an "Album" is recorded, and the game loops to the next "Tour Stop" with higher difficulty and tempo.

**Gameplay Loop Length**: Achieving one Level 5 requires merging 3 Level 4s (which requires 9 Level 3s, which requires 27 board matches). For all 3 types, that's ~81+ matches minimum - a significantly longer and more strategic loop.

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
- **Banking Critters**: When a player creates a Level 3+ Critter, it immediately "flies" off the board and lands on the **Stage** (UI area above the grid).
- **Stage Merging**: Multiple critters of the same type can occupy the stage simultaneously:
  - 3× Level 3 → 1× Level 4 (at stage)
  - 3× Level 4 → 1× Level 5 (at stage, maximum)
- **Music Layering**:
  - Level 1-2 critters on board: **No music layers** (silent practice)
  - Level 3 on stage: **Layer 1** (basic intensity)
  - Level 4 on stage: **Layer 2** (medium intensity)
  - Level 5 on stage: **Layer 3** (maximum intensity)
  - Music intensity per critter type = highest level of that type currently on stage

### 3. The Loop: Concerts & Tours
- **Trigger**: When the player has at least one Level 5 critter of each type (Melody, Drums, Pad) on the Stage.
- **The Concert**:
  - The board locks.
  - "Ultimate Song" animation plays (fireworks, crowd cheering).
  - **Album Count** increments by 1.
- **The Reset (New Tour Stop)**:
  - The Stage clears.
  - The grid completely refreshes/scrambles.
  - Global BPM increases.
  - Difficulty scales (faster gameplay, higher stakes).

### 4. Shuffle Mechanic (Deadlock Prevention)
- **Deadlock Detection**: Since merging reduces the number of items, the board can sometimes reach a state with no possible matches.
- **Auto-Shuffle**: If the game detects zero valid moves, the board automatically shuffles all critters to new positions to create new match opportunities.
- **Manual Shuffle**: A button allows players to manually shuffle the board if they feel stuck (potentially with a cooldown or score cost).

### 5. Combo System (The "Flow" State)
- **Combo Counter**: Tracks consecutive matches made without a break (e.g., cascades or quick successive moves).
- **Visuals**: A "Combo x2", "Combo x3" text pops up near the match.
- **Audio**: Each step in the combo chain plays a higher pitched/more exciting sound effect (C -> E -> G -> High C).
- **Reward**: 
  - Score Multiplier: Points = Base Score * Combo Count.
  - Hype Meter (Stretch): Higher combos refill the meter faster.

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
- **Melody** (Blue/Cyan) - Lead melodies
- **Drums** (Red/Pink) - Percussion
- **Pad** (Green) - Atmospheric synth pad
- **Evolution**: 
  - Lvl 1 (Baby) → Lvl 2 (Teen) [Board only, silent]
  - Lvl 3 (Musician) → Lvl 4 (Star) → Lvl 5 (Legend) [Stage only, adds music layers]

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
- 8x8 Grid generation. (DONE)
- Swap mechanics. (DONE)
- Basic Match-3 detection (remove 3). (DONE)
- Gravity/Refill logic. (DONE)
- **Scene Setup**:
  - Create `InputBlocker` Control node (z-index top) to prevent clicks during animations. (DONE)
  - Create `CritterContainer` Node2D inside Grid to manage z-ordering vs UI. (DONE)
  - Add `DebugUI` CanvasLayer with "Force Win" / "Spawn Lvl 3" buttons for testing. (DONE)

### **Phase 2**: Merge & Stage Logic (Day 3-4) ✓ COMPLETE
- Change "Remove 3" to "Merge 3 into 1". (DONE)
- Implement "Fly to Stage" for Level 3s with smooth animations. (DONE)
- Implement "Concert" trigger and Board Reset. (DONE)
- Create visual Stage display with persistent Level 3 critters. (DONE)
- Add stage reset signal system for clearing the stage. (DONE)
- Implement no-initial-matches generation to ensure clean starts. (DONE)
- Add visual level indicators (numbers on critters). (DONE)
- Add bounce animations on click and shake on invalid swap. (DONE)

### **Phase 2.5**: Extended Gameplay Loop (Current)
- [ ] Extend CritterLevel enum to support Level 4 and Level 5
- [ ] Update stage system to support multiple critters of same type
- [ ] Implement stage-based merging logic (3 Level 3s → 1 Level 4, etc.)
- [ ] Update music layering: only Level 3+ on stage adds music (not board critters)
- [ ] Update concert trigger: requires one Level 5 of each type
- [ ] Update visual scaling for Level 4 and Level 5 critters
- [ ] Test the extended gameplay loop (~81+ matches to win)

### **Phase 3: The Loop & Shuffle (Day 5)**
- **Audio Setup**:
  - Create `MusicLayers` node with 4 `AudioStreamPlayer` children (Drums, Bass, Melody, Harmony).
  - Route them to a custom "Music" audio bus.
- Implement Deadlock Detection (check all possible swaps).
- Implement Shuffle Mechanic (randomize grid array).
- Implement Difficulty Scaling (Album count -> Speed/BPM).
- Add Audio Layering system.

### **Phase 4**: Polish (Day 6-7)
- Animations (Swap, Pop, Fly).
- Particle effects.
- UI Polish.
- Bug fixing.
- **Combo System**:
  - Track cascade chains in `MatchController`.
  - Add UI popup for Combo Count.
  - Implement score multiplier logic.

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
