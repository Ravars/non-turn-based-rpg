extends Control

var selected_char: Unit
var action_awaiting_target: TimelineAction = null

func _ready():
	print("Ready TimelineUI")
	CombatManager.battle_initialized.connect(instantiate_button)
	$ColorRect3/VBoxContainer/PlayButton.connect("pressed", Callable(self, "_on_play_button_pressed"))
	$ColorRect3/VBoxContainer/PauseButton.connect("pressed", Callable(self, "_on_pause_button_pressed"))
	
	# Conecta ao sinal da lane (isso precisa ser feito depois que as lanes são criadas)
	# Vamos mover essa lógica para _on_battle_initialized

func instantiate_button(characters: Array[Unit]) -> void:
	print("Instantiate UI Buttons")
	var buttons_container = $ColorRect/Buttons_Container
	for child in buttons_container.get_children():
		child.queue_free()
	
	for character in characters:
		var botao = Button.new()
		botao.text = character.name
		botao.name = character.name
		botao.connect("pressed", Callable(self, "_on_button_press").bind(character))
		buttons_container.add_child(botao)
		
		# Conecta ao sinal de clique de cada unidade
		character.unit_clicked.connect(_on_unit_clicked)

	# Conecta aos inimigos também
	for enemy in CombatManager.active_enemies:
		enemy.unit_clicked.connect(_on_unit_clicked)

func _on_button_press(unidade: Unit):
	selected_char = unidade
	render_skill()
	print(unidade.name)

func _on_play_button_pressed():
	TimelineManager.play_game()
	
func _on_pause_button_pressed():
	TimelineManager.pause_game()
	
func render_skill():
	var skills_container = $ColorRect2/Buttons_Skills_Container
	for child in skills_container.get_children():
		child.queue_free()
		
	for skill in selected_char.skills:
		var botao = Ability_button.new()
		botao.text = skill.skill_name
		botao.set_skill(skill)
		botao.set_hero_owner(selected_char)
		skills_container.add_child(botao)

# --- Novas Funções para Seleção de Alvo ---

func setup_lane_connections(lanes_container: Node):
	for lane in lanes_container.get_children():
		if lane is TimelineLane:
			lane.target_selection_requested.connect(_on_target_selection_requested)

func _on_target_selection_requested(action: TimelineAction):
	print("UI: Entrando em modo de seleção de alvo para a skill: {skill_name}".format({"skill_name": action.skill_data.skill_name}))
	action_awaiting_target = action
	# Feedback visual: pode adicionar um brilho nos inimigos aqui.
	for enemy in CombatManager.active_enemies:
		enemy.modulate = Color.RED # Exemplo de destaque

func _on_unit_clicked(unit: Unit):
	# Se não estamos esperando por um alvo, o clique não faz nada de especial aqui.
	if action_awaiting_target == null:
		return
		
	# Verifica se o alvo é válido (ex: não pode curar um inimigo)
	# (Lógica a ser adicionada no futuro)
	
	print("UI: Unidade '{unit_name}' selecionada como alvo!".format({"unit_name": unit.name}))
	action_awaiting_target.target = unit
	
	# Reseta o estado e o feedback visual
	action_awaiting_target = null
	for enemy in CombatManager.active_enemies:
		enemy.modulate = Color.WHITE # Remove o destaque
