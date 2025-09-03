extends PanelContainer

func update_info(skill: SkillData, hero: Unit) -> void:
	$VBoxContainer/NameLabel.text = skill.skill_name
	$VBoxContainer/DescriptionLabel.text = skill.skill_description
	$VBoxContainer/DamageLabel.text = "Damage: {0} ({1})".format({0: str(skill.damage), 1: hero.get_final_strength()})
	$VBoxContainer/CastTimeLabel.text = "Cast Time: {0}".format({0: str(skill.cast_time)})
