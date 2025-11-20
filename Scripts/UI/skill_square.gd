extends PanelContainer

@onready var skill_name_label = $VBoxContainer/SkillNameLabel
@onready var cast_time_label = $VBoxContainer/CastTimeLabel
var skill: SkillData
func setup(p_skill: SkillData):
	self.skill = p_skill

func _ready() -> void:
	skill_name_label.text = skill.skill_name
	cast_time_label.text = "Cast Time: " + str(skill.cast_time)
	
	var square_size = skill.cast_time * 40 # Adjust this multiplier for proper scaling
	custom_minimum_size = Vector2(square_size, square_size)
