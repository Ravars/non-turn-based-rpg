extends Control

func _on_RestartButton_pressed():
	GameManager.start_new_run(GameManager.get_available_hero_archetype())
