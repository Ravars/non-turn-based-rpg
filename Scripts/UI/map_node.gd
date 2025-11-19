extends GraphNode

signal map_node_clicked(node_data: Dictionary)

var node_data: Dictionary

func setup(_node_data: Dictionary):
	self.node_data = _node_data
	$Label.text = MapGenerator.NodeType.keys()[node_data.type]

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		map_node_clicked.emit(node_data)
