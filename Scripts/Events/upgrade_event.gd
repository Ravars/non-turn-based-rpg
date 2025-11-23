extends Control

@onready var upgrades_container = $VBoxContainer/UpgradesContainer
@onready var leave_button = $VBoxContainer/LeaveButton

func _ready():
	leave_button.pressed.connect(_on_leave_button_pressed)
	populate_upgrade_options()

func populate_upgrade_options():
	# Clear previous options
	for child in upgrades_container.get_children():
		child.queue_free()

	# Add skill options
	var skill_options = GameManager.get_skill_reward_options(3)
	for skill in skill_options:
		var skill_button = Button.new()
		skill_button.text = "New Skill: " + skill.skill_name
		skill_button.pressed.connect(_on_skill_selected.bind(skill))
		upgrades_container.add_child(skill_button)

	# Add stat upgrade options
	var stats = ["Strength", "Dexterity", "Intelligence"]
	for i in range(3):
		var stat_button = Button.new()
		var stat_name = stats.pick_random()
		var amount = randi_range(1, 5)
		stat_button.text = "+%d %s" % [amount, stat_name]
		stat_button.pressed.connect(_on_stat_upgrade_selected.bind(stat_name, amount))
		upgrades_container.add_child(stat_button)

func _on_skill_selected(skill: SkillData):
	# Clear options and show hero selection
	for child in upgrades_container.get_children():
		child.queue_free()
	
	for hero_data in GameManager.player_team:
		var hero_button = Button.new()
		hero_button.text = hero_data.archetype.character_name
		hero_button.pressed.connect(_on_hero_for_skill_selected.bind(skill, hero_data))
		upgrades_container.add_child(hero_button)

func _on_hero_for_skill_selected(skill: SkillData, hero_data: PlayerCharacterData):
	GameManager.add_skill_to_hero(skill, hero_data)
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func _on_stat_upgrade_selected(stat: String, amount: int):
	# Clear options and show hero selection
	for child in upgrades_container.get_children():
		child.queue_free()

	for hero_data in GameManager.player_team:
		var hero_button = Button.new()
		hero_button.text = hero_data.archetype.character_name
		hero_button.pressed.connect(_on_hero_for_stat_selected.bind(stat, amount, hero_data))
		upgrades_container.add_child(hero_button)

func _on_hero_for_stat_selected(stat: String, amount: int, hero_data: PlayerCharacterData):
	match stat:
		"Strength":
			hero_data.archetype.base_stats.strength += amount
		"Dexterity":
			hero_data.archetype.base_stats.dexterity += amount
		"Intelligence":
			hero_data.archetype.base_stats.intelligence += amount
	
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func _on_leave_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")
