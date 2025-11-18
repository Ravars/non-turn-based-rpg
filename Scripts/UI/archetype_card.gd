extends PanelContainer

class_name ArchetypeCard

signal add_pressed(archetype: CharacterArchetype)
signal remove_pressed(archetype: CharacterArchetype)

var archetype: CharacterArchetype

@onready var character_name_label = $VBoxContainer/CharacterNameLabel
@onready var texture_rect = $VBoxContainer/TextureRect
@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var add_button: Button = $VBoxContainer/AddButton
@onready var remove_button: Button = $VBoxContainer/RemoveButton

func _ready():
	add_button.pressed.connect(_on_add_pressed)
	remove_button.pressed.connect(_on_remove_pressed)
	_update_ui()

func setup(_archetype: CharacterArchetype):
	self.archetype = _archetype
	if is_node_ready():
		_update_ui()

func _update_ui():
	if archetype:
		character_name_label.text = archetype.character_name
		description_label.text = archetype.description
		#if archetype.texture:
			#texture_rect.texture = archetype.texture

func set_selected(is_selected: bool):
	if not is_node_ready():
		await ready
	if is_selected:
		add_button.visible = false
		remove_button.visible = true
	else:
		add_button.visible = true
		remove_button.visible = false

func _on_add_pressed():
	add_pressed.emit(archetype)

func _on_remove_pressed():
	remove_pressed.emit(archetype)
