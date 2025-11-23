extends Control

@onready var rests_container = $VBoxContainer/RestsContainer
@onready var leave_button = $VBoxContainer/LeaveButton

func _ready():
	leave_button.pressed.connect(_on_leave_button_pressed)
	populate_rest_options()

func populate_rest_options():
	var upgrade_button = Button.new()
	upgrade_button.text = "Short Rest (Heal 20%)"
	upgrade_button.pressed.connect(_on_short_rest_selected)
	rests_container.add_child(upgrade_button)

	# And a new skill option
	var new_skill_button = Button.new()
	new_skill_button.text = "Revive a random hero"
	new_skill_button.pressed.connect(_on_revive_selected)
	rests_container.add_child(new_skill_button)

func _on_revive_selected():
	var dead_heroes = []
	for hero_data in GameManager.player_team:
		if hero_data.current_hp <= 0:
			dead_heroes.append(hero_data)
	
	if not dead_heroes.is_empty():
		var random_dead_hero = dead_heroes.pick_random()
		random_dead_hero.current_hp = random_dead_hero.archetype.base_stats.health * 0.5
		print("Revived: ", random_dead_hero.archetype.character_name)

	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func _on_short_rest_selected():
	for hero_data in GameManager.player_team:
		hero_data.current_hp = min(hero_data.current_hp + hero_data.archetype.base_stats.health * 0.2, hero_data.archetype.base_stats.health)
	
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func _on_leave_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")
