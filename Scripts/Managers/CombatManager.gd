extends Node2D

enum DamageType {
	PHYSICAL,
	FIRE,
	POISON,
	LIGHTNING,
	HOLY,
	HEAL,
}

signal battle_initialized(heroes: Array)

var active_heroes: Array[Unit] = []
var active_enemies: Array[Unit] = []

func _ready() -> void:
	pass

func execute_action(caster: Unit, skill: SkillData, p_targets: Array[Unit] = []):
	if not is_instance_valid(caster):
		print("Ação cancelada. Caster inválido.")
		return
	
	var targets_to_hit: Array[Unit] = p_targets
	if targets_to_hit.is_empty():
		targets_to_hit = get_automatic_targets(caster, skill)

	if targets_to_hit.is_empty():
		print("Ação cancelada. Nenhum alvo válido encontrado na execução.")
		return

	print("EXECUTING ACTION: %s uses %s on %s" % [caster.name, skill.skill_name, ", ".join(targets_to_hit.map(func(t): return t.name))])
	
	var actual_targets: Array[Unit] = []
	for target in targets_to_hit:
		if is_instance_valid(target) and not target.is_dead:
			actual_targets.append(target)
	
	if actual_targets.is_empty():
		print("Ação cancelada. Todos os alvos se tornaram inválidos antes da execução.")
		return

	if skill.heal > 0:
		var total_heal = get_total_heal(caster, skill)
		if total_heal > 0:
			for target in actual_targets:
				target.heal(total_heal)
	else:
		var total_damage = get_total_damage(caster, skill)
		if total_damage > 0:
			for target in actual_targets:
				target.take_damage(total_damage, skill.damage_type)
	
	for effect in skill.status_effects:
		for target in actual_targets:
			target.apply_status_effect(effect)

func get_automatic_targets(caster: Unit, skill: SkillData) -> Array[Unit]:
	var potential_targets = get_valid_targets(caster, skill)
	
	if potential_targets.is_empty():
		return []

	match skill.target_scope:
		SkillData.TargetScope.SINGLE:
			# Prioritize lowest HP for damage, highest HP for heal
			if skill.heal > 0:
				potential_targets.sort_custom(func(a, b): return a.current_hp > b.current_hp)
			else:
				potential_targets.sort_custom(func(a, b): return a.current_hp < b.current_hp)
			return [potential_targets[0]]
		SkillData.TargetScope.ALL, SkillData.TargetScope.FRONT_LINE, SkillData.TargetScope.BACK_LINE:
			return potential_targets
	return []

func get_total_damage(caster: Unit, skill: SkillData) -> int:
	var base_damage: int = skill.damage
	var final_strength = caster.get_final_strength()
	var total_damage = base_damage + (final_strength * 2)
	return total_damage

func get_total_heal(caster: Unit, skill: SkillData) -> int:
	var base_heal: int = skill.heal
	var final_intelligence = caster.get_final_intelligence()
	var total_heal = base_heal + final_intelligence
	return total_heal

func get_valid_targets(caster: Unit, skill_data: SkillData) -> Array[Unit]:
	var potential_targets: Array[Unit] = []
	match skill_data.target_team:
		SkillData.TargetTeam.ENEMIES:
			potential_targets = active_heroes if caster.is_enemy else active_enemies
		SkillData.TargetTeam.ALLIES:
			potential_targets = active_enemies if caster.is_enemy else active_heroes
		SkillData.TargetTeam.SELF:
			potential_targets = [caster]
	
	potential_targets = potential_targets.filter(func(unit: Unit): return not unit.is_dead)

	if skill_data.range_rule == SkillData.RangeRule.MELEE:
		if caster.current_lane_position != Unit.LanePosition.FRONT:
			return []
		if skill_data.target_team == SkillData.TargetTeam.ENEMIES and has_front_line_units(potential_targets):
			potential_targets = potential_targets.filter(func(unit: Unit): 
				return unit.current_lane_position == Unit.LanePosition.FRONT
			)
	
	var preferred_targets: Array[Unit] = []
	match skill_data.target_scope:
		SkillData.TargetScope.SINGLE:
			return potential_targets
		SkillData.TargetScope.ALL:
			return potential_targets
		SkillData.TargetScope.FRONT_LINE:
			preferred_targets = potential_targets.filter(func(unit: Unit): return unit.current_lane_position == Unit.LanePosition.FRONT)
			if not preferred_targets.is_empty():
				return preferred_targets
		SkillData.TargetScope.BACK_LINE:
			preferred_targets = potential_targets.filter(func(unit: Unit): return unit.current_lane_position == Unit.LanePosition.BACK)
			if not preferred_targets.is_empty():
				return preferred_targets
	
	# Fallback for empty lanes
	if skill_data.target_scope == SkillData.TargetScope.FRONT_LINE or skill_data.target_scope == SkillData.TargetScope.BACK_LINE:
		return potential_targets

	return []

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
	
	if not active_heroes.is_empty():
		var first_hero: Unit = active_heroes[0]
		if first_hero.skills.size() >= 3:
			# var test_skills: Array[SkillData] = [first_hero.skills[0], first_hero.skills[1], first_hero.skills[2]]
			# first_hero.setup_test_loop(test_skills)
			first_hero.add_skill_to_loop(first_hero.skills[0])
			first_hero.add_skill_to_loop(first_hero.skills[1])
			first_hero.add_skill_to_loop(first_hero.skills[0])
			first_hero.is_loop_active = true

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


func has_front_line_units(potential_targets: Array[Unit]) -> bool:
	for unit in potential_targets:
		if not unit.is_dead and unit.current_lane_position == Unit.LanePosition.FRONT:
			return true
	return false
