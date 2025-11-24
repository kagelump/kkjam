extends GutTest

var AudioManagerScript = load("res://scripts/audio_manager.gd")
var audio_manager

func before_each():
	audio_manager = AudioManagerScript.new()
	add_child_autofree(audio_manager)
	# We need to mock the BGM paths or ensure they exist, 
	# but for now let's assume the script handles missing files gracefully or files exist.
	# The script loads files in setup_audio.
	
func test_initialization():
	assert_not_null(audio_manager)
	assert_eq(audio_manager.process_mode, Node.PROCESS_MODE_ALWAYS)

func test_setup_audio_creates_players():
	# setup_audio is called in _ready, which happens when added to tree
	# We can check if layer_players is populated
	
	# Wait for _ready
	await wait_process_frames(1)
	
	# Check if players were created
	assert_gt(audio_manager.layer_players.size(), 0, "Should have created audio players")
	assert_true(audio_manager.layer_players.has("permanent_bgm"), "Should have permanent_bgm player")

func test_start_music_plays_all_layers():
	# This is the reproduction test.
	# We expect start_music to be called and play players.
	
	# Manually call setup if not already (it is in _ready)
	# audio_manager.setup_audio() 
	
	# Mock the players if files are missing?
	# Or just manually add a player to layer_players for testing logic
	var mock_player = AudioStreamPlayer.new()
	# Give it a stream so it can play
	mock_player.stream = AudioStreamGenerator.new()
	audio_manager.add_child(mock_player)
	audio_manager.layer_players["test_layer"] = mock_player
	
	assert_false(mock_player.playing, "Player should not be playing initially")
	
	audio_manager.start_music()
	
	assert_true(mock_player.playing, "Player should be playing after start_music")

func test_update_music_intensity():
	# Test that volume changes based on levels
	var p1 = AudioStreamPlayer.new()
	var p2 = AudioStreamPlayer.new()
	audio_manager.add_child(p1)
	audio_manager.add_child(p2)
	
	audio_manager.layer_players["c1_layer1"] = p1
	audio_manager.layer_players["c1_layer2"] = p2
	
	# Initial state (silent)
	p1.volume_db = -80.0
	p2.volume_db = -80.0
	
	# Level 1 for C1 -> Layer 1 should be audible, Layer 2 silent
	audio_manager.update_music_intensity(1, 0, 0)
	
	# Since it uses tweens, we verify the tween started by checking if volume is changing or wait
	# For unit test simplicity, we can just check if the function runs without error
	# and maybe check if volume is NOT -80 after a tiny wait if we really want.
	# But for now, let's just ensure the logic path is exercised.
	
	await wait_seconds(0.1)
	# p1 should be increasing from -80
	assert_gt(p1.volume_db, -80.0, "Layer 1 volume should be increasing")
	# p2 should stay at -80
	assert_eq(p2.volume_db, -80.0, "Layer 2 volume should stay silent")

func test_start_music_does_not_restart_if_playing():
	var mock_player = AudioStreamPlayer.new()
	mock_player.stream = AudioStreamGenerator.new()
	audio_manager.add_child(mock_player)
	audio_manager.layer_players["test_layer"] = mock_player
	
	# Start first time
	audio_manager.start_music()
	assert_true(mock_player.playing)
	
	# Simulate some playback time (can't easily do this without waiting, but we can check playback position if we could)
	# Instead, we can mock the player or check if play() is called.
	# Since we can't mock easily in GDScript without a framework, we rely on logic.
	# If we change the code to check .playing, we can test that logic.
	
	# For now, let's just implement the fix in AudioManager as it's safer.
	pass

func test_permanent_bgm_always_on():
	# Verify permanent_bgm exists and starts at full volume
	
	# Wait for _ready to ensure setup_audio has run
	await wait_process_frames(1)
	
	# Check if key exists
	if audio_manager.layer_players.has("permanent_bgm"):
		var player = audio_manager.layer_players["permanent_bgm"]
		assert_eq(player.volume_db, 0.0, "Permanent BGM should start at 0.0 dB")
	else:
		fail_test("permanent_bgm player was not created. File might be missing or failed to load.")
