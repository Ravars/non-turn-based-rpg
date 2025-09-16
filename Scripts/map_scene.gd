extends Node2D
func _on_combat_button_pressed():
	var encounter_enemies: Array[CharacterArchetype] = [
		preload("res://Resources/Archetypes/BasicGoblin.tres"),
		preload("res://Resources/Archetypes/BasicGoblin.tres")
	]
	GameManager.start_combat(encounter_enemies)
