extends Panel
class_name TimelineActionBlock

signal removed(action: TimelineAction)
signal target_changed(action: TimelineAction)

var action_data: TimelineAction

@onready var skill_name_label = $SkillName

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

func setup_block(action: TimelineAction, pixels_per_second: float)	:
	self.action_data = action
	$SkillName.text = action.skill_data.skill_name
	
	var block_width = action.skill_data.cast_time * pixels_per_second
	var block_height = 30
	custom_minimum_size = Vector2(block_width, block_height)
	self_modulate = Color.SKY_BLUE

func _on_gui_input(event:  InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				print("Bloco de ação clicado Left: {0}".format({0: action_data.skill_data.skill_name}))
			elif  event.button_index == MOUSE_BUTTON_RIGHT:
				print("Bloco de ação clicado Right: {0}".format({0: action_data.skill_data.skill_name}))
				removed.emit(action_data)
				get_viewport().set_input_as_handled()
