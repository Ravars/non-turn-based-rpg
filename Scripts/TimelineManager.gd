extends Node

var planned_actions: Array[TimelineCharacter] = []
var current_time: float = 0.0
var is_paused: bool = false

func _on_player_dropped_skill(timeline_id: int, skill: SkillData, caster: Node2D, target: Node2D, time: float):
	var new_action = TimelineAction.new(skill,caster,target, time)
	planned_actions[timeline_id].actions.append(new_action)
	#print(skill.print_skill_info())

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	current_time += delta / 5
	var amount_skiils: int = 0
	var actions_to_perform: Array[TimelineAction] = []
	for t in range(planned_actions.size()):
		var timeline: TimelineCharacter = planned_actions[t]
		if timeline.character.is_dead:
			continue
		amount_skiils += timeline.actions.size()
		for a in range(timeline.actions.size()-1,-1,-1):
			var action = timeline.actions[a]
			if action.caster.is_dead or action.target.is_dead:
				is_paused = true
				print("Paused due invalid target")
				return
				
			if current_time >= action.get_execution_time():
				actions_to_perform.append(action)
				timeline.actions.remove_at(a)
				
	for i in range(actions_to_perform.size()):
		var action = actions_to_perform[i]
		print("Personagem {2} executando {0} no tempo {1}".format({0: action.skill_data.skill_name, 1: current_time, 2: action.caster.name}))
		CombatManager.execute_action(action)
		
	if amount_skiils == 0:
		is_paused = true
		print("Paused")
		
	

func add_character_timeline(character: Unit) -> int:
	var new_timeline_character = TimelineCharacter.new(character)
	planned_actions.append(new_timeline_character)
	print(planned_actions.size())
	#
	if planned_actions.size() == 4:
		is_paused = false
	
	return planned_actions.size()-1
