extends Node

# Audio Manager
# Handles dynamic BGM mixing and SFX playback

# BGM Layers
var layers = {}
var layer_players = {}

# SFX
var sfx_players = []
const MAX_SFX_PLAYERS = 10

# Configuration
const FADE_TIME = 1.0 # Seconds
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

# Asset Paths
const BGM_PATHS = {
	"c1_layer1": "res://BGM/c1_layer1.wav",
	"c1_layer2": "res://BGM/c1_layer2.wav",
	"c1_layer3": "res://BGM/c1_layer3.wav",
	"c2_layer1": "res://BGM/c2_layer1.wav",
	"c2_layer2": "res://BGM/c2_layer2.wav",
	"c2_layer3": "res://BGM/c2_layer3.wav",
	"c3_layer1": "res://BGM/c3_layer1.wav",
	"c3_layer2": "res://BGM/c3_layer2.wav",
	"c3_layer3": "res://BGM/c3_layer3.wav",
	"pregame": "res://BGM/c1_pregame.wav"
}

const SFX_PATHS = {
	"match_small": "res://BGM/sfx_match_small.wav",
	"match_medium": "res://BGM/sfx_match_medium.wav",
	"match_large": "res://BGM/sfx_match_large.wav",
	"combo_bass": "res://BGM/sfx_combo_bass.wav"
}

var sfx_streams = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_audio()

func setup_audio():
	# Setup BGM Players
	for key in BGM_PATHS:
		var stream = load(BGM_PATHS[key])
		if stream:
			if stream is AudioStreamWAV:
				stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			elif stream is AudioStreamOggVorbis:
				stream.loop = true
				
			var player = AudioStreamPlayer.new()
			player.stream = stream
			player.bus = MUSIC_BUS
			player.volume_db = -80.0 # Start silent
			add_child(player)
			layer_players[key] = player
	
	# Setup SFX Pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		sfx_players.append(player)
		
	# Load SFX Streams
	for key in SFX_PATHS:
		sfx_streams[key] = load(SFX_PATHS[key])
		if sfx_streams[key]:
			if sfx_streams[key] is AudioStreamWAV:
				sfx_streams[key].loop_mode = AudioStreamWAV.LOOP_DISABLED
			elif sfx_streams[key] is AudioStreamOggVorbis:
				sfx_streams[key].loop = false

func start_music():
	for key in layer_players:
		layer_players[key].play()

func update_music_intensity(c1_level: int, c2_level: int, c3_level: int):
	# Logic to fade in/out layers based on levels
	
	# Critter 1: Melody
	_update_layer_volume("c1_layer1", c1_level >= 1)
	_update_layer_volume("c1_layer2", c1_level >= 2)
	_update_layer_volume("c1_layer3", c1_level >= 3)
	
	# Critter 2: Drums
	_update_layer_volume("c2_layer1", c2_level >= 1)
	_update_layer_volume("c2_layer2", c2_level >= 2)
	_update_layer_volume("c2_layer3", c2_level >= 3)
	
	# Critter 3: Pad
	_update_layer_volume("c3_layer1", c3_level >= 1)
	_update_layer_volume("c3_layer2", c3_level >= 2)
	_update_layer_volume("c3_layer3", c3_level >= 3)

func _update_layer_volume(layer_name: String, active: bool):
	if not layer_players.has(layer_name):
		return
		
	var player = layer_players[layer_name]
	var target_vol = 0.0 if active else -80.0
	
	# If we want to crossfade, we can use a tween
	var tween = create_tween()
	tween.tween_property(player, "volume_db", target_vol, FADE_TIME)

func play_sfx(sfx_name: String):
	if not sfx_streams.has(sfx_name):
		return
		
	# Find free player
	for player in sfx_players:
		if not player.playing:
			player.stream = sfx_streams[sfx_name]
			player.play()
			return
			
	# If all busy, use the first one (cut off)
	sfx_players[0].stream = sfx_streams[sfx_name]
	sfx_players[0].play()
