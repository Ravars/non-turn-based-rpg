extends Node2D

@onready var graph_edit = $GraphEdit
@export var map_node_scene: PackedScene

var map_generator = MapGenerator.new()
var map_data: Array[Array]
var encounter_db: EncounterDB

func _ready():
	encounter_db = load("res://Resources/Encounter/Act1_EncountersDB.tres")
	map_data = map_generator.generate_map()
	generate_map_nodes()

func generate_map_nodes():
	var node_positions = {} # Store node positions to draw connections

	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
			var node_data = map_data[y][x]
			if node_data:
				var map_node: GraphNode = map_node_scene.instantiate()
				map_node.setup(node_data)
				map_node.position_offset = Vector2(x * 200 + 50, y * 120 + 50)
				graph_edit.add_child(map_node)
				node_positions[Vector2(x, y)] = map_node

				map_node.map_node_clicked.connect(_on_map_node_pressed)

	# Connect nodes
	for y in range(map_data.size() - 1):
		for x in range(map_data[y].size()):
			if map_data[y][x]:
				for next_x in range(map_data[y+1].size()):
					if map_data[y+1][next_x]:
						graph_edit.connect_node(node_positions[Vector2(x, y)].name, 0, node_positions[Vector2(next_x, y+1)].name, 0)

func _on_map_node_pressed(node_data: Dictionary):
	print("Encounter DB instance: ", encounter_db)
	match node_data.type:
		MapGenerator.NodeType.COMBAT:
			GameManager.start_combat(encounter_db.get_random_normal_encounter())
		MapGenerator.NodeType.ELITE_COMBAT:
			GameManager.start_combat(encounter_db.get_random_elite_encounter())
		MapGenerator.NodeType.BOSS:
			GameManager.start_combat(encounter_db.get_boss_encounter())
		MapGenerator.NodeType.EVENT:
			# Implement event logic
			pass
		MapGenerator.NodeType.SHOP:
			# Implement shop logic
			pass
