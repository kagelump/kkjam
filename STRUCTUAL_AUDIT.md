# Structural Audit

This document is a checklist for cleaning up structural issues in the KKJam codebase. Each item is sized so a junior developer can pick it up, fix it, run `make test`, and ship it.

Before starting any item:

1. Run `make test` to confirm the baseline is green.
2. Run `make run` and verify the game still launches.
3. Create a feature branch per item (or per cluster of related items).

After finishing any item, run `make test` again before committing.

---

## Suggested First Cleanup Pass (Low-Risk)

These are surface-level fixes. None of them change game behavior. Do them first to reduce noise before tackling the architectural refactors.

### 1. Delete or fix the dead `MusicLayers` subtree in `main.tscn`

**Problem.** `scenes/main.tscn` declares a `MusicLayers` node with four children (`Drums`, `Bass`, `Melody`, `Harmony`):

```39:47:scenes/main.tscn
[node name="MusicLayers" type="Node" parent="."]

[node name="Drums" type="AudioStreamPlayer" parent="MusicLayers"]

[node name="Bass" type="AudioStreamPlayer" parent="MusicLayers"]

[node name="Melody" type="AudioStreamPlayer" parent="MusicLayers"]

[node name="Harmony" type="AudioStreamPlayer" parent="MusicLayers"]
```

Nothing in the project references those nodes. `scripts/audio_manager.gd` is registered as the `AudioManager` autoload (see `project.godot` `[autoload]` section) and creates its own `AudioStreamPlayer` pool dynamically in `setup_audio()`. Also, the names contradict the design: `TODO.md` and `AGENTS.md` describe **3 stems (Drums, Melody, Pad)**, not 4 with Bass/Harmony.

**How to fix.**

1. Open `scenes/main.tscn` in the Godot editor.
2. In the Scene panel, right-click the `MusicLayers` node and choose **Delete Node**. This will remove `Drums`, `Bass`, `Melody`, `Harmony`, and the parent.
3. Save the scene.
4. Search the project for any string match of `"MusicLayers"`, `"$MusicLayers"`, or `get_node("MusicLayers")` and confirm there are no remaining references. (There shouldn't be.)

**Acceptance criteria.**

- `main.tscn` no longer contains a `MusicLayers` node.
- `make test` and `make run` still work.
- Music still plays in-game (the autoload `AudioManager` is unaffected).

---

### 2. Delete `test/run_tests.gd` and stale phase summaries

**Problem.** `test/run_tests.gd` is dead code — its own header tells you to use the official GUT CLI:

```5:8:test/run_tests.gd
# RECOMMENDED: Use GUT's built-in CLI instead:
#   godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/
#
# This file exists for reference but the official GUT CLI is more reliable.
```

`Makefile` and both GitHub workflows (`tests.yml`, `deploy.yml`) use the GUT CLI directly, so nothing depends on this file.

`progress_docs/PHASE1_SUMMARY.md`, `progress_docs/TEST_FIX_SUMMARY.md`, and `progress_docs/TEST_IMPLEMENTATION_SUMMARY.md` are point-in-time progress logs whose information is duplicated in `AGENTS.md` and git history.

**How to fix.**

1. Delete the following files:
   - `test/run_tests.gd`
   - `test/run_tests.gd.uid`
   - `progress_docs/PHASE1_SUMMARY.md`
   - `progress_docs/TEST_FIX_SUMMARY.md`
   - `progress_docs/TEST_IMPLEMENTATION_SUMMARY.md`
2. Search the repo for any string match of `run_tests.gd`, `PHASE1_SUMMARY`, `TEST_FIX_SUMMARY`, or `TEST_IMPLEMENTATION_SUMMARY` and remove links to the deleted files.
3. Update `AGENTS.md`'s "Repository Structure" section so it no longer lists those files (you'll redo that tree more thoroughly in item 4).

**Acceptance criteria.**

- The five files above are deleted.
- No remaining references to them in the codebase.
- `make test` still passes.

---

### 3. Update `README.md` to match the current state of the project

**Problem.** `README.md` has drifted significantly from reality:

