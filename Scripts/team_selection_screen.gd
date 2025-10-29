extends Control

@onready var available_archetypes_container = $AvailableArchetypesContainer
@onready var selected_archetypes_container = $SelectedContainer
@onready var start_run_button:Button = $Button
@export var archetype_card_scene: PackedScene

var TEAM_LIMIT = 3
var selected_archetypes: Array[CharacterArchetype] = []

func _ready():
	start_run_button.pressed.connect(_on_start_run_pressed)
	populate_available_archetypes()
	LimboConsole.register_command(create_random_team, "selection random")
	LimboConsole.register_command(set_team_size, "selection setteamsize")
	LimboConsole.register_command(reset_team, "selection reset")
	LimboConsole.register_command(start, "selection start")
	LimboConsole.register_command(start_random, "selection quick")
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
	start()

func start_random():
	create_random_team()
	start()
func start():
	if selected_archetypes.is_empty():
		print("Selecione pelo menos um herói.")
		return
	GameManager.start_new_run(selected_archetypes)
func _on_archetype_selected(archetype: CharacterArchetype):
	try_add_archetype(archetype)

func try_add_archetype(archetype: CharacterArchetype):
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

func create_random_team(team_size: int = 2):
	var available_heroes = GameManager.get_available_hero_archetype()
	while selected_archetypes.size() < team_size and selected_archetypes.size() < available_heroes.size() and selected_archetypes.size() < TEAM_LIMIT:
		var archetype = available_heroes.pick_random()
		try_add_archetype(archetype)

func set_team_size(new_size: int = 3):
	var available_heroes = GameManager.get_available_hero_archetype()
	TEAM_LIMIT = min(new_size, available_heroes.size())

func reset_team():
	selected_archetypes.clear()
	for child in selected_archetypes_container.get_children():
		child.queue_free()
