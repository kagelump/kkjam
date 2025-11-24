# Audio Compression Guide for Web Export

Since this game will be served on the web, minimizing asset size is crucial for fast load times. Audio files are often the largest assets.

## Recommended Formats

### Background Music (BGM)
*   **Format:** **Ogg Vorbis** (`.ogg`)
*   **Why:** Excellent compression-to-quality ratio, native support in Godot and browsers, and supports seamless looping.
*   **Target Bitrate:** 96 kbps - 128 kbps.

### Sound Effects (SFX)
*   **Format:** **WAV** (with IMA-ADPCM compression) or **MP3**.
*   **Why:**
    *   **WAV (IMA-ADPCM):** Very low CPU cost to decode, instant playback. Best for short, frequent sounds (like matching).
    *   **MP3:** Good for longer, non-looping sounds if file size is a concern, but can have tiny gaps at the start (bad for looping).

## How to Configure in Godot

You don't need to convert files externally! Godot handles this on import.

### 1. Configure BGM Files
Select all your music layer files (`c1_layer1.wav`, etc.) in the Godot FileSystem dock.

1.  Go to the **Import** tab (top left, next to Scene).
2.  Set **Importer** to `OggVorbis`.
3.  **Loop:** Check `Enable`.
4.  Click **Reimport**.

*Note: This will convert them to `.ogg` internally when exporting.*

### 2. Configure SFX Files
Select all your SFX files (`sfx_match_small.wav`, etc.).

1.  Go to the **Import** tab.
2.  Set **Importer** to `WAV`.
3.  **Compress Mode:**
    *   Select `IMA-ADPCM` for significant size reduction (4:1) with minimal quality loss.
    *   Or `Disabled` (PCM) for pristine quality but large size.
4.  **Loop:** Check `Disable` (unless it's a looping effect).
5.  Click **Reimport**.

## Estimated Savings
*   **Original WAVs:** ~10MB per minute of stereo audio.
*   **Ogg Vorbis (128kbps):** ~1MB per minute.
*   **Savings:** ~90% reduction in file size.
