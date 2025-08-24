extends Panel
class_name TimelineActionBlock

signal removed(action: TimelineAction)
signal target_changed(action: TimelineAction)
signal show_target_line(start_pos: Vector2, end_pos: Vector2)
signal hide_target_line()

var action_data: TimelineAction

@onready var skill_name_label = $SkillName

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

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

func _on_mouse_entered():
	if is_instance_valid(action_data.target):
		var start_pos = global_position + size / 2
		var end_pos = action_data.target.global_position
		show_target_line.emit(start_pos, end_pos)
	
func _on_mouse_exited():
	hide_target_line.emit()
