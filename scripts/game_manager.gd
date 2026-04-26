extends Node
class_name GameManager

signal concert_triggered
signal critter_collected(type, level)
signal stage_reset

# Game state
var score: int = 0
var albums_completed: int = 0
var current_bpm: int = 100

# References
var grid: Node2D = null
var ui: Control = null
var stage_display: Node = null

const CONCERT_DURATION_SEC: float = 2.5

@export var grid_path: NodePath = NodePath("../Grid")
@export var ui_path: NodePath = NodePath("../UI")
@export var stage_path: NodePath = NodePath("../StageBackground")
@export var background_path: NodePath = NodePath("../Background")

func _ready():
	if grid_path != NodePath(""):
		grid = get_node_or_null(grid_path) as Node2D
	if ui_path != NodePath(""):
		ui = get_node_or_null(ui_path) as Control
	if stage_path != NodePath(""):
		stage_display = get_node_or_null(stage_path) as Node
	if is_instance_valid(grid) and grid.has_signal("score_earned"):
		grid.score_earned.connect(add_score)
	if is_instance_valid(grid) and grid.has_signal("level_3_plus_merged"):
		grid.level_3_plus_merged.connect(_on_level_3_plus_merged)
	update_ui()
	AudioManager.start_music()
	print("KKJam - Phase 2.5 Started")
	print("Match 3 to merge! Get Level 5 of each type to trigger concert!")

func _on_level_3_plus_merged(critter: Critter) -> void:
	if is_instance_valid(critter):
		collect_critter(critter.critter_type, critter.critter_level)

func add_score(points: int):
	score += points
	update_ui()

func update_ui():
	if not is_instance_valid(ui):
		return
	var score_label := ui.get_node_or_null("ScoreLabel") as Label
	if score_label == null:
		return
	score_label.text = "Score: %d | Albums: %d | BPM: %d" % [score, albums_completed, current_bpm]

func collect_critter(type: Critter.CritterType, level: Critter.CritterLevel):
	emit_signal("critter_collected", type, level)
	print("Collected Level ", level + 1, " ", Critter.CritterType.keys()[type], " Critter")
	# Note: concert checking is now done in stage_display after merges

func check_concert_condition():
	# Check if we have at least one Level 5 of each type on stage
	if not stage_display:
		return
	
	var has_all_level_5 = true
	for type in [Critter.CritterType.MELODY, Critter.CritterType.DRUMS, Critter.CritterType.PAD]:
		var max_level = stage_display.get_max_level_for_type(type)
		if max_level < Critter.CritterLevel.LEVEL_5:
			has_all_level_5 = false
			break
	
	if has_all_level_5:
		await trigger_concert()

func trigger_concert() -> void:
	print("ULTIMATE CONCERT TRIGGERED!")
	emit_signal("concert_triggered")
	await complete_album()

func _flash_concert_background() -> void:
	var bg = get_node_or_null(background_path) as ColorRect
	if bg == null:
		return
	var orig: Color = bg.color
	var tw = create_tween().set_loops(3)
	tw.tween_property(bg, "color", orig.lightened(0.2), 0.25)
	tw.tween_property(bg, "color", orig, 0.25)

func complete_album() -> void:
	albums_completed += 1
	current_bpm += 10
	update_ui()
	print("Album completed! Total albums: ", albums_completed)
	if is_instance_valid(grid) and "processing_matches" in grid:
		grid.set("processing_matches", true)
	AudioManager.play_concert_cue()
	_flash_concert_background()
	await get_tree().create_timer(CONCERT_DURATION_SEC).timeout
	reset_stage()
	if is_instance_valid(grid) and grid.has_method("reset_board"):
		await grid.reset_board()

func reset_stage():
	emit_signal("stage_reset")
	print("Stage cleared for next tour stop")
