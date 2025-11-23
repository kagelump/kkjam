extends Node
## Audio Manager
##
## Manages music layers, sound effects, and audio mixing.
## Coordinates critter audio loops to create dynamic music composition.

# Audio buses
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

# Active audio layers
var active_loops: Dictionary = {}  # layer_name -> AudioStreamPlayer

# Music configuration
var base_bpm: int = 120
var measures_per_loop: int = 4

func _ready():
	print("Audio Manager initialized")
	_setup_audio_buses()

func _setup_audio_buses():
	"""Set up audio bus routing"""
	# This will use the default_bus_layout.tres
	# Additional runtime configuration can be added here
	pass

func add_music_layer(layer_name: String, audio_stream: AudioStream):
	"""Add a new music layer to the composition"""
	if layer_name in active_loops:
		print("Layer already active: ", layer_name)
		return
	
	var player = AudioStreamPlayer.new()
	player.stream = audio_stream
	player.bus = MUSIC_BUS
	add_child(player)
	
	# Sync to beat grid
	player.play()
	
	active_loops[layer_name] = player
	print("Added music layer: ", layer_name)

func remove_music_layer(layer_name: String):
	"""Remove a music layer from the composition"""
	if layer_name not in active_loops:
		return
	
	var player = active_loops[layer_name]
	
	# Fade out before removing
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80, 0.5)
	await tween.finished
	
	player.stop()
	player.queue_free()
	active_loops.erase(layer_name)
	print("Removed music layer: ", layer_name)

func evolve_layer(old_layer_name: String, new_layer_name: String, new_stream: AudioStream):
	"""Evolve a music layer to a new version"""
	if old_layer_name in active_loops:
		await remove_music_layer(old_layer_name)
	add_music_layer(new_layer_name, new_stream)

func play_sfx(sfx_stream: AudioStream):
	"""Play a one-shot sound effect"""
	var player = AudioStreamPlayer.new()
	player.stream = sfx_stream
	player.bus = SFX_BUS
	add_child(player)
	player.play()
	
	# Clean up when finished
	await player.finished
	player.queue_free()

func set_master_volume(volume_db: float):
	"""Set master volume"""
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func set_music_volume(volume_db: float):
	"""Set music volume"""
	var bus_idx = AudioServer.get_bus_index(MUSIC_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, volume_db)

func set_sfx_volume(volume_db: float):
	"""Set SFX volume"""
	var bus_idx = AudioServer.get_bus_index(SFX_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, volume_db)

func get_active_layer_count() -> int:
	"""Get the number of active music layers"""
	return active_loops.size()

func clear_all_layers():
	"""Remove all active music layers"""
	var layer_names = active_loops.keys().duplicate()
	for layer_name in layer_names:
		await remove_music_layer(layer_name)
