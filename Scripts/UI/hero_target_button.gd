extends Button

@onready var name_label: Label = $VBoxContainer/Label
@onready var sprite_texture: TextureRect = $VBoxContainer/TextureRect
var hero: PlayerCharacterData

func setup(hero_data: PlayerCharacterData):
	self.hero = hero_data
	
func _ready() -> void:
	name_label.text = hero.archetype.character_name
	#sprite_texture.texture = hero.archetype.sprite
