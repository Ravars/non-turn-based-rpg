extends Node2D

@onready var graph_edit = $GraphEdit
@export var map_node_scene: PackedScene

var map_data: Array[Array]
var encounter_db: EncounterDB

var node_positions = {} # Store node positions to draw connections

func _ready():
	var team_formation_button = Button.new()
	team_formation_button.text = "Team Formation"
	team_formation_button.pressed.connect(_on_team_formation_button_pressed)
	add_child(team_formation_button)

	encounter_db = load("res://Resources/Encounter/Act1_EncountersDB.tres")
	map_data = GameManager.map_data
	generate_map_nodes()
	graph_edit.arrange_nodes()

func _on_team_formation_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/TeamFormationScreen.tscn")


func generate_map_nodes():
	node_positions.clear()

	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
			var node_data = map_data[y][x]
			if node_data:
				var map_node: GraphNode = map_node_scene.instantiate()
				var node_pos = Vector2i(x,y)
				map_node.setup(node_data, node_pos)
				map_node.position_offset = Vector2(x * 200 + 50, y * 120 + 50)
				graph_edit.add_child(map_node)
				node_positions[Vector2(x, y)] = map_node

				if node_data.type == MapGenerator.NodeType.START:
					map_node.modulate = Color.WHITE
					GameManager.update_current_map_node_ref(map_node)
				elif not GameManager.visited_nodes.has(node_pos):
					map_node.map_node_clicked.connect(_on_map_node_pressed)
				
				if node_pos == GameManager.current_player_pos:
					map_node.modulate = Color.GREEN
					GameManager.update_current_map_node_ref(map_node)


	# Connect nodes
	for y in range(map_data.size() - 1):
		for x in range(map_data[y].size()):
			if map_data[y][x]:
				for next_x in range(map_data[y+1].size()):
					if map_data[y+1][next_x]:
						graph_edit.connect_node(node_positions[Vector2(x, y)].name, 0, node_positions[Vector2(next_x, y+1)].name, 0)

func _on_map_node_pressed(node_data: Dictionary, map_node: GraphNode, node_pos: Vector2i):
	
	if node_data.type == MapGenerator.NodeType.START:
		return

	if not (node_pos.y == GameManager.current_player_pos.y + 1 or (GameManager.current_player_pos.y == 0 and node_pos.y == 0)):
		print("Invalid move")
		return

	# Clear previous highlight
	if is_instance_valid(GameManager.current_map_node_ref):
		GameManager.current_map_node_ref.modulate = Color.WHITE

	# Update player position
	GameManager.add_visited_node(GameManager.current_player_pos)
	GameManager.update_player_pos(node_pos)
	GameManager.update_current_map_node_ref(map_node)

	# Highlight new position
	map_node.modulate = Color.GREEN

	match node_data.type:
		MapGenerator.NodeType.COMBAT:
			GameManager.start_combat(encounter_db.get_random_normal_encounter())
		MapGenerator.NodeType.ELITE_COMBAT:
			GameManager.start_combat(encounter_db.get_random_elite_encounter())
		MapGenerator.NodeType.BOSS:
			GameManager.start_combat(encounter_db.get_boss_encounter())
		MapGenerator.NodeType.RECRUITMENT:
			get_tree().change_scene_to_file("res://Scenes/Events/RecruitmentEvent.tscn")
		MapGenerator.NodeType.UPGRADE:
			get_tree().change_scene_to_file("res://Scenes/Events/UpgradeEvent.tscn")
		MapGenerator.NodeType.REST:
			get_tree().change_scene_to_file("res://Scenes/Events/RestEvent.tscn")
		MapGenerator.NodeType.SHOP:
			# Implement shop logic
			pass