- Header still says **"Phase 2 Complete ✓"** while `AGENTS.md` and `TODO.md` mark Phase 2.5 complete.
- The "Project Structure" section lists 5 scripts but omits `scripts/audio_manager.gd` (which is the autoload powering all in-game audio).
- The deployment-guide link `[Deployment Guide](DEPLOYMENT.md)` is broken; the file actually lives at `progress_docs/DEPLOYMENT.md`.
- Phase 3 still lists "Create `MusicLayers` node with 4 `AudioStreamPlayer` children (Drums, Bass, Melody, Harmony)" as a TODO. After item 1 above, that node is gone, and the design has moved to 3 stems anyway.
- It mentions `/assets/sprites/` and `/assets/audio/` placeholder folders that don't exist; the real audio assets live in `BGM/`.

**How to fix.** Edit `README.md`:

1. Change the status header from `## Current Status: Phase 2 Complete ✓` to `## Current Status: Phase 2.5 Complete ✓`.
2. Under "Project Structure", change the scripts list to include all six files in `scripts/`:
   - `audio_manager.gd` — Autoload; dynamic music layering and SFX playback
   - `critter.gd`
   - `game_manager.gd`
   - `grid.gd`
   - `match_controller.gd`
   - `stage_display.gd`
3. Replace the placeholder `/assets/sprites/` and `/assets/audio/` lines with a real `/BGM/` entry (background music + SFX `.wav`/`.mp3` files).
4. Fix the deployment link: `[Deployment Guide](progress_docs/DEPLOYMENT.md)`.
5. In the "Phase 3" section, remove the "Create `MusicLayers` node…" line. The remaining Phase 3 items (deadlock detection, shuffle, BPM scaling) are still accurate.
6. Skim the rest of the README for any other claims that contradict `AGENTS.md` (the source of truth) and update them.

**Acceptance criteria.**

- Status, scripts list, and deployment link are correct.
- No mention of `MusicLayers` as a Phase 3 task.
- Clicking links in the README from a fresh checkout works.

---

### 4. Fix `AGENTS.md` repository tree and missing CI workflow

**Problem.** `AGENTS.md` "Repository Structure" hardcodes the GitHub Actions runner path as if it were the local repo root:

```43:84:AGENTS.md
## Repository Structure

```
/home/runner/work/kkjam/kkjam/
├── .git/                    # Git repository data
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Pages deployment automation
...
```
```

That path only exists on GitHub's CI runners. It also lists only `deploy.yml` under `.github/workflows/`, but `tests.yml` exists and is what runs `make test` on every push/PR.

**How to fix.**

1. Replace `/home/runner/work/kkjam/kkjam/` with a relative tree, e.g. start with `kkjam/` or just omit the root line.
2. Under `.github/workflows/`, list both files:
   ```
   ├── .github/
   │   └── workflows/
   │       ├── deploy.yml    # GitHub Pages deployment automation
   │       └── tests.yml     # Runs `make test` on push and PR
   ```
3. Verify the listed files actually exist by running `ls scripts/ scenes/ test/unit/ test/integration/ progress_docs/` and matching against the doc.
4. Update the "Phase 2.5" status note as needed if any of the other items (e.g. removing `run_tests.gd` from item 2) changed the file inventory.

**Acceptance criteria.**

- No reference to `/home/runner/...` anywhere in `AGENTS.md`.
- Both workflow files are listed.
- The repository tree matches an `ls` of the actual project.

---

### 5. Remove duplicate audio assets and clean `dist/` in `make clean`

**Problem (duplicate audio).** `BGM/` ships both `.mp3` and `.wav` versions of all four SFX:

```
BGM/sfx_match_small.mp3   sfx_match_small.wav
BGM/sfx_match_medium.mp3  sfx_match_medium.wav
BGM/sfx_match_large.mp3   sfx_match_large.wav
BGM/sfx_combo_bass.mp3    sfx_combo_bass.wav
```

`scripts/audio_manager.gd` only loads the `.wav` versions:

```34:39:scripts/audio_manager.gd
const SFX_PATHS = {
	"match_small": "res://BGM/sfx_match_small.wav",
	"match_medium": "res://BGM/sfx_match_medium.wav",
	"match_large": "res://BGM/sfx_match_large.wav",
	"combo_bass": "res://BGM/sfx_combo_bass.wav"
}
```

The `.mp3` versions are unused bloat in the repo.

**Problem (`dist/`).** The `Makefile`'s `clean` target removes `build/` but not `dist/`:

