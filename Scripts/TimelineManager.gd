extends Node

# var characters: Array[TimelineCharacter] = []
var planned_actions: Array[TimelineAction] = []
var current_time: float = 0.0
var is_paused: bool = false

func pause_game():
	if not is_paused:
		is_paused = true
		print("Jogo Pausado")
	
func play_game():
	if is_paused:
		is_paused = false
		print("Jogo iniciado")

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	current_time += delta / 5
	CombatManager.process_action(current_time)

func add_planed_action(action: TimelineAction):
	planned_actions.append(action)
	planned_actions.sort_custom(func(a: TimelineAction,b: TimelineAction): return a.get_execution_time() < b.get_execution_time())
	print("Ação '{skill_name}' adicionada à timeline.".format({"skill_name": action.skill_data.skill_name}))
