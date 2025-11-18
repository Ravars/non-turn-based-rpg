extends PanelContainer
class_name CharacterStatsPanel

@onready var character_name_label = $VBoxContainer/CharacterNameLabel
@onready var stats_container = $VBoxContainer/StatsContainer
@onready var skills_container = $VBoxContainer/SkillsContainer

func display_stats(archetype: CharacterArchetype):
	character_name_label.text = archetype.character_name
	
	# Clear previous stats
	for child in stats_container.get_children():
		child.queue_free()
	
	# Display new stats
	add_stat("Health", archetype.base_stats.health)
	add_stat("Strength", archetype.base_stats.strength)
	add_stat("Intelligence", archetype.base_stats.intelligence)
	add_stat("Focus", archetype.base_stats.focus)

	# Clear previous skills
	for child in skills_container.get_children():
		child.queue_free()
		
	# Display new skills
	for skill in archetype.starting_skills:
		var skill_label = Label.new()
		skill_label.text = skill.skill_name
		skills_container.add_child(skill_label)

func add_stat(stat_name: String, stat_value):
	var name_label = Label.new()
	name_label.text = stat_name
	stats_container.add_child(name_label)
	
	var value_label = Label.new()
	value_label.text = str(stat_value)
	stats_container.add_child(value_label)