```76:83:Makefile
.PHONY: clean
clean:
	@echo "Cleaning temporary files..."
	@find . -name ".DS_Store" -delete
	@rm -rf .godot/mono_crash.*.json
	@rm -rf build/
	@echo "Clean complete."
	@echo "Clean complete."
```

`dist/` already contains a stale web export from a previous build flow; `.gitignore` excludes it from git but it persists locally. There is also a duplicated `@echo "Clean complete."` line.

**How to fix.**

1. Delete the four unused MP3 SFX files in `BGM/`:
   - `sfx_match_small.mp3`
   - `sfx_match_medium.mp3`
   - `sfx_match_large.mp3`
   - `sfx_combo_bass.mp3`
   - Also remove their `.import` siblings if present (e.g. `sfx_match_small.mp3.import`).
2. Run `make run` to confirm SFX still play (only the `.wav` versions are used by the autoload).
3. Edit the `Makefile` `clean` target to also remove `dist/` and to drop the duplicated `@echo`:
   ```makefile
   .PHONY: clean
   clean:
   	@echo "Cleaning temporary files..."
   	@find . -name ".DS_Store" -delete
   	@rm -rf .godot/mono_crash.*.json
   	@rm -rf build/
   	@rm -rf dist/
   	@echo "Clean complete."
   ```
4. Run `make clean` and confirm `dist/` and `build/` are gone.

**Acceptance criteria.**

- No unreferenced `.mp3` SFX files remain in `BGM/`.
- `make clean` removes `dist/`.
- `make run` still plays match SFX.

---

### 6. Fix stale comments and assertions in tests

**Problem (integration test).** `test/integration/test_game_flow.gd` claims "all 4 types" but the system has 3:

```68:84:test/integration/test_game_flow.gd
func test_grid_contains_all_critter_types():
	...
	# We should have all 4 types (high probability with 64 cells and 4 types)
	assert_true(types_found.size() >= 3, "Should have at least 3 different critter types")
```

The threshold (`>= 3`) is intentional (you want all three to appear with high probability), but the comment is wrong and the assertion message is misleading.

**Problem (match controller tests).** `test/unit/test_match_controller.gd` still has "bunnies"/"cats" comments from before the rename to MELODY/DRUMS/PAD:

```57:80:test/unit/test_match_controller.gd
	# Create a horizontal match of 3 bunnies at level 1
	mock_grid.create_critter(Critter.CritterType.DRUMS, ...)
	...
	# Create a vertical match of 3 cats at level 1
	mock_grid.create_critter(Critter.CritterType.MELODY, ...)
```

**How to fix.**

1. In `test_game_flow.gd::test_grid_contains_all_critter_types`:
   - Update the comment to reflect 3 types, e.g. `# We should have all 3 types (high probability with 64 cells and 3 types)`.
   - Update the assertion message to `"Should have all 3 critter types"`.
   - Optionally tighten the assertion to `assert_eq(types_found.size(), 3, ...)` since with 64 cells and 3 types, all 3 should appear with overwhelming probability.
2. In `test_match_controller.gd`:
   - Replace any "bunny"/"bunnies"/"cat"/"cats"/"frog"/"bird" comments with the actual type names being created (`DRUMS`, `MELODY`, `PAD`).
3. Run `make test-unit` and `make test-int` to confirm everything still passes.

**Acceptance criteria.**

- No `bunny`/`bunnies`/`cat`/`cats`/`frog`/`bird` comments remain in `test/`.
- No reference to "4 types" remains in `test/`.
- All tests pass.

---

## Architecturally Important (The Real Refactors)

These items change behavior or structure. Each one should be its own PR with focused tests.

### 7. De-duplicate critters across matches in `MatchController.resolve_matches`

**Problem.** `find_matches()` returns horizontal and vertical matches independently, so an L- or T-shape produces two matches that share a critter. The existing edge-case test `test_l_shaped_matches_dont_count` asserts exactly this. In `resolve_matches`, each match is processed independently:

