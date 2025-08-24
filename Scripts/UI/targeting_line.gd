extends Line2D
class_name TargetingLine
func _ready() -> void:
	visible = false
	
func update_and_show_line(start_pos: Vector2, end_pos: Vector2) -> void:
	clear_points()
	points = [to_local(start_pos), to_local(end_pos)]
	visible = true

func clear_line():
	visible = false
