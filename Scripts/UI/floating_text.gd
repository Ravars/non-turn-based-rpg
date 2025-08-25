extends Node
class_name FloatingText

@onready var animation_player = $AnimationPlayer
@onready var label = $TextLabel

func start(text_to_display: String):
	label.text = text_to_display
	animation_player.play("float_and_fade")
