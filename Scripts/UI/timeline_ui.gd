extends Control

var selected_char: Unit

func _ready():
	CombatManager.battle_initialized.connect(instantiate_button)
	
func instantiate_button(characters: Array[Unit]) -> void:
	var buttons_container = $Buttons_Container
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

func render_skill():
	print("Render")
	var skills_container = $Buttons_Skills_Container
	for child in skills_container.get_children():
		child.queue_free()
		
	for skill in selected_char.skills:
		var botao = Button.new()
		botao.text = skill.skill_name
		botao.connect("pressed", Callable(self, "_on_skill_pressed").bind(skill))
		skills_container.add_child(botao)

func _on_skill_pressed(skill: SkillData):
	print(skill.skill_name)