```93:142:scripts/match_controller.gd
func resolve_matches(matches: Array, swap_target: Vector2 = Vector2(-1, -1)):
	for match in matches:
		var critters = match["critters"]
		...
		# Remove all matched critters from grid
		for critter in critters:
			grid.remove_critter(critter.grid_x, critter.grid_y)

		# Create a new merged critter at the merge location
		var next_level = critter_level + 1

		if next_level <= Critter.CritterLevel.LEVEL_3:
			var new_critter = grid.spawn_critter(merge_x, merge_y, next_level)
			...
		var points = 10 * (critter_level + 1) * critters.size()
		grid.get_node("../GameManager").add_score(points)
		...
```

When two matches share a cell:

- The shared critter is "removed" twice (the second call hits a `null` cell — silent no-op, but conceptually wrong).
- Both matches `spawn_critter` a new merged critter, possibly at colliding positions. `grid.spawn_critter` overwrites `grid_data[merge_x][merge_y]` with the new critter, leaking the previous merged critter as an orphan node still attached to `CritterContainer` but no longer in `grid_data`. That orphan stays on screen and never participates in matches.
- Score is double-counted for the shared cell, and SFX fires twice.

**How to fix.**

1. Before processing, build a set of unique critters across all matches:
   ```gdscript
   var seen_critters: Dictionary = {}
   var unique_matches: Array = []
   for match in matches:
       # Decide on a single representative match per connected component:
       var overlap_with_existing = false
       for critter in match["critters"]:
           if seen_critters.has(critter):
               overlap_with_existing = true
               break
       if overlap_with_existing:
           continue # already covered by a prior match
       for critter in match["critters"]:
           seen_critters[critter] = true
       unique_matches.append(match)
   ```
   Note: this minimal version drops one of the overlapping matches. A nicer version merges them into a single "connected component" with one merge location.
