extends GraphNode

signal map_node_clicked(node_data: Dictionary, map_node: GraphNode, node_pos: Vector2i)

var node_data: Dictionary
var node_pos: Vector2i

func setup(_node_data: Dictionary, _node_pos: Vector2i):
	self.node_data = _node_data
	self.node_pos = _node_pos
	$Label.text = MapGenerator.NodeType.keys()[node_data.type]

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		map_node_clicked.emit(node_data, self, node_pos)
