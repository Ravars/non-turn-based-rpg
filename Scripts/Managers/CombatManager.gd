extends Node2D

signal battle_initialized(heroes: Array)

var active_heroes: Array[Unit] = []
var active_enemies: Array[Unit] = []

func execute_action(action: TimelineAction):
	if not is_instance_valid(action):
		print("Ação cancelada. Alvo inválido.")
		return
	var damage_amount: int = action.skill_data.damage
	action.target.take_damage(damage_amount)

func process_action(current_time: float):
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
		new_enemy.add_to_group("enemies")
		spawn_point.add_child(new_enemy)
		new_enemy.global_position = spawn_point.global_position + offset
		active_enemies.append(new_enemy)
		setup_node.enemy_lane_occupancy[spawn_point] = occupant_count + 1
	print("Emit")	
	battle_initialized.emit(active_heroes)

#
#@onready var player_lanes = $PlayerLanes
#@onready var enemy_lanes = $EnemyLanes
#
#var combat_active := false
#var current_time := 0.0
#
## Exemplo de dados de habilidade.
#var simple_attack = {
	#"ability_name": "Ataque Básico",
	#"cast_time": 1.0,
	#"recovery_time": 0.5,
	#"damage": 10
#}
#
#func _ready():
	#call_deferred("setup_enemies")
	## Inicia o combate automaticamente para teste
	#start_combat()
#
#func _process(delta):
	#if not combat_active:
		#return
	#
	#current_time += delta
	#process_timelines()
#
#func setup_enemies():
	#print("Configurando inimigos...")
	#for i in range(enemy_lanes.get_child_count()):
		#var lane = enemy_lanes.get_child(i)
		#if lane.has_node("UnitPosition"):
			#var unit_position = lane.get_node("UnitPosition")
			#if unit_position.get_child_count() > 0:
				#var enemy_unit = unit_position.get_child(0)
				#if enemy_unit.has_method("add_action"):
					## Adiciona uma ação de exemplo à timeline do inimigo
					#var action_data = {
						#"start_time": 1.0, # Inimigos começam suas ações após 1 segundo
						#"end_time": 1.0 + simple_attack["cast_time"] + simple_attack["recovery_time"],
						#"details": simple_attack,
						#"owner": enemy_unit,
						#"target_lane_index": i
					#}
					#enemy_unit.add_action(action_data)
#
#func start_combat():
	#combat_active = true
	#print("Combate iniciado!")
#
#func process_timelines():
	## Processa as ações dos jogadores
	#for i in range(player_lanes.get_child_count()):
		#var lane = player_lanes.get_child(i)
		#process_unit_in_lane(lane, i, false)
#
	## Processa as ações dos inimigos
	#for i in range(enemy_lanes.get_child_count()):
		#var lane = enemy_lanes.get_child(i)
		#process_unit_in_lane(lane, i, true)
#
#func process_unit_in_lane(lane, lane_index, is_enemy):
	#if not lane.has_node("UnitPosition"): return
	#var unit_position = lane.get_node("UnitPosition")
	#if unit_position.get_child_count() == 0: return
	#
	#var unit = unit_position.get_child(0)
	#if not unit.has_method("get_action_timeline"): return # Supondo que teremos um getter
	#
	#var actions_to_remove = []
	#for action in unit.action_timeline:
		#if current_time >= action["start_time"]:
			#execute_action(action)
			#actions_to_remove.append(action)
			#
	#for action in actions_to_remove:
		#unit.action_timeline.erase(action)
#
#func execute_action(action_data):
	#print(action_data["owner"].name, " executa ", action_data["details"]["ability_name"])
	#
	#var target_lanes = player_lanes if action_data["owner"].is_enemy else enemy_lanes
	#var target_lane_index = action_data["target_lane_index"]
	#
	#if target_lane_index >= target_lanes.get_child_count(): return
	#
	#var target_lane = target_lanes.get_child(target_lane_index)
	#if not target_lane.has_node("UnitPosition"): return
	#var target_position = target_lane.get_node("UnitPosition")
	#if target_position.get_child_count() == 0: return
		#
	#var target_unit = target_position.get_child(0)
	#if target_unit.has_method("take_damage"):
		#var damage = action_data["details"]["damage"]
		#target_unit.take_damage(damage)
		#print(target_unit.name, " recebeu ", damage, " de dano.")
#
## Precisamos adicionar esta função em unit.gd para que o CombatManager possa ler a timeline
## func get_action_timeline():
##     return action_timeline
