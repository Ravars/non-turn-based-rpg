extends Node2D

@onready var act_1_encounters: EncounterDB = preload("res://Resources/Encounter/Act1_Encounters.tres")
var node_encounter_map: Dictionary = {}

@onready var node_button_1: Button = $VBoxContainer/NodeButton1
@onready var node_button_2: Button = $VBoxContainer/NodeButton2

func _ready() -> void:
	generate_map_path()
	node_button_1.pressed.connect(_on_node_button_pressed.bind(node_button_1))
	node_button_2.pressed.connect(_on_node_button_pressed.bind(node_button_2))

func generate_map_path():
	var available_encounters = act_1_encounters.normal_encounters.duplicate()

	if available_encounters.is_empty():
		print("ERRO")
		return
	available_encounters.shuffle()
	var encounter:EncounterData = available_encounters.pop_front()
	node_encounter_map[node_button_1] = encounter
	node_button_1.text = encounter.encounter_name

	if available_encounters.is_empty():
		available_encounters = act_1_encounters.normal_encounters.duplicate()
		available_encounters.shuffle()
	
	encounter = available_encounters.pop_front()
	node_encounter_map[node_button_2] = encounter
	node_button_2.text = encounter.encounter_name


func _on_node_button_pressed(button_node: Button):
	if node_encounter_map.has(button_node):
		var encounter: EncounterData = node_encounter_map[button_node]
		print("MAPA: Iniciando encontro {0}".format({0: encounter.encounter_name}))
		button_node.disabled = true
		var enemies: Array[CharacterArchetype] = encounter.enemy_archetypes.duplicate()
		GameManager.start_combat(enemies)
