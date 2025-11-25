extends PanelContainer

var hero_data: PlayerCharacterData

@onready var name_label = $VBoxContainer/NameLabel
@onready var texture_rect = $VBoxContainer/TextureRect

func _ready():
	name_label.text = hero_data.archetype.character_name
	if hero_data.archetype.sprite_frames:
		var sprite_frames = hero_data.archetype.sprite_frames
		if sprite_frames.has_animation("default") and sprite_frames.get_frame_count("default") > 0:
			texture_rect.texture = sprite_frames.get_frame_texture("default", 0)

func setup(_hero_data: PlayerCharacterData):
	self.hero_data = _hero_data

func _get_drag_data(at_position):
	var data = {"hero_data": hero_data}
	var preview = Label.new()
	preview.text = hero_data.archetype.character_name
	set_drag_preview(preview)
	return data
