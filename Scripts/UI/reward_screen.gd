extends Control

@onready var card_container = $Panel/RewardHBoxContainer
@export var reward_card_scene: PackedScene

func _ready():
	
	var skill_options = GameManager.get_skill_reward_options(3)
	if skill_options.is_empty():
		print("Nenhuma recompensa encontrada")
		_continue_to_map()
		return
	for skill in skill_options:
		var card: RewardCard = reward_card_scene.instantiate()
		card.setup(skill)
		card.reward_selected.connect(_on_reward_selected)
		card_container.add_child(card)

func _continue_to_map():
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/MapScene.tscn")

func _on_reward_selected(selected_skill: SkillData):
	GameManager.add_skill_to_hero(selected_skill)
	call_deferred("_continue_to_map")
