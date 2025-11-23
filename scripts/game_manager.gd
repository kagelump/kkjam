extends Node
class_name GameManager

# Game state
var score: int = 0
var albums_completed: int = 0
var current_bpm: int = 100

# References
@onready var grid: Grid = $"../Grid"
@onready var ui: Control = $"../UI"

func _ready():
	print("KKJam - Phase 1 MVP Started")
	print("Click critters to select, then click an adjacent critter to swap")
	print("Match 3 or more of the same type and level to score!")

func add_score(points: int):
	score += points
	update_ui()

func update_ui():
	# Will be implemented when UI is added
	pass

func complete_album():
	albums_completed += 1
	current_bpm += 10  # Increase tempo
	print("Album completed! Total albums: ", albums_completed)
	# Future: trigger concert animation, reset board, etc.
