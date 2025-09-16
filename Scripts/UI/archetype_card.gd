extends Button
class_name ArchetypeCard

var archetype: CharacterArchetype
@onready var character_name_label = $VBoxContainer/CharacterNameLabel
@onready var stats_container = $VBoxContainer/StatsHBoxContainer
@onready var skills_container = $VBoxContainer/SkillsHBoxContainer


func _ready():
	text = archetype.character_name
	var healthText = Label.new()
	healthText.text = "Health: " + str(archetype.base_stats.health)
	stats_container.add_child(healthText)

	var manaText = Label.new()
	manaText.text = "Mana: " + str(archetype.base_stats.health)
	stats_container.add_child(manaText)

	var strengthText = Label.new()
	strengthText.text = "Strength" + str(archetype.base_stats.health)
	stats_container.add_child(strengthText)

	var dexterityText = Label.new()
	dexterityText.text = "Dexterity" + str(archetype.base_stats.health)
	stats_container.add_child(dexterityText)
	
	for skill in archetype.starting_skills:
		var skill_text = Label.new()
		skill_text.text = skill.skill_name + " CastTime: " + str(skill.cast_time)
		skills_container.add_child(skill_text)


func setup(_archetype: CharacterArchetype):
	self.archetype = _archetype
	# var character_name_label: Label = $VBoxContainer/CharacterNameLabel
	# var stats_container = $VBoxContainer/StatsHBoxContainer
	# var skills_container = $VBoxContainer/SkillsHBoxContainer
	# character_name_label.text = archetype.character_name

	