2. (Better) Treat overlapping matches as one connected component:
   - Use a small union-find over critter references.
   - For each component, pick a single merge location (`swap_target` if it's part of the component, otherwise the centroid).
   - Score = `10 * (level + 1) * total_critter_count_in_component`.
   - Fire one SFX per component.
3. Add unit tests covering:
   - L-shape merge: one merged critter spawned, board has no orphan nodes.
   - T-shape merge: same.
   - Plus-shape (vertical+horizontal sharing center cell).
   You can verify "no orphans" by counting `grid.get_node("CritterContainer").get_child_count()` against the number of non-null cells in `grid_data`.

**Acceptance criteria.**

- For any L/T/plus shape, the number of new merged critters equals the number of distinct connected components.
- `CritterContainer.get_child_count()` matches the count of non-null `grid_data` cells after processing.
- Score and SFX fire once per component, not once per match line.
- All existing tests still pass and the new tests cover the overlap cases.

---

### 8. Remove `get_node("../X")` coupling between scripts

**Problem.** Cross-component communication uses fragile string-based scene paths:

```209:228:scripts/grid.gd
func handle_level_3_created(critter: Critter):
	...
	var game_manager = get_node_or_null("../GameManager")
	if game_manager:
		game_manager.collect_critter(critter.critter_type, critter.critter_level)

	# Get target position from StageDisplay
	var stage_bg = get_node_or_null("../StageBackground")
```

```141:142:scripts/match_controller.gd
		grid.get_node("../GameManager").add_score(points)
```

```18:25:scripts/game_manager.gd
func _ready():
	if has_node("../Grid"):
		grid = get_node("../Grid")
	if has_node("../UI"):
		ui = get_node("../UI")
	if has_node("../StageBackground"):
		stage_display = get_node("../StageBackground")
```

This makes scripts brittle (renaming a node breaks the game silently) and untestable (every unit test currently builds a `MockGrid` just to keep `get_node("../GameManager")` resolvable). It also contradicts `AGENTS.md`'s own guidance: "Prefer signals over direct function calls for decoupling."

**How to fix.**

Refactor in three small steps. Run `make test` after each step.

1. **Inject explicit references via `@export`.** In `Grid`, replace `get_node_or_null("../GameManager")` and `get_node_or_null("../StageBackground")` with exported NodePaths set on the scene:
   ```gdscript
   @export var game_manager_path: NodePath
   @export var stage_display_path: NodePath
   @onready var game_manager: GameManager = get_node(game_manager_path)
   @onready var stage_display: Node = get_node(stage_display_path)
   ```
   Wire the paths in `main.tscn` via the editor (point them to `../GameManager` and `../StageBackground` once).
2. **Replace `add_score` direct call with a signal.** In `Grid`:
   ```gdscript
   signal score_earned(points: int)
   ```
   In `MatchController.resolve_matches`, replace `grid.get_node("../GameManager").add_score(points)` with `grid.emit_signal("score_earned", points)`. In `GameManager._ready()`, connect `grid.score_earned.connect(add_score)`. (Or do the equivalent in `main.tscn` via the editor.)
3. **Replace direct calls in `Grid.handle_level_3_created`** with a signal `level_3_created(critter)` that `GameManager` and `StageDisplay` connect to. Each one does its own work in its own handler; `Grid` no longer reaches up.
4. Remove the now-unused `has_node("../X")` / `get_node("../X")` lookups from `GameManager._ready()`. Replace UI tracking the same way.
5. Update unit tests: drop the `MockGrid::_ready` trick that adds a `GameManager` sibling to the parent — instead, pass a real reference into the controller.

**Acceptance criteria.**

- No `get_node("../X")` or `has_node("../X")` calls remain in `scripts/`.
- Renaming the `GameManager` or `StageBackground` node in the editor doesn't break the game (paths are routed through `@export`s or signals).
- Unit tests no longer need `MockGrid::_ready` to fake a parent hierarchy.
- All tests pass.

---

### 9. Make stage merges async and fix overlap in `_get_next_position_for_type`

**Problem (overlap).** `stage_display.gd::_get_next_position_for_type` overlaps after 3 critters of the same type:

```62:68:scripts/stage_display.gd
func _get_next_position_for_type(type: Critter.CritterType) -> Vector2:
	var base_pos = stage_base_positions[type]
	var count = stage_critters[type].size()

	# Arrange critters horizontally around the base position
	var offset_x = (count - 1) * CRITTER_SPACING / 2.0
	return base_pos + Vector2(-offset_x + (count % 3) * CRITTER_SPACING, 0)
```

The `count % 3` term means the 4th, 7th, and 10th critters of the same type all spawn at the same X offset as the 1st. Per `TODO.md`, you can have up to 9 Level-3 critters of one type before any Level-4 merge, so this is reachable in normal play. `_reorganize_type` later corrects the layout, but the fly-in landing position used by `Grid.handle_level_3_created` (via `get_global_stage_position`) is wrong, so animations land on top of an existing critter.

**Problem (async).** `_check_stage_merges` runs a `while` loop that calls `_perform_stage_merge`, which calls `_add_critter_to_stage`, which contains a `await get_tree().create_timer(0.6).timeout`. None of the call sites `await`. As a result, chains of `3×L3 → L4 → 3×L4 → L5` resolve instantly state-wise but with overlapping animations and many invisible-but-counted critters in `stage_critters[type]`. Currently saved by `is_instance_valid` guards, but any timing change desyncs.

**How to fix.**

1. Replace the position formula with a deterministic non-modulo layout. Example (no overlap up to ~7 critters per type at `CRITTER_SPACING = 30`):
   ```gdscript
   func _get_next_position_for_type(type: Critter.CritterType) -> Vector2:
       var base_pos = stage_base_positions[type]
       var count = stage_critters[type].size()  # before append
       # Spread critters around base_pos centered, no wraparound
       var offset_x = (count - (count - 1) / 2.0) * CRITTER_SPACING
       # or, simpler: just append to the right of the last one
       return base_pos + Vector2(count * CRITTER_SPACING, 0)
   ```
   Then let `_reorganize_type` re-center them after the spawn animation finishes. The exact formula is up to you; the requirement is no two critters share a position before reorganize runs.
2. Make the merge chain awaitable:
   ```gdscript
   func _check_stage_merges(type: Critter.CritterType) -> void:
       var merged := true
       while merged:
           merged = false
           ...
           for level in level_groups:
               var group = level_groups[level]
               if group.size() >= 3:
                   var next_level = level + 1
                   if next_level <= Critter.CritterLevel.LEVEL_5:
                       await _perform_stage_merge(type, group.slice(0, 3), next_level)
                       merged = true
                       break
   ```
   And in `_perform_stage_merge`, `await _add_critter_to_stage(type, new_level, false)` so the next iteration sees the new critter as fully spawned and visible.
3. Update `_on_critter_collected` to `await _add_critter_to_stage(...)` if you want the chain to start only after the fly-in animation completes.
4. Add tests:
   - Stage merge: queue 3 Level-3 critters of the same type, await one frame plus the animation duration, assert that one Level-4 critter remains.
   - Chain merge: queue 9 Level-3 critters, assert that one Level-5 critter remains.
   - Overlap: queue 4 Level-3 critters of the same type without merging conditions met (e.g. mix levels), assert that all positions are distinct.

**Acceptance criteria.**

- No two critters share a stage position immediately after spawn (before reorganize).
- Chain merges complete in clear, sequenced animations.
- New tests pass.

---

### 10. Make the cascade-depth fail-safe restore the board to a valid state

**Problem.**

```179:206:scripts/grid.gd
func refill_board():
	cascade_depth += 1
	if cascade_depth > MAX_CASCADE_DEPTH:
		push_warning("Max cascade depth reached, breaking cascade loop.")
		processing_matches = false
		return

	# Apply gravity - move critters down
	apply_gravity()
	...
```

If you ever hit the cap, you bail out with `processing_matches = false` while pending matches almost certainly still exist on the board. The player can then interact with an unresolved board, which can compound the problem (more matches stack up, more cascades trigger).

**How to fix.**

Pick one of these two strategies:

1. **One-shot finalizer.** Before returning, do one more `find_matches`/`resolve` pass without recursion to clear the obvious matches, then unlock input:
   ```gdscript
   if cascade_depth > MAX_CASCADE_DEPTH:
       push_warning("Max cascade depth reached. Finalizing board.")
       var leftover = match_controller.find_matches()
       if leftover.size() > 0:
           match_controller.resolve_matches(leftover)
       processing_matches = false
       return
   ```
2. **Emergency reset.** Treat the deadlock as catastrophic and regenerate:
   ```gdscript
   if cascade_depth > MAX_CASCADE_DEPTH:
       push_warning("Max cascade depth reached. Resetting board.")
       reset_board()
       return
   ```
   `reset_board` already clears `processing_matches` after regeneration.

Either way, log the event with `push_warning` and consider a `print` so QA can spot it in the console.

**How to test.** Force the deadlock in a test by lowering `MAX_CASCADE_DEPTH` to a small number temporarily, or by injecting matches in a controlled test scene. Assert that `processing_matches == false` and that no matches are present after the safe-return path.

**Acceptance criteria.**

- After hitting the cascade cap, the board has no pending matches.
- `processing_matches` is `false`.
- The game accepts input and remains playable.

---

### 11. Build a real concert sequence for `GameManager.complete_album`

**Problem.** The "win condition" / loop reset is currently a stub:

```61:75:scripts/game_manager.gd
func trigger_concert():
	print("ULTIMATE CONCERT TRIGGERED!")
	emit_signal("concert_triggered")
	complete_album()

func complete_album():
	albums_completed += 1
	current_bpm += 10  # Increase tempo
	print("Album completed! Total albums: ", albums_completed)

	# Reset for next tour stop
	reset_stage()
	# In a real implementation, we'd wait for the concert animation to finish
	if grid:
		grid.reset_board()
```

It's a print plus a counter plus an immediate reset. There is no animation, no input lock, no audio cue, and the comment explicitly admits "in a real implementation, we'd wait for the concert animation to finish". `AGENTS.md` and `TODO.md` claim Phase 2.5 is complete, so this is a feature gap, not just polish.

**How to fix.**

1. Add a concert duration constant, e.g. `const CONCERT_DURATION_SEC: float = 2.5`.
2. Lock input. Set `grid.processing_matches = true` (or expose `Grid.set_input_locked(bool)`) at the start of the sequence so the player can't swap during the animation. Optionally show a fullscreen overlay (the existing `InputBlocker` Control can be repurposed; see item 12 below — but for this item, just block input via `processing_matches`).
3. Play a celebratory cue. Either:
   - Call a new `AudioManager.play_concert_jingle()` that triggers `full_track_almost_done.mp3` (already loaded) or a dedicated stinger.
   - Emit `concert_triggered` and let `audio_manager.gd` handle the cue.
4. Animate. Add a simple visible signal (e.g. flash the `Background` ColorRect or scale the title) for `CONCERT_DURATION_SEC` seconds.
5. Make the reset async:
   ```gdscript
   func complete_album() -> void:
       albums_completed += 1
       current_bpm += 10
       _start_concert_animation()
       await get_tree().create_timer(CONCERT_DURATION_SEC).timeout
       reset_stage()
       if grid:
           grid.reset_board()
   ```
6. Update the concert audio: fade out music, play the stinger, fade in next BGM as `current_bpm` changes.
7. Add an integration test that triggers the concert and asserts:
   - `albums_completed` increments by 1.
   - `current_bpm` increases by 10.
   - `stage_critters` is empty after the timer.
   - `grid_data` is fully populated with Level-1 critters after the timer.
   - Input is unlocked at the end.

**Acceptance criteria.**

- Triggering a concert produces a visible animation and audio cue lasting at least 1 second.
- Input is locked during the animation and unlocked after the reset.
- The new test passes.

---

### 12. Add tests for stage merging, concert trigger, and music-layer activation; cover Levels 4 and 5 everywhere

**Problem.** Tests don't cover the headline Phase 2.5 features:

- No tests for stage merging (3×L3 → L4, 3×L4 → L5).
- No tests for the concert trigger condition (one Level 5 of each type on stage).
- No tests for music-layer activation per stage state.
- Existing tests only iterate `LEVEL_1..LEVEL_3`, e.g.:

```29:36:test/unit/test_critter.gd
func test_critter_levels():
	...
	for level in [Critter.CritterLevel.LEVEL_1, Critter.CritterLevel.LEVEL_2, Critter.CritterLevel.LEVEL_3]:
		critter.initialize(Critter.CritterType.DRUMS, level, 0, 0)
		assert_eq(critter.critter_level, level, "Critter level should be set correctly")
```

```44:58:test/unit/test_edge_cases.gd
func test_critter_size_increases_with_level():
	var sizes = []
	for level in [Critter.CritterLevel.LEVEL_1, Critter.CritterLevel.LEVEL_2, Critter.CritterLevel.LEVEL_3]:
		...
```

**How to fix.**

1. **Extend Level-4/5 coverage in existing tests.** Update the loops in:
   - `test/unit/test_critter.gd::test_critter_levels`
   - `test/unit/test_edge_cases.gd::test_all_critter_type_combinations`
   - `test/unit/test_edge_cases.gd::test_critter_size_increases_with_level`
   to iterate `LEVEL_1..LEVEL_5`. Adjust assertions where size/visual differs at higher levels.
2. **Add stage-merge tests** to a new `test/unit/test_stage_display.gd`:
   - Add 3 Level-3 critters of one type to the stage, await the timer, assert one Level-4 remains.
   - Add 9 Level-3 critters of one type, assert one Level-5 remains after the cascade.
   - Add 3 Level-3 critters of two different types, assert no merge happens across types.
3. **Add a concert-trigger test** to a new `test/integration/test_concert.gd`:
   - Spawn one Level-5 critter of each type on the stage (call `_add_critter_to_stage` directly).
   - Call `game_manager.check_concert_condition()`.
   - Assert `concert_triggered` signal is emitted, `albums_completed` increments, `stage_critters` is cleared, and `grid_data` is repopulated. (Use the async behavior added in item 11.)
4. **Add an audio-layer test** to `test/unit/test_audio_manager.gd`:
   - Manually populate `audio_manager.layer_players` with mock players.
   - Call `update_music_intensity(level_for_melody, level_for_drums, level_for_pad)` with each combination of levels 0..3.
   - Assert which layers fade in (target `0.0 dB`) versus fade out (`-80.0 dB`). Use a short `await wait_seconds(0.1)` to let the tween run a bit, then check the direction (`>` or `<` the previous value), as the existing `test_update_music_intensity` already does.
5. After all new tests are added, update `AGENTS.md`'s "**X automated tests (Y unit, Z integration)**" line to the new counts. Search for `50 automated tests`, `42 unit`, and `8 integration` in `AGENTS.md` and `progress_docs/` and update them.

**Acceptance criteria.**

- New tests cover stage merging at Level 4 and Level 5.
- New tests cover the concert trigger condition end-to-end.
- New tests cover music-layer activation logic.
- Existing tests run on Levels 1–5 instead of 1–3.
- `make test` passes.
- `AGENTS.md` test counts match the new totals.
