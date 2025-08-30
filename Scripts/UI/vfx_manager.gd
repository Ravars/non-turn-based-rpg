extends Node
class_name VFXManager

@export var floating_text_scene: PackedScene

func _on_unit_damage_taken(amount: float, position: Vector2, damage_type: CombatManager.DamageType):
	if not floating_text_scene:
		print("ERROR VFXManager: text not asigned")
	var floating_text: FloatingText = floating_text_scene.instantiate()
	add_child(floating_text)
	floating_text.global_position = position
	floating_text.start(str(snapped(amount, 0.1)), damage_type)
