extends Control

var selected_char: Unit

func _ready():
	print("Ready TimelineUI")
	CombatManager.battle_initialized.connect(instantiate_button)
	$ColorRect3/VBoxContainer/PlayButton.connect("pressed", Callable(self, "_on_play_button_pressed"))
	$ColorRect3/VBoxContainer/PauseButton.connect("pressed", Callable(self, "_on_pause_button_pressed"))
	

func instantiate_button(characters: Array[Unit]) -> void:
	print("Intantitate")
	var buttons_container = $ColorRect/Buttons_Container
	print(characters.size())
	for i in range(characters.size()):
		var botao = Button.new()
		botao.text = characters[i].name
		botao.name = characters[i].name
		botao.connect("pressed", Callable(self, "_on_button_press").bind(characters[i]))
		buttons_container.add_child(botao)	

func _on_button_press(unidade: Unit):
	selected_char = unidade
	render_skill()
	print(unidade.name)

func _on_play_button_pressed():
	TimelineManager.play_game()
	
func _on_pause_button_pressed():
	TimelineManager.pause_game()
	
func render_skill():
	print("Render")
	var skills_container = $ColorRect2/Buttons_Skills_Container
	for child in skills_container.get_children():
		child.queue_free()
		
	for skill in selected_char.skills:
		var botao = Ability_button.new()
		botao.text = skill.skill_name
		botao.set_skill(skill)
		botao.set_hero_owner(selected_char)
		botao.connect("pressed", Callable(self, "_on_skill_pressed").bind(skill))
		skills_container.add_child(botao)

func _on_skill_pressed(skill: SkillData):
	print(skill.skill_name)
