extends RefCounted
class_name TimelineCharacter

var character: Unit
var actions: Array[TimelineAction] = []

func _init(p_character: Unit) -> void:
	self.character = p_character
