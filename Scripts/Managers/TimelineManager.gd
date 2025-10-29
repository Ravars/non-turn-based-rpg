extends Node

# var planned_actions: Array[TimelineAction] = []
var current_time: float = 0.0
var is_paused: bool = true
var is_selecting_target: bool = false
var time_scale: float = 1
var action_awaiting_target: TimelineAction = null
signal time_updated(current_time: float)
signal tick(current_time: float, delta: float)
signal time_scale_changed(time_scale: float)
signal target_selection_changed(is_selecting: bool)

func _ready():
	LimboConsole.register_command(play_game, "timeline play", "Play the game")
	LimboConsole.register_command(pause_game, "timeline pause", "Pause the game")
	LimboConsole.register_command(set_time_scale, "timeline setscale", "Set timeline scale")

func pause_game():
	if not is_paused:
		is_paused = true
		print("Jogo Pausado")
	
func play_game():
	if is_paused:
		is_paused = false
		print("Jogo iniciado")

func _physics_process(p_delta: float) -> void:
	if is_paused:
		return
	current_time += p_delta * time_scale
	tick.emit(current_time, p_delta * time_scale)
	time_updated.emit(current_time)

func set_time_scale(p_time_scale: float):
	self.time_scale = p_time_scale
	time_scale_changed.emit(p_time_scale)

func reset_timeline():
	current_time = 0.0
	is_paused = true
	time_scale = 1
# func add_planned_action(action: TimelineAction):
# 	planned_actions.append(action)
# 	planned_actions.sort_custom(func(a: TimelineAction,b: TimelineAction): return a.get_execution_time() < b.get_execution_time())
# 	print("Ação '{skill_name}' adicionada à timeline em {1} para {0}.".format({"skill_name": action.skill_data.skill_name, 1: action.start_time, 0:action.caster.name}))

func start_target_selection(action: TimelineAction):
	if is_selecting_target:
		return
	print("UI: Entrando em modo de seleção de alvo para a skill: {skill_name}".format({"skill_name": action.skill_data.skill_name}))
	is_selecting_target = true
	action_awaiting_target = action
	target_selection_changed.emit(true)

func stop_target_selection():
	if not is_selecting_target:
		is_selecting_target = false
		action_awaiting_target = null
		target_selection_changed.emit(false)

func confirm_target_form_action(target_unit: Unit):
	if not is_selecting_target or action_awaiting_target == null:
		return
	print("UI: Unidade '{unit_name}' selecionada como alvo!".format({"unit_name": target_unit.name}))
	action_awaiting_target.target = target_unit
	is_selecting_target = false
	action_awaiting_target = null
	target_selection_changed.emit(false)
