@tool
extends Button
class_name Ability_button

var skill_data: SkillData
var hero_owner: Unit
@export var timeline_ui: PlayerActionPanel

func _get_drag_data(_at_position: Vector2) -> Variant:
	if timeline_ui and timeline_ui.is_selecting_target:
		print("Bloqueado: Selecione um alvo primeiro")
		return null
	if hero_owner.is_dead:
		return null
	var preview = Label.new()
	preview.text = skill_data.skill_name
	preview.set_size(Vector2(100,30))
	set_drag_preview(preview)
	return {
		"skill_data": skill_data,
		"hero_owner": hero_owner
	}


func set_skill(p_skill_data: SkillData):
	self.skill_data = p_skill_data
	
func set_hero_owner(hero: Unit):
	self.hero_owner = hero
