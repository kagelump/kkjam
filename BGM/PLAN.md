# Audio Integration Plan

## Overview
This plan outlines the integration of the new dynamic background music (BGM) and sound effects (SFX) into the game. The core concept is to tie the music layers to the game state, specifically the presence and level of the different Critter types.

## 1. Game Design Updates
To align with the 3 distinct musical themes (Melody, Drums, Pad), we will reduce the number of Critter types from 4 to 3.

*   **Action**: Update `Critter.CritterType` enum.
    *   Current: `BUNNY`, `CAT`, `FROG`, `BIRD` (4 types)
    *   New: `MELODY` (Critter 1), `DRUMS` (Critter 2), `PAD` (Critter 3). (We can keep the animal names but map them to these roles).
*   **Action**: Update `Grid.gd` generation logic to spawn only 3 types.

## 2. Asset Mapping

### Music Layers (Adaptive BGM)
The music is divided into 3 "Instruments" (Critters), each with 3 "Intensity Layers".

| Critter Type | Role | Layer 1 (Level 1) | Layer 2 (Level 2) | Layer 3 (Level 3) |
| :--- | :--- | :--- | :--- | :--- |
| **Critter 1** | Melody/Harmony | `C1 Layer 1.wav` (and variants) | `C1 Layer 2.wav` | `C1 Layer 3.wav` |
| **Critter 2** | Drums | `C2 Layer 1.wav` | `C2 Layer 2.wav` | `C2 Layer 3.wav` |
| **Critter 3** | Pad/Atmosphere | `C3 Layer 1.wav` | `C3 Layer 2.wav` | `C3 Layer 3.wav` |

*   **Pregame/Menu**: `C1 Layer 1_PREGAME.wav`
*   **Full Mix Reference**: `full_track.wav`

### Sound Effects (SFX)
| Event | Asset | Description |
| :--- | :--- | :--- |
| **Match / Merge (Small)** | `FX 1.wav` | Basic match or Level 1 creation. |
| **Match / Merge (Medium)** | `FX 2.wav` | 4-match or Level 2 creation. |
| **Match / Merge (Large)** | `FX 3.wav` | 5-match or Level 3 creation. |
| **Combo / Special** | `fullcombo_BASS.wav` | Played on high combo count or board clear. |

## 3. Implementation Strategy

### AudioManager (Singleton)
We will create a global `AudioManager` to handle the synchronization and mixing of these tracks.

*   **Synchronization**: All music layers must start simultaneously and loop seamlessly.
*   **Volume Control**: We will not stop/start tracks to change layers. Instead, we will have all 9 layers (or 3 active layers per critter) playing in sync and control their volume (0.0 to 1.0) to fade them in/out.

### Dynamic Logic
The music intensity for each Critter Type will be determined by the **highest level** of that critter currently on the board.

*   **Logic Loop (checked on board update):**
    1.  Scan board for max level of Critter 1.
        *   None -> Volume 0.
        *   Level 1 -> Fade in Layer 1, Fade out others.
        *   Level 2 -> Fade in Layer 2, Fade out others.
        *   Level 3 -> Fade in Layer 3, Fade out others.
    2.  Repeat for Critter 2 and Critter 3.

This creates a dynamic mix where the music evolves as the player builds up their board.

## 4. Tasks

### Phase 1: Setup
- [ ] Create `BGM` folder in Godot project and import WAV files.
- [ ] Configure import settings: Enable looping for music, disable for SFX.
- [ ] Create `AudioManager.gd` (Autoload).

### Phase 2: Code Changes
- [ ] Modify `Critter.gd` to reflect 3 types.
- [ ] Modify `Grid.gd` to spawn 3 types.
- [ ] Implement `AudioManager` logic to manage `AudioStreamPlayers`.
- [ ] Connect `GameManager` or `Grid` signals to `AudioManager` to trigger state changes.

### Phase 3: Polish
- [ ] Tune fade times (e.g., 1-second crossfades).
- [ ] Implement SFX triggers in `MatchController`.
- [ ] Test synchronization.
