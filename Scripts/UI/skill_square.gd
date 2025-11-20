extends PanelContainer

@onready var skill_name_label = $HBoxContainer/SkillNameLabel
@onready var cast_time_label = $HBoxContainer/CastTimeLabel
var skill: SkillData
func setup(p_skill: SkillData):
	self.skill = p_skill
	
func _ready() -> void:
	skill_name_label.text = skill.skill_name
	cast_time_label.text = str(skill.cast_time)
	var square_size = skill.cast_time * 40 # Adjust this multiplier for proper scaling
	custom_minimum_size = Vector2(square_size, 40)
