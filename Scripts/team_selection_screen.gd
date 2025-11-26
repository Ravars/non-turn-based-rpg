extends Control

@onready var available_archetypes_container = $HBoxContainer/AvailableArchetypesVBox/AvailableArchetypesContainer
@onready var selected_archetypes_container = $SelectedTeamVBox/SelectedArchetypesContainer
@onready var character_details_container = $HBoxContainer/CharacterDetailsVBox/CharacterStatsPanelContainer
@onready var confirm_button: Button = $SelectedTeamVBox/ConfirmButton

@export var archetype_card_scene: PackedScene
@export var character_stats_panel_scene: PackedScene
@export var skill_tooltip_scene: PackedScene

var TEAM_LIMIT = 3
var selected_archetypes: Array[CharacterArchetype] = []
var displayed_archetype_cards: Dictionary = {} # Stores archetype -> card instance
var character_stats_panel: CharacterStatsPanel
var current_hovered_skill_tooltip: Control = null

func _ready():
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	character_stats_panel = character_stats_panel_scene.instantiate() as CharacterStatsPanel
	character_details_container.add_child(character_stats_panel)
	
	populate_available_archetypes()
	update_confirm_button_state()

func populate_available_archetypes():
	var available_heroes = GameManager.get_available_hero_archetype()
	for archetype in available_heroes:
		var card: ArchetypeCard = archetype_card_scene.instantiate()
		card.setup(archetype)
		card.add_pressed.connect(_on_archetype_added)
		card.remove_pressed.connect(_on_archetype_removed)
		card.gui_input.connect(_on_archetype_card_gui_input.bind(card, archetype))
		available_archetypes_container.add_child(card)
		displayed_archetype_cards[archetype] = card

func _on_archetype_card_gui_input(event: InputEvent, _card: ArchetypeCard, archetype: CharacterArchetype):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_archetype_card_pressed(archetype)

func _on_archetype_added(archetype: CharacterArchetype):
	if selected_archetypes.size() >= TEAM_LIMIT:
		print("Limite da equipe atingido.")
		return
	if selected_archetypes.has(archetype):
		print("Já selecionado.")
		return
	
	selected_archetypes.append(archetype)
	update_selected_team_display()
	displayed_archetype_cards[archetype].set_selected(true)
	update_confirm_button_state()

func _on_archetype_removed(archetype: CharacterArchetype):
	if selected_archetypes.has(archetype):
		selected_archetypes.erase(archetype)
		update_selected_team_display()
		displayed_archetype_cards[archetype].set_selected(false)
		update_confirm_button_state()

@export var unit_scene: PackedScene

func _on_archetype_card_pressed(archetype: CharacterArchetype):
	var temp_unit = unit_scene.instantiate()
	temp_unit.initialize(archetype, Unit.LanePosition.FRONT)
	character_stats_panel.display_stats(temp_unit)
	temp_unit.queue_free()


func update_selected_team_display():
	for child in selected_archetypes_container.get_children():
		child.queue_free()
	
	for archetype in selected_archetypes:
		var card: ArchetypeCard = archetype_card_scene.instantiate()
		card.setup(archetype)
		card.set_selected(true)
		card.remove_pressed.connect(_on_archetype_removed)
		card.gui_input.connect(_on_archetype_card_gui_input.bind(card, archetype))
		selected_archetypes_container.add_child(card)

func update_confirm_button_state():
	confirm_button.disabled = selected_archetypes.is_empty()

func _on_confirm_button_pressed():
	if selected_archetypes.is_empty():
		return
	GameManager.start_new_run(selected_archetypes)
