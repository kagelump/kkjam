extends Control

@onready var game_manager: GameManager = $"../GameManager"
var critter_scene = preload("res://scenes/critter.tscn")

# Positions for the 4 critters on stage
# Stage is 512x200. Center Y is 100.
# X positions: 1/8, 3/8, 5/8, 7/8 of 512
var stage_positions = {
	Critter.CritterType.BUNNY: Vector2(64, 100),
	Critter.CritterType.CAT: Vector2(192, 100),
	Critter.CritterType.FROG: Vector2(320, 100),
	Critter.CritterType.BIRD: Vector2(448, 100)
}

var active_critters = {}

func _ready():
	if game_manager:
		game_manager.critter_collected.connect(_on_critter_collected)
		game_manager.stage_reset.connect(_on_stage_reset)

func _on_critter_collected(type: Critter.CritterType):
	if active_critters.has(type):
		return
		
	var pos = stage_positions.get(type, Vector2.ZERO)
	if pos == Vector2.ZERO:
		return
		
	var critter = critter_scene.instantiate()
	critter.visible = false # Start hidden, wait for grid animation
	add_child(critter)
	
	# Initialize as Level 3
	critter.initialize(type, Critter.CritterLevel.LEVEL_3, -1, -1)
	critter.position = pos
	
	# Make it look "active" / "performing"
	critter.scale = Vector2(1.2, 1.2)
	
	active_critters[type] = critter
	
	# Wait for grid animation (0.6s) then show
	await get_tree().create_timer(0.6).timeout
	if is_instance_valid(critter):
		critter.visible = true
		
		# Add a simple bounce animation
		var tween = create_tween().set_loops()
		tween.tween_property(critter, "scale", Vector2(1.3, 1.3), 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(critter, "scale", Vector2(1.2, 1.2), 0.5).set_trans(Tween.TRANS_SINE)

func _on_stage_reset():
	for type in active_critters:
		var critter = active_critters[type]
		if is_instance_valid(critter):
			critter.queue_free()
	active_critters.clear()

func get_global_stage_position(type: Critter.CritterType) -> Vector2:
	var local_pos = stage_positions.get(type, Vector2.ZERO)
	if local_pos == Vector2.ZERO:
		return Vector2.ZERO
	return get_global_position() + local_pos
