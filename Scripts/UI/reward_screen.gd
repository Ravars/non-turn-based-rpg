extends Control

@onready var card_container = $Panel/RewardHBoxContainer
@onready var hero_target_container = $Panel/HeroHBoxContainer
@onready var hero_target_label: Label = $Panel/HeroLabel
@onready var instruction_label: Label = $Panel/Label
@export var reward_card_scene: PackedScene
@export var hero_target_button_scene: PackedScene
var pending_skill_reward: SkillData = null
func _ready():
	hero_target_container.visible = false
	hero_target_label.visible = false
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
	self.pending_skill_reward = selected_skill
	card_container.visible = false
	instruction_label.text = "Habilidade {0} selecionada.".format({0: selected_skill.skill_name})
	hero_target_label.visible = true
	populate_hero_targets()
	#GameManager.add_skill_to_hero(selected_skill)
	#call_deferred("_continue_to_map")

func populate_hero_targets():
	for child in hero_target_container.get_children():
		child.queue_free()
	hero_target_container.visible = true
	var player_team = GameManager.player_team
	for hero_data in player_team:
		var target_button:Button = hero_target_button_scene.instantiate()
		target_button.setup(hero_data)
		target_button.pressed.connect(_on_hero_target_selected.bind(hero_data))
		hero_target_container.add_child(target_button)
	
func _on_hero_target_selected(target_hero_data: PlayerCharacterData):
	if not pending_skill_reward:
		return
	GameManager.add_skill_to_hero(pending_skill_reward, target_hero_data)
	call_deferred("_continue_to_map")
