extends Node2D
class_name Unit

signal unit_died(Unit)
signal unit_clicked(unit: Unit)
# signal action_executed(action: TimelineAction)
# signal action_started(action: TimelineAction)
# signal action_tick(percent: float)
signal damage_taken(amount: float, position: Vector2, damage_type: CombatManager.DamageType)
signal heal_received(amount: float, position: Vector2)
# signal target_selection_requested(action: TimelineAction)
# signal action_added(action: TimelineAction)
const AIController = preload("res://Scripts/Controllers/EnemyAIController.gd")

@export var is_enemy := false

var max_hp: int = 100
var current_hp: float = 100

var timeline_id: int = 0
var is_dead: bool = false
var is_stunned: bool = false
var is_casting: bool = false
var archetype: CharacterArchetype

@export var characterStats: CharacterStats
var skills: Array[SkillData] = []
@export var active_status_effects: Dictionary = {}
var stun_texture = preload("res://Icons/busy_hourglass.png")
var action_indicator_image: Sprite2D
var current_cast_progress: float = 0.0
var current_lane_position: LanePosition




var skill_loop: Array[SkillData] = []
var execution_plan: Array = []
var plan_index: int = 0
var step_progress_timer: float = 0.0
# var current_loop_index: int = 0
# var current_cast_timer: float = 0.0
var is_loop_active: bool = false
	
var last_loop_progress: float = 0.0
var loop_progress_timer: float = 0.0

func initialize(p_archetype: CharacterArchetype, p_lane_position: LanePosition, p_current_health: float = -1.0):
	self.archetype = p_archetype
	self.current_lane_position = p_lane_position
	self.name = archetype.character_name
	self.skills = archetype.starting_skills.duplicate()
	if p_current_health < 0:
		self.current_hp = archetype.base_stats.health
	else:
		self.current_hp = p_current_health
	$Label.text = str(current_hp)
	# Cria uma área clicável programaticamente
	var clickable_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	
	if has_node("Sprite2D"):
		rectangle.size = get_node("Sprite2D").texture.get_size()
	else:
		rectangle.size = Vector2(50, 100)
	
	collision_shape.shape = rectangle
	clickable_area.add_child(collision_shape)
	add_child(clickable_area)
	
	clickable_area.input_event.connect(_on_input_event)
	if is_enemy:
		print("IsEnemy")
		var ai_node = Node.new()
		ai_node.name = "AIController"
		ai_node.set_script(AIController)
		add_child(ai_node)
	action_indicator_image = $ActionIndicator
	LoopManager.tick.connect(internal_process)

func setup_test_loop(loop_skills: Array[SkillData]):
	self.skill_loop = loop_skills
	self.is_loop_active = true
	print("'{0}' configurado com um loop de {1} habilidades.".format({0: name, 1: skill_loop.size()}))

# func internal_process(_current_time: float, delta: float):
# 	if not is_loop_active or is_dead or skill_loop.is_empty() or is_stunned: return
# 	current_cast_timer += delta
	
# 	var current_skill = skill_loop[current_loop_index]



# 	while current_cast_timer >= current_skill.cast_time:
# 		print("'{0}' executou a habilidade '{1}'".format({0: name, 1: current_skill.skill_name}))
# 		CombatManager.execute_action(self, current_skill)
# 		current_cast_timer -= current_skill.cast_time
# 		current_loop_index = (current_loop_index + 1) % skill_loop.size()
# 		current_skill = skill_loop[current_loop_index]
# 	# if current_cast_timer >= current_skill.cast_time:
# 	# 	print("'{0}' executou a habilidade '{1}'".format({0: name, 1: current_skill.skill_name}))
# 	# 	CombatManager.execute_action(self, current_skill)
# 	# 	current_cast_timer = 0
# 	# 	current_loop_index = (current_loop_index + 1) % skill_loop.size()
		
	
# 	# process_action_queue(_current_time, delta)
# 	# process_status_effect(_current_time, delta)

