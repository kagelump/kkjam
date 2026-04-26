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
var grid = null
var ui: Control = null
var stage_display = null

func _ready():
	# Get references if they exist
	if has_node("../Grid"):
		grid = get_node("../Grid")
	if has_node("../UI"):
		ui = get_node("../UI")
	if has_node("../StageBackground"):
		stage_display = get_node("../StageBackground")
	
	update_ui()
	# Start BGM
	AudioManager.start_music()
	
	print("KKJam - Phase 2.5 Started")
	print("Match 3 to merge! Get Level 5 of each type to trigger concert!")

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
		trigger_concert()

func trigger_concert():
	print("ULTIMATE CONCERT TRIGGERED!")
	emit_signal("concert_triggered")
	complete_album()

func complete_album():
	albums_completed += 1
	current_bpm += 10  # Increase tempo
	update_ui()
	print("Album completed! Total albums: ", albums_completed)
	
	# Reset for next tour stop
	reset_stage()
	# In a real implementation, we'd wait for the concert animation to finish
	if grid:
		grid.reset_board()

func reset_stage():
	emit_signal("stage_reset")
	print("Stage cleared for next tour stop")
