extends Node
class_name GameManager

signal concert_triggered
signal critter_collected(type)
signal stage_reset

# Game state
var score: int = 0
var albums_completed: int = 0
var current_bpm: int = 100

# Collection state
var collected_critters: Dictionary = {
	Critter.CritterType.MELODY: false,
	Critter.CritterType.DRUMS: false,
	Critter.CritterType.PAD: false
}

# References
var grid: Grid = null
var ui: Control = null

func _ready():
	# Get references if they exist
	if has_node("../Grid"):
		grid = get_node("../Grid")
	if has_node("../UI"):
		ui = get_node("../UI")
	
	print("KKJam - Phase 2 Started")
	print("Match 3 to merge! Collect all 4 Level 3 critters to win!")

func add_score(points: int):
	score += points
	update_ui()

func update_ui():
	# Will be implemented when UI is added
	pass

func collect_critter(type: Critter.CritterType):
	if not collected_critters[type]:
		collected_critters[type] = true
		emit_signal("critter_collected", type)
		print("Collected Level 3 Critter: ", Critter.CritterType.keys()[type])
		check_concert_condition()

func check_concert_condition():
	var all_collected = true
	for type in collected_critters:
		if not collected_critters[type]:
			all_collected = false
			break
	
	if all_collected:
		trigger_concert()

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

func reset_stage():
	for type in collected_critters:
		collected_critters[type] = false
	emit_signal("stage_reset")
	print("Stage cleared for next tour stop")
