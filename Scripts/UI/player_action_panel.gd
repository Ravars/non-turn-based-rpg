extends Control
class_name PlayerActionPanel
var selected_char: Unit
@export var ability_button_scene: PackedScene
@export var vfx_manager: VFXManager
@onready var skills_container = $ColorRect2/Buttons_Skills_Container
func _ready():
	print("Ready PlayerActionPanel")
	CombatManager.battle_initialized.connect(instantiate_button)
	$ColorRect3/VBoxContainer/PlayButton.connect("pressed", Callable(self, "_on_play_button_pressed"))
	$ColorRect3/VBoxContainer/PauseButton.connect("pressed", Callable(self, "_on_pause_button_pressed"))
	$"ColorRect4/VBoxContainer/0_1xButton".connect("pressed", Callable(self, "_on_01x_button_pressed"))
	$"ColorRect4/VBoxContainer/0_5xButton".connect("pressed", Callable(self, "_on_05x_button_pressed"))
	$"ColorRect4/VBoxContainer/1xButton".connect("pressed", Callable(self, "_on_1x_button_pressed"))
	$"ColorRect4/VBoxContainer/2xButton".connect("pressed", Callable(self, "_on_2x_button_pressed"))
	#LoopManager.target_selection_changed.connect(_on_target_selection_changed)
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
		character.damage_taken.connect(vfx_manager._on_unit_damage_taken)
		character.heal_received.connect(vfx_manager._on_unit_heal_received)
		
		# Conecta ao sinal de clique de cada unidade
		# character.unit_clicked.connect(_on_unit_clicked)
		# character.target_selection_requested.connect(_on_target_selection_requested)

	# Conecta aos inimigos também
	for enemy in CombatManager.active_enemies:
		# enemy.unit_clicked.connect(_on_unit_clicked)
		enemy.damage_taken.connect(vfx_manager._on_unit_damage_taken)

func _on_button_press(unidade: Unit):
	if LoopManager.is_selecting_target:
		print("Termine de selecionar o alvo antes")
		return
	selected_char = unidade
	render_skill()
	print(unidade.name)

func _on_play_button_pressed():
	if LoopManager.is_selecting_target:
		return
	LoopManager.play_game()
	
func _on_pause_button_pressed():
	LoopManager.pause_game()
	
func render_skill():
	var skills_container = $ColorRect2/Buttons_Skills_Container
	for child in skills_container.get_children():
		child.queue_free()
		
	for skill in selected_char.skills:
		# var botao = Ability_button.new()
		var botao = ability_button_scene.instantiate()
		botao.text = skill.skill_name
		botao.set_skill(skill)
		botao.set_hero_owner(selected_char)
		botao.timeline_ui = self
		skills_container.add_child(botao)
	_set_skill_buttons_disabled(LoopManager.is_selecting_target)

# --- Novas Funções para Seleção de Alvo ---

func setup_lane_connections(lanes_container: Node):
	for lane in lanes_container.get_children():
		if lane is TimelineLane:
			pass
			# lane.target_selection_requested.connect(_on_target_selection_requested)
			# lane.target_selection_stoped.connect(_on_target_selection_stoped)

# func _on_target_selection_requested(action: TimelineAction):
# 	LoopManager.start_target_selection(action)
	
# func _on_target_selection_stoped():
# 	LoopManager.stop_target_selection()
# func _on_unit_clicked(unit: Unit):
# 	if not LoopManager.is_selecting_target:
# 		return
# 	if LoopManager.action_awaiting_target == null:
# 		return
		
# 	# Verifica se o alvo é válido (ex: não pode curar um inimigo)
# 	# (Lógica a ser adicionada no futuro)
# 	LoopManager.confirm_target_form_action(unit)
# 	_set_skill_buttons_disabled(false)
		
func _on_2x_button_pressed():
	LoopManager.set_time_scale(2)
	pass
	
func _on_1x_button_pressed():
	LoopManager.set_time_scale(1)
	pass

func _on_05x_button_pressed():
	LoopManager.set_time_scale(0.5)
	pass

func _on_01x_button_pressed():
	LoopManager.set_time_scale(0.1)
	pass

func _set_skill_buttons_disabled(disabled: bool):
	for button in skills_container.get_children():
		if button is Button:
			button.disabled = disabled

func _on_target_selection_changed(is_selecting: bool, valid_targets: Array[Unit]):
	_set_skill_buttons_disabled(is_selecting)
	print("IS selecting: {0}".format({0:is_selecting}))
	var all_units = CombatManager.active_enemies + CombatManager.active_heroes
	if is_selecting:
		for unit:Unit in all_units:
			if valid_targets.has(unit):
				unit.modulate = Color.RED
			else:
				unit.modulate = Color(0.5,0.5,0.5,0.5)
	else:
		for unit in all_units:
			unit.modulate = Color.WHITE
