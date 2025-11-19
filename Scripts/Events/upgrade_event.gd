extends Control

@onready var upgrades_container = $VBoxContainer/UpgradesContainer
@onready var leave_button = $VBoxContainer/LeaveButton

func _ready():
	leave_button.pressed.connect(_on_leave_button_pressed)
	populate_upgrade_options()

func populate_upgrade_options():
	# For now, let's just add a simple stat upgrade option
	var upgrade_button = Button.new()
	upgrade_button.text = "+5 Strength to a random hero"
	upgrade_button.pressed.connect(_on_upgrade_selected.bind("strength", 5))
	upgrades_container.add_child(upgrade_button)

	# And a new skill option
	var new_skill_button = Button.new()
	new_skill_button.text = "Add a new skill to a random hero"
	new_skill_button.pressed.connect(_on_new_skill_selected)
	upgrades_container.add_child(new_skill_button)

func _on_upgrade_selected(stat: String, amount: int):
	var random_hero = GameManager.player_team.pick_random()
	var oldvalue = random_hero.archetype.base_stats.strength
	match stat:
		"strength":
			random_hero.archetype.base_stats.strength += amount
	
	print("Upgraded %s's %s by %d, %d -> %d" % [random_hero.archetype.character_name, stat, amount,oldvalue,random_hero.archetype.base_stats.strength])
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func _on_new_skill_selected():
	var random_hero = GameManager.player_team.pick_random()
	var new_skill = GameManager.get_skill_reward_options(1)[0]
	GameManager.add_skill_to_hero(new_skill, random_hero)
	
	print("Added skill %s to %s" % [new_skill.skill_name, random_hero.archetype.character_name])
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func _on_leave_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")
