extends PanelContainer

func update_info(skill: SkillData) -> void:
	$VBoxContainer/NameLabel.text = skill.skill_name
	$VBoxContainer/DescriptionLabel.text = skill.skill_description
	$VBoxContainer/DamageLabel.text = "Damage: {0}".format({0: str(skill.damage)})
	$VBoxContainer/CastTimeLabel.text = "Cast Time: {0}".format({0: str(skill.cast_time)})
