extends RefCounted
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

func _uf_find(parent: Array, i: int) -> int:
	if parent[i] != i:
		parent[i] = _uf_find(parent, parent[i])
	return parent[i]

func _uf_union(parent: Array, a: int, b: int) -> void:
	var ra: int = _uf_find(parent, a)
	var rb: int = _uf_find(parent, b)
	if ra != rb:
		parent[ra] = rb

func _cell_key(c) -> String:
	return "%d,%d" % [c.grid_x, c.grid_y]

# Group line matches that share a critter (L / T / +) into one connected component; resolve each once.
# Dedupe by grid cell, not only object reference, so the same cell from two line matches always merges.
func _merge_components_from_matches(matches: Array) -> Array:
	var key_to_i: Dictionary = {}
	var all_critters: Array = []
	for m in matches:
		for c in m["critters"]:
			var k: String = _cell_key(c)
			if not key_to_i.has(k):
				key_to_i[k] = all_critters.size()
				all_critters.append(c)
	var n: int = all_critters.size()
	if n == 0:
		return []
	var parent: Array = []
	for i in range(n):
		parent.append(i)
	for m in matches:
		var cr: Array = m["critters"]
		if cr.is_empty():
			continue
		var i0: int = key_to_i[_cell_key(cr[0])]
		for t in range(1, cr.size()):
			_uf_union(parent, i0, key_to_i[_cell_key(cr[t])])
	var root_to_critters: Dictionary = {}
	for i in range(n):
		var r: int = _uf_find(parent, i)
		if not root_to_critters.has(r):
			root_to_critters[r] = []
		(root_to_critters[r] as Array).append(all_critters[i])
	return root_to_critters.values()

func _pick_merge_cell_for_component(
	comp: Array, swap_target: Vector2) -> Vector2i:
	if swap_target != Vector2(-1, -1):
		var sx: int = int(swap_target.x)
		var sy: int = int(swap_target.y)
		for critter in comp:
			if critter.grid_x == sx and critter.grid_y == sy:
				return Vector2i(sx, sy)
	# Stable middle by grid position
	var sorted_comp: Array = comp.duplicate()
	sorted_comp.sort_custom(func(a, b) -> bool:
		if a.grid_x != b.grid_x:
			return a.grid_x < b.grid_x
		return a.grid_y < b.grid_y
	)
	var mid: Critter = sorted_comp[sorted_comp.size() / 2]
	return Vector2i(mid.grid_x, mid.grid_y)

# Resolve matches: remove critters and create merged critter
func resolve_matches(matches: Array, swap_target: Vector2 = Vector2(-1, -1)):
	var components: Array = _merge_components_from_matches(matches)
	for comp in components:
		if comp.is_empty():
			continue
		var critters: Array = comp
		var critter_type = critters[0].critter_type
		var critter_level = critters[0].critter_level
		var merge_pos: Vector2i = _pick_merge_cell_for_component(critters, swap_target)
		var merge_x: int = merge_pos.x
		var merge_y: int = merge_pos.y
		# Remove all matched critters from grid
		for critter in critters:
			grid.remove_critter(critter.grid_x, critter.grid_y)
		# Create a new merged critter at the merge location
		var next_level: int = critter_level + 1
		if next_level <= Critter.CritterLevel.LEVEL_3:
			var new_critter = grid.spawn_critter(merge_x, merge_y, next_level)
			new_critter.initialize(critter_type, next_level, merge_x, merge_y)
			print("Merged into Level ", ["1", "2", "3"][next_level], " at ", merge_x, ",", merge_y)
			if next_level == Critter.CritterLevel.LEVEL_3:
				grid.handle_level_3_created(new_critter)
		else:
			print("Max level reached!")
		var points: int = 10 * (critter_level + 1) * critters.size()
		if grid.has_method("add_match_score"):
			grid.add_match_score(points)
		if critters.size() >= 5:
			AudioManager.play_sfx("match_large")
		elif critters.size() >= 4:
			AudioManager.play_sfx("match_medium")
		else:
			AudioManager.play_sfx("match_small")

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
