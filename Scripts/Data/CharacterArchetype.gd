extends Resource
class_name CharacterArchetype

@export var character_name: String = "Novo Arquétipo"
@export var description: String = "Descrição do Arquétipo"
@export var scene: PackedScene
@export var sprite_frames: SpriteFrames
@export var base_stats: CharacterStats
@export var starting_skills: Array[SkillData] = []