# func internal_process(_current_time: float, delta: float):
# 	if not is_loop_active or skill_loop.is_empty() or is_stunned or is_dead:
# 		return
# 	var loop_props = calculate_loop_properties()
# 	print(loop_props)
# 	if loop_props.total_duration <= 0: return
# 	# Salva o tempo anterior e avança o timer
# 	last_loop_progress = loop_progress_timer
# 	loop_progress_timer += delta
# 	# Verifica se o timer cruzou o ponto de conclusão de alguma habilidade
# 	var time_accumulator = 0.0
# 	for skill in skill_loop:
# 		var skill_end_time = time_accumulator + skill.cast_time
# 		# Se o tempo ANTERIOR era antes do fim e o tempo ATUAL é depois...
# 		if last_loop_progress < skill_end_time and loop_progress_timer >= skill_end_time:
# 			print("'{0}' executou '{1}' no tempo {2}".format({0: name, 1: skill.skill_name, 2: skill_end_time}))
# 			CombatManager.execute_action(self, skill)
# 		time_accumulator += skill.cast_time
# 	# "Wrap around" - faz o loop reiniciar
# 	if loop_progress_timer >= loop_props.total_duration:
# 		var time_overflow = loop_progress_timer - loop_props.total_duration
# 		loop_progress_timer = time_overflow
# 		last_loop_progress = 0.0
# 		# Re-executa a lógica para o tempo que "sobrou"
# 		internal_process(_current_time,0)

func internal_process(current_time: float, delta: float):
	if not is_loop_active or execution_plan.is_empty() or is_stunned or is_dead:
		return
	step_progress_timer += delta
	var current_step = execution_plan[plan_index]
	var current_step_duration: float
	# Determina a duração do passo atual
	if current_step.type == "cast":
		# print("CAST: {0} at {1}".format({0:current_step_duration, 1: current_time}))
		current_step_duration = current_step.skill.cast_time
	else: # "idle"
		current_step_duration = current_step.duration
		# print("Idle: {0} at {1}".format({0:current_step_duration, 1: current_time}))
	# Se o tempo progrediu além do passo atual, executa e avança
	if step_progress_timer >= current_step_duration:
		# Se o passo que terminou era um cast, executa a ação
		if current_step.type == "cast":
			print("Cast: {0} at {1}".format({0: current_step.skill.skill_name, 1: current_time}))
			var targets = CombatManager.get_automatic_targets(self, current_step.skill)
			CombatManager.execute_action(self, current_step.skill, targets)
		# Avança para o próximo passo no plano
		plan_index = (plan_index + 1) % execution_plan.size()
		# Reseta o timer, carregando o tempo que "sobrou"
		step_progress_timer -= current_step_duration
	


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		unit_clicked.emit(self)
		get_viewport().set_input_as_handled()

func take_damage(amount: float, damage_type: CombatManager.DamageType):
	current_hp = max(0, current_hp-amount)
	$Label.text = str(current_hp)
	print("DAMAGE {0} sofreu {1} de dano, vida atual: {2}".format({0: name,1: amount, 2: current_hp}))
	damage_taken.emit(amount, self.global_position, damage_type)
	if current_hp <= 0:
		_die()

func heal(amount: float):
	current_hp = min(current_hp + amount, max_hp)
	$Label.text = str(current_hp)
	heal_received.emit(amount, self.global_position)
	print("HEAL {0} recebeu {1} de cura, vida atual: {2}".format({0: name,1: amount, 2: current_hp}))
	
func _die():
	if is_dead: return
	print("{0} foi derrotado!".format({0:name}))
	is_dead = true
	unit_died.emit(self)
	modulate = Color(0.5, 0.5, 0.5)
	CombatManager.on_unit_died(self)

func apply_status_effect(effect:StatusEffect):
	print("EFFECT {0} recebeu o efeito {1}".format({0: name, 1: effect.effect_name}))
	active_status_effects[effect] = {
		"time_left": effect.duration,
		"tick_timer": 0.0
	}
	
	# TODO: Apply instant effects
	if effect.type == StatusEffect.EffectType.STUN:
		is_stunned = true
		action_indicator_image.texture = stun_texture
		print("EFFECT {0} está ATORDOADO".format({0: name}))

