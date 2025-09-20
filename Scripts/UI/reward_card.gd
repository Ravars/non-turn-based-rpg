extends Control
class_name RewardCard

signal reward_selected(skill: SkillData)
@onready var name_label:Label = $Button/VBoxContainer/SkillLabel
@onready var cast_time_label:Label =  $Button/VBoxContainer/CastTimeLabel
@onready var damage_label:Label =  $Button/VBoxContainer/DamageLabel
@onready var select_button:Button =  $Button

var skill_data: SkillData

func _ready() -> void:
	select_button.pressed.connect(_on_pressed)
	name_label.text = skill_data.skill_name
	damage_label.text = str(skill_data.damage)
	cast_time_label.text = str(skill_data.cast_time)

func setup(p_skill: SkillData):
	self.skill_data = p_skill
	


func _on_pressed():
	if skill_data:
		reward_selected.emit(skill_data)
