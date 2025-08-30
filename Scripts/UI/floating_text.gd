extends Node
class_name FloatingText

@onready var animation_player = $AnimationPlayer
@onready var label: Label = $TextLabel

func start(text_to_display: String, damage_type: CombatManager.DamageType):
	label.text = text_to_display
	var color = Color.WHITE
	match damage_type:
		CombatManager.DamageType.PHYSICAL:
			color = Color.WHITE
		CombatManager.DamageType.FIRE:
			color = Color.ORANGE_RED
		CombatManager.DamageType.POISON:
			color = Color.SPRING_GREEN
		CombatManager.DamageType.LIGHTNING:
			color = Color.SKY_BLUE
		CombatManager.DamageType.HOLY:
			color = Color.GOLD
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	animation_player.play("float_and_fade")