func process_status_effect(_current_time: float, delta: float) -> void:
	if is_dead or active_status_effects.is_empty(): return
	
	var effects_to_remove = []
	for effect: StatusEffect in active_status_effects:
		var effect_data = active_status_effects[effect]
		effect_data.time_left -= delta
		
		if effect_data.time_left <= 0:
			effects_to_remove.append(effect)
			continue

		match effect.type:
			StatusEffect.EffectType.STUN:
				pass
			StatusEffect.EffectType.DAMAGE_OVER_TIME:
				effect_data.tick_timer += delta
				if effect_data.tick_timer >= 1.0:
					print("EFFECT! {0} sofre {1} de dano do efeito {2}".format({0: name, 1: effect.value, 2: effect.effect_name}))
					take_damage(effect.value, CombatManager.DamageType.POISON)
					effect_data.tick_timer -= 1.0
				pass
			StatusEffect.EffectType.HEAL_OVER_TIME:
				pass
			StatusEffect.EffectType.STAT_MODIFIER:
				pass
			
	for effect in effects_to_remove:
		_on_effect_expired(effect)
		active_status_effects.erase(effect)
		action_indicator_image.texture = null
		print("EFFECT '{0}' expirou em {1}".format({"0": effect.effect_name, "1": name}))
	# TODO: revert effects

func _on_effect_expired(effect: StatusEffect):
	if effect.type == StatusEffect.EffectType.STUN:
		is_stunned = false
		print("EFFECT {0} NÃO está mais atordoado.".format({0: name}))

func get_final_strength() -> int:
	var final_value = float(characterStats.strength)
	for effect: StatusEffect in active_status_effects:
		if effect.type == StatusEffect.EffectType.STAT_MODIFIER and effect.target_stat == StatusEffect.Stat.STRENGTH:
			if effect.is_percentage:
				final_value *= (1.0 + effect.value/100)
			else:
				final_value += effect.value
	return max(0, int(final_value))

func get_final_intelligence() -> int:
	return characterStats.intelligence

enum LanePosition {
	FRONT,
	BACK
}

func recalculate_execution_plan():
	execution_plan.clear()
	if skill_loop.is_empty():
		return
	var cooldown_timers: Dictionary = {} # Simula os cooldowns durante o planejamento
	# Simula um ciclo completo para determinar a ordem e as pausas
	for i in range(skill_loop.size()):
		var skill_to_cast = skill_loop[i]
		var current_cooldown_keys = cooldown_timers.keys()
		# 1. Verifica se a skill precisa de uma pausa para o cooldown
		if cooldown_timers.has(skill_to_cast):
			var required_idle_time = cooldown_timers[skill_to_cast]
			if required_idle_time > 0:
				# Adiciona um passo de pausa ao plano
				execution_plan.append({"type": "idle", "duration": required_idle_time})
				# Avança o tempo, reduzindo todos os outros cooldowns
				
				for timer_skill in current_cooldown_keys:
					cooldown_timers[timer_skill] -= required_idle_time

		# 2. Adiciona o passo de conjuração
		execution_plan.append({"type": "cast", "skill": skill_to_cast})
		# 3. Avança o tempo pelo cast_time, reduzindo todos os cooldowns
		var cast_duration = skill_to_cast.cast_time
		for timer_skill in current_cooldown_keys:
			cooldown_timers[timer_skill] -= cast_duration
		# 4. Define o cooldown para a skill que acabamos de "conjurar"
		cooldown_timers[skill_to_cast] = skill_to_cast.cooldown
	
	var final_idle_time = 0.0
	for skill in cooldown_timers:
		var remaining_cd = cooldown_timers[skill]
		if remaining_cd > final_idle_time:
			final_idle_time = remaining_cd

	if final_idle_time > 0:
		execution_plan.append({"type": "idle", "duration": final_idle_time})
	
	# Limpa timers negativos
	var final_timers = cooldown_timers.keys()
	for skill in final_timers:
		if cooldown_timers[skill] <= 0:
			cooldown_timers.erase(skill)

	# Verifica se a última skill precisa de uma pausa para a primeira skill do próximo ciclo
	# var first_skill_of_loop = skill_loop[0]
	# if cooldown_timers.has(first_skill_of_loop):
	# 	var final_idle_time = cooldown_timers[first_skill_of_loop]
	# 	if final_idle_time > 0:
	# 		execution_plan.append({"type": "idle", "duration": final_idle_time})

	print("Novo Plano de Execução Gerado: ", execution_plan)

func add_skill_to_loop(skill_to_add: SkillData):
	if skill_loop.size() >= characterStats.focus:
		return
	skill_loop.append(skill_to_add)
	recalculate_execution_plan()

func remove_skill_from_loop(index: int):
	if index >= 0 and index < skill_loop.size():
		skill_loop.remove_at(index)
		recalculate_execution_plan()
