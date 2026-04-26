# KKJam — UI / UX bug tracker

This file documents **UI and copy issues** found during browser play-testing (web export) and from scene layout review. It is the source of truth for what’s wrong; **fix plans and implementation** can be done in a follow-up (e.g. **Opus 4.7** or another pass) so design decisions stay separate from the bug list.

**Related:** `scenes/main.tscn` (`UI`, `TitleLabel`, `InstructionsLabel`, `ScoreLabel`, `GridBackground`), `scripts/game_manager.gd` (startup `print` / phase messaging).

---

## 1. Score / phase line overlaps the board (high)

**What:** The `ScoreLabel` string **“Phase 1 MVP - Core Match-3”** is positioned at `offset_top` 960–`offset_bottom` 1020, while the grid area runs **y = 400–1120** in scene space. The label **visually sits on top of the bottom rows** of the 8×8 board.

**Why it matters:** Players cannot clearly see tiles in the **bottom two rows**; taps may also feel inconsistent if labels intercept input (Control defaults vary by node).

**Evidence:** Screenshot review during web test; layout in `main.tscn` lines 24–28 (grid) vs 72–80 (`ScoreLabel`).

**Handoff (fix plan request):** Propose 1–2 layout options: move status below the entire grid+padding, or to a non-overlapping top strip; define z-order and `mouse_filter` for any full-width `Control` so the playfield stays readable and clickable. Include export-safe dimensions for **720×1280** portrait.

---

## 2. Stale copy — “Phase 1 MVP” vs game reality (medium)

**What:** On-screen `ScoreLabel` still says **Phase 1 MVP** while the game logs **“KKJam - Phase 2.5 Started”** and the concert / merge messaging describes **Level 5** and the **stage** loop.

**Why it matters:** Inconsistent with `AGENTS.md`, tests, and `game_manager` behavior; confuses new players and play-testers.

**Handoff (fix plan request):** Define the **canonical** one-line for this label (e.g. album count, short phase tag, or remove phase entirely). Wire updates if the line should change during play (connect to `GameManager` or a small UI controller). Align with any score/album already tracked in code.

---

## 3. Instruction text does not match mechanics (medium)

**What:** `InstructionsLabel` says **“Match 3+ of same color & size!”** The actual rules are **same critter type and same level** (not “color” only); early board is **all level 1**, so “size” reads as a broken mechanic.

**Why it matters:** Mismatch with design docs and with merge/stage flow.

**Handoff (fix plan request):** Replace with a short, accurate line (e.g. type + level, merge, stage for L3+). Optional second line for concert goal if it fits. Keep within existing label box or adjust `offset_*` in `main.tscn` if copy grows.

---

## 4. “Size” + uniform “1” on tiles (lower)

**What:** Every starting tile shows **“1”**; instructions mention **“size”**; visually it’s unclear that **level** is the same concept.

**Why it matters:** Low severity if treated as “level 1 at start” but contributes to the instruction mismatch in §3.

**Handoff (fix plan request):** Either tie copy to “level” explicitly or add a minimal UI hint (e.g. only when level &gt; 1) so “size” is not the only term used.

---

## 5. Console vs on-screen messaging split (lower / meta)

**What:** Helpful state is in **console** (`print` / `push_warning`); the **in-game** UI does not echo match resolution, score, or errors.

**Why it matters:** Web players often don’t open DevTools; on-screen feedback is a separate feature set.

**Handoff (fix plan request):** Optional: a minimal **toast** or line under the grid for “Invalid swap” / “Match!” — out of scope for *pure* copy fixes but related to “UI feels broken when silent.”

---

## Outsource / next step — **Opus 4.7 fix plans**

**Goal:** From this file, produce **concrete fix plans** (not necessarily code), including:

1. **Priority order** (must-fix vs nice-to-have).
2. For each bug: **scene changes** vs **new script** vs **string-only** change.
3. **Acceptance tests:** manual (browser) + any GUT or UI test hooks if added.
4. **Risks:** `mouse_filter` on `UI` parent and children, anchor drift on stretch modes.

**Input paths:** `res://scenes/main.tscn`, `res://scripts/game_manager.gd`, `AGENTS.md` (design truth).

**Do not** change match/grid logic in a UI-only pass unless a bug is proven in gameplay code.

---

## Play test snapshot (for regression)

- **Build:** `make web-dev` (or export Web debug to `build/web/` and serve on port 8000).
- **Session:** Select/swap path worked; **invalid** adjacent swap produced console `Swap would not create a match` and expected reject behavior; startup logs matched **Phase 2.5** merge/concert copy.
- **Not exhaustively covered here:** full valid match → merge → cascade in browser (separate test matrix).

Last updated: 2026-04-26 (browser session, Cursor).
