extends PanelContainer
class_name CharacterStatsPanel

@onready var character_name_label = $VBoxContainer/CharacterNameLabel
@onready var stats_container = $VBoxContainer/StatsContainer
@onready var skills_container = $VBoxContainer/SkillsContainer

func display_stats(unit: Unit):
	var archetype = unit.archetype
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
		var damage = CombatManager.get_total_damage(unit, skill)
		var heal = CombatManager.get_total_heal(unit, skill)
		var text = "%s - Dmg: %d" % [skill.skill_name, damage]
		if heal > 0:
			text += ", Heal: %d" % heal
		text += ", Cast: %.1f, CD: %.1f" % [skill.cast_time, skill.cooldown]
		skill_label.text = text
		skills_container.add_child(skill_label)

		for effect in skill.status_effects:
			var effect_label = Label.new()
			var effect_text = "  Effect: %s, Duration: %.1f" % [effect.effect_name, effect.duration]
			if effect.value > 0:
				effect_text += ", Value: %.1f" % [effect.value]
			effect_label.text = effect_text
			skills_container.add_child(effect_label)

func add_stat(stat_name: String, stat_value):
	var name_label = Label.new()
	name_label.text = stat_name
	stats_container.add_child(name_label)
	
	var value_label = Label.new()
	value_label.text = str(stat_value)
	stats_container.add_child(value_label)
