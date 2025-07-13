@tool
extends Button

@export var ability_name: String
@export var damage: int
@export var cast_time: float
@export var recovery_time: float

func _ready():
	var label = $Label
	label.text = ability_name
	


func _get_drag_data(at_position: Vector2) -> Variant:
	var preview = Label.new()
	preview.text = ability_name
	print(at_position)
	set_drag_preview(preview)
	return {
		"ability_name": ability_name,
		"damage": damage,
		"cast_time": cast_time,
		"recovery_time": recovery_time
	}
