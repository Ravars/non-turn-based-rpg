extends Control

@onready var unassigned_container = $VBoxContainer/HBoxContainer/UnassignedContainer
@onready var front_lane_container = $VBoxContainer/HBoxContainer/FrontLaneContainer
@onready var back_lane_container = $VBoxContainer/HBoxContainer/BackLaneContainer
@onready var done_button = $VBoxContainer/DoneButton

@export var hero_card_scene: PackedScene

func _ready():
	done_button.pressed.connect(_on_done_button_pressed)
	unassigned_container.hero_dropped.connect(_on_hero_dropped_in_unassigned)
	front_lane_container.hero_dropped.connect(_on_hero_dropped_in_front_lane)
	back_lane_container.hero_dropped.connect(_on_hero_dropped_in_back_lane)
	populate_heroes()

func populate_heroes():
	for hero_data in GameManager.player_team:
		var hero_card = hero_card_scene.instantiate()
		hero_card.setup(hero_data)
		unassigned_container.add_child(hero_card)

func _on_hero_dropped_in_unassigned(hero_data: PlayerCharacterData):
	move_hero_card(hero_data, unassigned_container)

func _on_hero_dropped_in_front_lane(hero_data: PlayerCharacterData):
	move_hero_card(hero_data, front_lane_container)

func _on_hero_dropped_in_back_lane(hero_data: PlayerCharacterData):
	move_hero_card(hero_data, back_lane_container)

func move_hero_card(hero_data: PlayerCharacterData, new_container: VBoxContainer):
	# Find the hero card in the other containers and remove it
	for container in [unassigned_container, front_lane_container, back_lane_container]:
		for child in container.get_children():
			if child is PanelContainer and child.hero_data == hero_data:
				child.queue_free()
				break
	
	# Add the hero card to the new container
	var hero_card = hero_card_scene.instantiate()
	hero_card.setup(hero_data)
	new_container.add_child(hero_card)

func _on_done_button_pressed():
	var front_lane_heroes: Array[PlayerCharacterData] = []
	for child in front_lane_container.get_children():
		if child is PanelContainer:
			front_lane_heroes.append(child.hero_data)
	
	var back_lane_heroes: Array[PlayerCharacterData] = []
	for child in back_lane_container.get_children():
		if child is PanelContainer:
			back_lane_heroes.append(child.hero_data)
			
	GameManager.set_team_formation(front_lane_heroes, back_lane_heroes)
	
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")
