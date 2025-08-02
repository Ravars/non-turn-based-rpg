extends Node2D

signal battle_initialized(heroes: Array)

var active_heroes: Array[Unit] = []
var active_enemies: Array[Unit] = []

func _ready() -> void:
	TimelineManager.tick.connect(process_action)

func execute_action(action: TimelineAction):
	if not is_instance_valid(action):
		print("Ação cancelada. Alvo inválido.")
		return
	
	var damage_amount: int = action.skill_data.damage
	if damage_amount > 0:
		action.target.take_damage(damage_amount)

	for effect in action.skill_data.status_effects:
		action.target.apply_status_effect(effect)

func process_action(current_time: float, _delta: float):
	var timelineActions: Array[TimelineAction] = TimelineManager.planned_actions
	var actions_to_perform: Array[TimelineAction] = []
	for i in range(timelineActions.size()-1,-1,-1):
		var action = timelineActions[i]
		if action.caster.is_dead:
			continue
		if current_time >= action.get_execution_time():
			if not action.target.is_dead:
				actions_to_perform.append(action)
			else:
				print("Ação {0} cancelada por alvo inválido.".format([action.skill_data.skill_name]))
			timelineActions.remove_at(i)

	for action_to_perform in actions_to_perform:
		print("Personagem {caster_name} executando {skill_name} no tempo {time}".format({"caster_name": action_to_perform.caster.name, "skill_name": action_to_perform.skill_data.skill_name, "time": current_time}))
		execute_action(action_to_perform)
		
	if timelineActions.size() == 0:
		TimelineManager.pause_game()

func initialize_battle(hero_data: Array[PackedScene], enemy_data: Array[PackedScene], setup_node: BattleSetup) -> void:
	active_heroes.clear()
	active_enemies.clear()
	
	for i in range(hero_data.size()):
		var spawn_point = setup_node.player_spawn_points[randi() % setup_node.player_spawn_points.size()]
		var occupant_count = setup_node.hero_lane_occupancy.get(spawn_point, 0)
		var offset = Vector2(occupant_count * setup_node.lane_offset, 0)
		
		var new_hero: Unit = hero_data[i].instantiate()
		spawn_point.add_child(new_hero)
		new_hero.add_to_group("heroes")
		new_hero.global_position = spawn_point.global_position + offset
		active_heroes.append(new_hero)
		setup_node.hero_lane_occupancy[spawn_point] = occupant_count + 1
		
	for i in range(enemy_data.size()):
		var spawn_point = setup_node.enemie_spawn_points[randi() % setup_node.enemie_spawn_points.size()]
		var occupant_count = setup_node.enemy_lane_occupancy.get(spawn_point, 0)
		var offset = Vector2(occupant_count * setup_node.lane_offset, 0)
		
		var new_enemy: Unit = enemy_data[i].instantiate()
		new_enemy.is_enemy = true
		new_enemy.add_to_group("enemies")
		spawn_point.add_child(new_enemy)
		new_enemy.global_position = spawn_point.global_position + offset
		
		active_enemies.append(new_enemy)
		setup_node.enemy_lane_occupancy[spawn_point] = occupant_count + 1
	battle_initialized.emit(active_heroes)

func get_random_hero_target():
	if active_heroes.is_empty(): return
	var alive_heroes = []
	for hero in active_heroes:
		if not hero.is_dead:
			alive_heroes.append(hero)
	if alive_heroes.is_empty(): return null
	return alive_heroes.pick_random()
