extends PanelContainer
class_name SkillLoopItem
signal action_button_pressed(skill_data: SkillData, index: int)

@onready var label_skill_name = $HBoxContainer/Label_SkillName
@onready var button_action:Button = $HBoxContainer/Button_Action

var skill_data: SkillData
var index_in_loop: int = -1
var is_in_loop: bool = false
var idle_duration: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_action.pressed.connect(_on_button_pressed)
	if skill_data:
		label_skill_name.text = str(skill_data.skill_name)
		button_action.visible = true
		if is_in_loop:
			button_action.text = "X"
		else:
			button_action.text = "+"
	else:
		label_skill_name.text = "Ocioso (%.2f s)" % idle_duration
		button_action.visible = false

func setup(p_skill_data: SkillData, p_index: int, p_is_in_loop: bool, p_idle_duration: float):
	self.skill_data = p_skill_data
	self.index_in_loop = p_index
	self.is_in_loop = p_is_in_loop
	self.idle_duration = p_idle_duration

func _on_button_pressed():
	action_button_pressed.emit(skill_data, index_in_loop)
