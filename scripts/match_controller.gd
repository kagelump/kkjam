extends Node
class_name MatchController

# Reference to the grid
var grid: Node2D

func _init(grid_ref: Node2D):
	grid = grid_ref

# Find all matches on the board (horizontal and vertical lines of 3+)
func find_matches() -> Array:
	var matches = []
	var grid_data = grid.grid_data
	var grid_width = grid.GRID_WIDTH
	var grid_height = grid.GRID_HEIGHT
	
	# Check horizontal matches
	for y in range(grid_height):
		var x = 0
		while x < grid_width:
			var critter = grid_data[x][y]
			if critter == null:
				x += 1
				continue
				
			var match_length = 1
			var match_type = critter.critter_type
			var match_level = critter.critter_level
			
			# Count consecutive matching critters
			while x + match_length < grid_width:
				var next_critter = grid_data[x + match_length][y]
				if next_critter and next_critter.critter_type == match_type and next_critter.critter_level == match_level:
					match_length += 1
				else:
					break
			
			# If we found 3 or more, record the match
			if match_length >= 3:
				var match_critters = []
				for i in range(match_length):
					match_critters.append(grid_data[x + i][y])
				matches.append({
					"critters": match_critters,
					"type": match_type,
					"level": match_level,
					"merge_x": x,
					"merge_y": y
				})
				x += match_length
			else:
				x += 1
	
	# Check vertical matches
	for x in range(grid_width):
		var y = 0
		while y < grid_height:
			var critter = grid_data[x][y]
			if critter == null:
				y += 1
				continue
				
			var match_length = 1
			var match_type = critter.critter_type
			var match_level = critter.critter_level
			
			# Count consecutive matching critters
			while y + match_length < grid_height:
				var next_critter = grid_data[x][y + match_length]
				if next_critter and next_critter.critter_type == match_type and next_critter.critter_level == match_level:
					match_length += 1
				else:
					break
			
			# If we found 3 or more, record the match
			if match_length >= 3:
				var match_critters = []
				for i in range(match_length):
					match_critters.append(grid_data[x][y + i])
				matches.append({
					"critters": match_critters,
					"type": match_type,
					"level": match_level,
					"merge_x": x,
					"merge_y": y
				})
				y += match_length
			else:
				y += 1
	
	return matches

# Resolve matches: remove critters and create merged critter
func resolve_matches(matches: Array, swap_target: Vector2 = Vector2(-1, -1)):
	for match in matches:
		var critters = match["critters"]
		var critter_type = match["type"]
		var critter_level = match["level"]
		
		# Determine merge location
		var merge_x = match["merge_x"]
		var merge_y = match["merge_y"]
		
		# If swap_target is valid and is part of this match, use it as merge location
		if swap_target != Vector2(-1, -1):
			for critter in critters:
				if critter.grid_x == int(swap_target.x) and critter.grid_y == int(swap_target.y):
					merge_x = int(swap_target.x)
					merge_y = int(swap_target.y)
					break
		else:
			# If no swap target (e.g. cascade match), try to use the middle critter
			if critters.size() >= 3:
				var middle_critter = critters[critters.size() / 2]
				merge_x = middle_critter.grid_x
				merge_y = middle_critter.grid_y
		
		# Remove all matched critters from grid
		for critter in critters:
			grid.remove_critter(critter.grid_x, critter.grid_y)
		
		# Create a new merged critter at the merge location
		var next_level = critter_level + 1
		
		if next_level <= Critter.CritterLevel.LEVEL_3:
			# Spawn the upgraded critter
			var new_critter = grid.spawn_critter(merge_x, merge_y, next_level)
			# Set type explicitly to match the merged ones (spawn_critter randomizes type by default)
			new_critter.initialize(critter_type, next_level, merge_x, merge_y)
			
			print("Merged into Level ", ["1", "2", "3"][next_level], " at ", merge_x, ",", merge_y)
			
			# Check if we created a Level 3 critter
			if next_level == Critter.CritterLevel.LEVEL_3:
				grid.handle_level_3_created(new_critter)
		else:
			# Should not happen if max level is 3, but just in case
			print("Max level reached!")
		
		# Add score
		var points = 10 * (critter_level + 1) * critters.size()
		grid.get_node("../GameManager").add_score(points)

# Check if a swap would create a match
func would_create_match(x1: int, y1: int, x2: int, y2: int) -> bool:
	# Temporarily swap in grid data
	var grid_data = grid.grid_data
	var temp = grid_data[x1][y1]
	grid_data[x1][y1] = grid_data[x2][y2]
	grid_data[x2][y2] = temp
	
	# Check for matches
	var has_match = check_matches_at_position(x1, y1) or check_matches_at_position(x2, y2)
	
	# Swap back
	temp = grid_data[x1][y1]
	grid_data[x1][y1] = grid_data[x2][y2]
	grid_data[x2][y2] = temp
	
	return has_match

# Check if there's a match at a specific position
func check_matches_at_position(x: int, y: int) -> bool:
	var grid_data = grid.grid_data
	var critter = grid_data[x][y]
	
	if critter == null:
		return false
	
	var type = critter.critter_type
	var level = critter.critter_level
	
	# Check horizontal
	var h_count = 1
	# Check left
	var check_x = x - 1
	while check_x >= 0 and grid_data[check_x][y] != null and grid_data[check_x][y].critter_type == type and grid_data[check_x][y].critter_level == level:
		h_count += 1
		check_x -= 1
	# Check right
	check_x = x + 1
	while check_x < grid.GRID_WIDTH and grid_data[check_x][y] != null and grid_data[check_x][y].critter_type == type and grid_data[check_x][y].critter_level == level:
		h_count += 1
		check_x += 1
	
	if h_count >= 3:
		return true
	
	# Check vertical
	var v_count = 1
	# Check up
	var check_y = y - 1
	while check_y >= 0 and grid_data[x][check_y] != null and grid_data[x][check_y].critter_type == type and grid_data[x][check_y].critter_level == level:
		v_count += 1
		check_y -= 1
	# Check down
	check_y = y + 1
	while check_y < grid.GRID_HEIGHT and grid_data[x][check_y] != null and grid_data[x][check_y].critter_type == type and grid_data[x][check_y].critter_level == level:
		v_count += 1
		check_y += 1
	
	if v_count >= 3:
		return true
	
	return false
