extends Node

enum State { IDLE, WAITING_FOR_EXECUTION, COOLDOWN }
var current_state: State = State.IDLE

var unit_owner: Unit
var cooldown_timer: float = 0.0

var pending_action: TimelineAction = null

func _ready() -> void:
	unit_owner = get_parent()
	current_state = State.COOLDOWN
	cooldown_timer = randf_range(0.5, 1.5)

func _process(delta: float) -> void:
	if unit_owner.is_dead or TimelineManager.is_paused:
		return
	match current_state:
		State.IDLE:
			decide_next_action()
		State.WAITING_FOR_EXECUTION:
			if not TimelineManager.planned_actions.has(pending_action):
				current_state = State.COOLDOWN
				cooldown_timer = randf_range(2.0, 4.0)
				pending_action = null
				print("IA {name} executou a ação e entrou em cooldown".format({"name": name}))
		State.COOLDOWN:
			cooldown_timer -= delta
			if cooldown_timer <= 0:
				current_state = State.IDLE
		
func decide_next_action():
	if unit_owner.skills.is_empty(): return
	var skill_to_use: SkillData = unit_owner.skills.pick_random()
	
	var target = CombatManager.get_random_hero_target()
	if not is_instance_valid(target): return
	
	var start_time = TimelineManager.current_time
	var new_action = TimelineAction.new(skill_to_use, unit_owner, target, start_time)
	
	TimelineManager.add_planned_action(new_action)
	
	pending_action = new_action
	current_state = State.WAITING_FOR_EXECUTION
	print("IA: {name} planejou usar {skill}".format({"name": name, "skill": skill_to_use.skill_name}))
