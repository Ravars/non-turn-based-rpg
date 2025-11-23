extends Node

class_name MapGenerator

const MAP_WIDTH = 3
const MAP_HEIGHT = 8

enum NodeType { START, COMBAT, ELITE_COMBAT, REST, SHOP, BOSS, RECRUITMENT, UPGRADE }

func generate_map() -> Array[Array]:
	var map_data: Array[Array] = []
	for y in range(MAP_HEIGHT):
		var row = []
		for x in range(MAP_WIDTH):
			row.append(null)
		map_data.append(row)

	# Create a start node
	var start_x = randi() % MAP_WIDTH
	map_data[0][start_x] = _generate_node_data(0, false, true)

	# Create a random path
	var current_x = start_x
	for y in range(1, MAP_HEIGHT):
		map_data[y][current_x] = _generate_node_data(y)
		
		# Add branching paths
		if randf() < 0.3:
			var branch_x = (current_x + 1) % MAP_WIDTH
			if map_data[y][branch_x] == null:
				map_data[y][branch_x] = _generate_node_data(y)
		
		# Move to the next row
		current_x = clamp(current_x + randi_range(-1, 1), 0, MAP_WIDTH - 1)

	# Add boss node
	map_data.append([_generate_node_data(MAP_HEIGHT, true)])
	
	return map_data

func _generate_node_data(y: int, is_boss: bool = false, is_start: bool = false) -> Dictionary:
	var node_type: NodeType
	if is_boss:
		node_type = NodeType.BOSS
	elif is_start:
		node_type = NodeType.START
	else:
		var rand = randf()
		if rand < 0.4:
			node_type = NodeType.COMBAT
		elif rand < 0.6:
			node_type = NodeType.REST
		elif rand < 0.7:
			node_type = NodeType.ELITE_COMBAT
		elif rand < 0.8:
			node_type = NodeType.RECRUITMENT
		elif rand < 0.9:
			node_type = NodeType.UPGRADE
		else:
			node_type = NodeType.SHOP
			
	return {
		"type": node_type,
		"position": Vector2(0, 0) # Position will be set later
	}
