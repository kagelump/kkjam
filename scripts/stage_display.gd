extends Control

@onready var game_manager: GameManager = $"../GameManager"
var critter_scene = preload("res://scenes/critter.tscn")

# Positions for the 3 critter types on stage
# Stage is 720x200. Center Y is 100.
# X positions: 1/6, 3/6, 5/6 of 720
var stage_base_positions = {
	Critter.CritterType.MELODY: Vector2(120, 100),
	Critter.CritterType.DRUMS: Vector2(360, 100),
	Critter.CritterType.PAD: Vector2(600, 100)
}

# Store multiple critters per type: { type: [critter, critter, ...] }
var stage_critters = {
	Critter.CritterType.MELODY: [],
	Critter.CritterType.DRUMS: [],
	Critter.CritterType.PAD: []
}

const CRITTER_SPACING = 30.0  # Horizontal spacing between critters of same type

func _ready():
	if game_manager:
		game_manager.critter_collected.connect(_on_critter_collected)
		game_manager.stage_reset.connect(_on_stage_reset)

func _on_critter_collected(type: Critter.CritterType, level: Critter.CritterLevel):
	_add_critter_to_stage(type, level, true)

func _add_critter_to_stage(type: Critter.CritterType, level: Critter.CritterLevel, check_merges: bool = false):
	var pos = _get_next_position_for_type(type)
	
	var critter = critter_scene.instantiate()
	critter.visible = false # Start hidden, wait for grid animation
	add_child(critter)
	
	# Initialize with the collected level
	critter.initialize(type, level, -1, -1)
	critter.position = pos
	
	# Make it look "active" / "performing"
	critter.scale = Vector2(1.2, 1.2)
	
	stage_critters[type].append(critter)
	
	# Wait for grid animation (0.6s) then show
	await get_tree().create_timer(0.6).timeout
	if is_instance_valid(critter):
		critter.visible = true
		
		# Add a simple bounce animation
		var tween = create_tween().set_loops()
		tween.tween_property(critter, "scale", Vector2(1.3, 1.3), 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(critter, "scale", Vector2(1.2, 1.2), 0.5).set_trans(Tween.TRANS_SINE)
	
	# Check for stage merges (only if requested)
	if check_merges:
		_check_stage_merges(type)

func _get_next_position_for_type(type: Critter.CritterType) -> Vector2:
	var base_pos = stage_base_positions[type]
	var count = stage_critters[type].size()
	
	# Arrange critters horizontally around the base position
	var offset_x = (count - 1) * CRITTER_SPACING / 2.0
	return base_pos + Vector2(-offset_x + (count % 3) * CRITTER_SPACING, 0)

func _check_stage_merges(type: Critter.CritterType):
	var critters = stage_critters[type]
	
	# Group by level
	var level_groups = {}
	for critter in critters:
		if not is_instance_valid(critter):
			continue
		var level = critter.critter_level
		if not level_groups.has(level):
			level_groups[level] = []
		level_groups[level].append(critter)
	
	# Check each level for merges (need 3 of same level)
	for level in level_groups:
		var group = level_groups[level]
		if group.size() >= 3:
			# Can merge! 3 of this level -> 1 of next level
			var next_level = level + 1
			
			# Only merge if not at max level
			if next_level <= Critter.CritterLevel.LEVEL_5:
				_perform_stage_merge(type, group.slice(0, 3), next_level)

func _perform_stage_merge(type: Critter.CritterType, critters_to_merge: Array, new_level: Critter.CritterLevel):
	print("Stage merge! 3x Level ", critters_to_merge[0].critter_level + 1, " -> 1x Level ", new_level + 1)
	
	# Remove the 3 critters from stage
	for critter in critters_to_merge:
		stage_critters[type].erase(critter)
		if is_instance_valid(critter):
			critter.queue_free()
	
	# Add the new merged critter (without checking for more merges to avoid recursion)
	await _add_critter_to_stage(type, new_level, false)
	
	# Reorganize remaining critters
	_reorganize_type(type)
	
	# Update music based on new stage state
	_update_music_from_stage()
	
	# Check concert condition
	if game_manager:
		game_manager.check_concert_condition()

func _reorganize_type(type: Critter.CritterType):
	# Reposition all critters of this type
	var base_pos = stage_base_positions[type]
	var valid_critters = []
	
	for critter in stage_critters[type]:
		if is_instance_valid(critter):
			valid_critters.append(critter)
	
	stage_critters[type] = valid_critters
	
	for i in range(valid_critters.size()):
		var offset_x = (valid_critters.size() - 1) * CRITTER_SPACING / 2.0
		var target_pos = base_pos + Vector2(-offset_x + i * CRITTER_SPACING, 0)
		
		var tween = create_tween()
		tween.tween_property(valid_critters[i], "position", target_pos, 0.3)

func _update_music_from_stage():
	# Calculate max level for each critter type on stage
	var max_levels = {
		Critter.CritterType.MELODY: 0,
		Critter.CritterType.DRUMS: 0,
		Critter.CritterType.PAD: 0
	}
	
	for type in stage_critters:
		for critter in stage_critters[type]:
			if is_instance_valid(critter):
				var level = 0
				match critter.critter_level:
					Critter.CritterLevel.LEVEL_3: level = 1  # Layer 1
					Critter.CritterLevel.LEVEL_4: level = 2  # Layer 2
					Critter.CritterLevel.LEVEL_5: level = 3  # Layer 3
				
				if level > max_levels[type]:
					max_levels[type] = level
	
	# Update AudioManager
	AudioManager.update_music_intensity(
		max_levels[Critter.CritterType.MELODY],
		max_levels[Critter.CritterType.DRUMS],
		max_levels[Critter.CritterType.PAD]
	)

func get_max_level_for_type(type: Critter.CritterType) -> int:
	var max_level = 0
	for critter in stage_critters[type]:
		if is_instance_valid(critter):
			if critter.critter_level > max_level:
				max_level = critter.critter_level
	return max_level

func _on_stage_reset():
	for type in stage_critters:
		for critter in stage_critters[type]:
			if is_instance_valid(critter):
				critter.queue_free()
		stage_critters[type].clear()

func get_global_stage_position(type: Critter.CritterType) -> Vector2:
	var local_pos = _get_next_position_for_type(type)
	return get_global_position() + local_pos
