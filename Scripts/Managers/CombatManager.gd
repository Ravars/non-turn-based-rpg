extends Node2D

enum DamageType {
	PHYSICAL,
	FIRE,
	POISON,
	LIGHTNING,
	HOLY,
}

signal battle_initialized(heroes: Array)

var active_heroes: Array[Unit] = []
var active_enemies: Array[Unit] = []

func _ready() -> void:
	pass
	#TimelineManager.tick.connect(process_action)

func execute_action(action: TimelineAction):
	if not is_instance_valid(action):
		print("Ação cancelada. Alvo inválido.")
		return
	
	var base_damage: int = action.skill_data.damage
	var final_strength = action.caster.get_final_strength()
	var total_damage = base_damage + (final_strength * 2)
	if total_damage > 0:
		action.target.take_damage(total_damage, action.skill_data.damage_type)

	for effect in action.skill_data.status_effects:
		action.target.apply_status_effect(effect)

func initialize_battle(hero_data: Array[PlayerCharacterData], enemy_data: Array[CharacterArchetype], setup_node: BattleSetup) -> void:
	active_heroes.clear()
	active_enemies.clear()
	
	for i in range(hero_data.size()):
		var position_in_lane = i % 2
		var spawn_point = setup_node.player_spawn_points[position_in_lane]
		var occupant_count = setup_node.hero_lane_occupancy.get(spawn_point, 0)
		var offset = Vector2(occupant_count * setup_node.lane_offset, 0)
		var archetype = hero_data[i].archetype
		var new_hero: Unit = archetype.scene.instantiate()
		var lane_pos_enum
		if position_in_lane == 0:
			lane_pos_enum = Unit.LanePosition.FRONT
		else:
			lane_pos_enum = Unit.LanePosition.BACK


		new_hero.initialize(archetype, lane_pos_enum, hero_data[i].current_hp)
		spawn_point.add_child(new_hero)
		new_hero.add_to_group("heroes")
		new_hero.global_position = spawn_point.global_position + offset
		active_heroes.append(new_hero)
		setup_node.hero_lane_occupancy[spawn_point] = occupant_count + 1
		
	for i in range(enemy_data.size()):
		var position_in_lane = i % 2
		var spawn_point = setup_node.enemie_spawn_points[position_in_lane]
		var occupant_count = setup_node.enemy_lane_occupancy.get(spawn_point, 0)
		var offset = Vector2(occupant_count * setup_node.lane_offset, 0)
		var archetype = enemy_data[i]
		var lane_pos_enum
		if position_in_lane == 0:
			lane_pos_enum = Unit.LanePosition.FRONT
		else:
			lane_pos_enum = Unit.LanePosition.BACK
		var new_enemy: Unit = enemy_data[i].scene.instantiate()
		new_enemy.is_enemy = true
		new_enemy.initialize(archetype, lane_pos_enum)
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

func on_unit_died(dead_unit: Unit):
	if dead_unit.is_enemy:
		active_enemies.erase(dead_unit)
	else:
		active_heroes.erase(dead_unit)
	
	if active_heroes.is_empty():
		print("COMBATE TERMINOU: Derrota!")
		GameManager.combat_ended.emit(false)
	elif active_enemies.is_empty():
		print("COMBATE TERMINOU: Vitoria!")
		GameManager.combat_ended.emit(true)
	
# func get_valid_targets_for(action: TimelineAction) -> Array[Unit]:
# 	var caster = action.caster
# 	var skill = action.skill_data
# 	var valid_targets: Array[Unit] = []

# 	var enemy_team = active_heroes if caster.is_enemy else active_enemies
# 	if skill.range_rule == SkillData.RangeRule.MELEE:
# 		if caster.current_lane_position != Unit.LanePosition.FRONT