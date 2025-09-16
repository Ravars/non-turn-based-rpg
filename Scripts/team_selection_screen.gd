extends Control

@onready var available_archetypes_container = $AvailableArchetypesContainer
@onready var selected_archetypes_container = $SelectedContainer
@onready var start_run_button:Button = $Button
@export var archetype_card_scene: PackedScene

const TEAM_LIMIT = 3
var selected_archetypes: Array[CharacterArchetype] = []

func _ready():
	start_run_button.pressed.connect(_on_start_run_pressed)
	populate_available_archetypes()

func populate_available_archetypes():
	var available_heroes = GameManager.get_available_hero_archetype()
	for archetype in available_heroes:
		var card: ArchetypeCard = archetype_card_scene.instantiate()
		card.setup(archetype)
		# var card_button: Button = Button.new()
		# card_button.text = archetype.character_name
		card.pressed.connect(_on_archetype_selected.bind(archetype))
		available_archetypes_container.add_child(card)

func _on_start_run_pressed():
	if selected_archetypes.is_empty():
		print("Selecione pelo menos um herói.")
		return
	GameManager.start_new_run(selected_archetypes)

func _on_archetype_selected(archetype: CharacterArchetype):
	if selected_archetypes.size() >= TEAM_LIMIT:
		print("Limite da equipe atingido.")
		return
	if selected_archetypes.has(archetype):
		print("Já selecionado.")
		return
	selected_archetypes.append(archetype)
	update_selected_team_display()

func update_selected_team_display():
	for child in selected_archetypes_container.get_children():
		child.queue_free()
	for archetype in selected_archetypes:
		var name_label = Label.new()
		name_label.text = archetype.character_name
		selected_archetypes_container.add_child(name_label)
