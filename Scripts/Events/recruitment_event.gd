extends Control

@onready var archetypes_container = $VBoxContainer/ArchetypesContainer
@onready var leave_button = $VBoxContainer/LeaveButton

@export var archetype_card_scene: PackedScene

var available_archetypes: Array[CharacterArchetype] = []

func _ready():
	leave_button.pressed.connect(_on_leave_button_pressed)
	populate_available_archetypes()

func populate_available_archetypes():
	var all_heroes = GameManager.get_available_hero_archetype()
	# Filter out heroes already in the player's team
	var player_archetypes = GameManager.player_team.map(func(data): return data.archetype)
	available_archetypes = all_heroes.filter(func(archetype): return not player_archetypes.has(archetype))
	
	# Display up to 3 random archetypes
	available_archetypes.shuffle()
	var num_to_display = min(3, available_archetypes.size())
	
	for i in range(num_to_display):
		var archetype = available_archetypes[i]
		var card: ArchetypeCard = archetype_card_scene.instantiate()
		card.setup(archetype)
		card.add_pressed.connect(_on_archetype_selected)
		archetypes_container.add_child(card)

func _on_archetype_selected(archetype: CharacterArchetype):
	var new_character_data = PlayerCharacterData.new()
	new_character_data.archetype = archetype
	new_character_data.current_hp = archetype.base_stats.health
	GameManager.player_team.append(new_character_data)
	
	print("Recruited: ", archetype.character_name)
	
	# Transition back to the map scene
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func _on_leave_button_pressed():
	# Transition back to the map scene without recruiting anyone
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")
