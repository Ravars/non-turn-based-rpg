extends Node

# var planned_actions: Array[TimelineAction] = []
var current_time: float = 0.0
var is_paused: bool = true
var time_scale: float = 1
signal time_updated(current_time: float)
signal tick(current_time: float, delta: float)
signal time_scale_changed(time_scale: float)

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
