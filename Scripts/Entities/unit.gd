extends Node2D
class_name Unit

signal unit_died(Unit)
signal unit_clicked(unit: Unit)
signal action_executed(action: TimelineAction)
signal action_started(action: TimelineAction)
signal action_tick(percent: float)
signal damage_taken(amount: float, position: Vector2)
const AIController = preload("res://Scripts/Controllers/EnemyAIController.gd")

@export var is_enemy := false

var max_hp: int = 100
var current_hp: float = 100
var timeline_id: int = 0
var is_dead: bool = false
var is_stunned: bool = false
var is_casting: bool = false
@export var characterStats: CharacterStats
@export var skills: Array[SkillData] = []
@export var active_status_effects: Dictionary = {}
var stun_texture = preload("res://Icons/busy_hourglass.png")
var action_indicator_image: Sprite2D
var action_queue: Array[TimelineAction] = []
var current_cast_progress: float = 0.0

func _ready() -> void:
	max_hp = characterStats.health
	current_hp = max_hp
	$Label.text = str(current_hp)
	action_indicator_image = $ActionIndicator
	
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
	TimelineManager.tick.connect(internal_process)

func internal_process(_current_time: float, delta: float):
	process_action_queue(_current_time, delta)
	process_status_effect(_current_time, delta)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		unit_clicked.emit(self)
		get_viewport().set_input_as_handled()

func take_damage(amount: float):
	current_hp = max(0, current_hp-amount)
	$Label.text = str(current_hp)
	print("DAMAGE {0} sofreu {1} de dano, vida atual: {2}".format({0: name,1: amount, 2: current_hp}))
	damage_taken.emit(amount, self.global_position)
	if current_hp <= 0:
		_die()

func _die():
	print("{0} foi derrotado!".format({0:name}))
	is_dead = true
	unit_died.emit(self)
	modulate = Color(0.5, 0.5, 0.5)

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

func add_action_to_queue(action: TimelineAction):
	action_queue.append(action)
	action_queue.sort_custom(func(a: TimelineAction,b: TimelineAction): return a.start_time < b.start_time)

func process_action_queue(_current_time: float, game_delta: float) -> void:
	if is_dead or action_queue.is_empty(): return

	if is_stunned: return
	if is_casting:
		current_cast_progress += game_delta
		var current_action: TimelineAction = action_queue[0]
		
		var percent = (current_cast_progress * 100) / current_action.skill_data.cast_time
		action_tick.emit(percent)
		if current_cast_progress >= current_action.skill_data.cast_time:
			CombatManager.execute_action(current_action)
			action_executed.emit(current_action)
			action_queue.pop_front()
			is_casting = false
			current_cast_progress = 0
		return
	var next_action = action_queue[0]
	if _current_time >= next_action.start_time:
		is_casting = true
		action_started.emit(next_action)

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
					take_damage(effect.value)
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

func remove_action_from_queue(action_to_remove: TimelineAction):
	if action_queue.has(action_to_remove):
		action_queue.erase(action_to_remove)
		print("Ação '{0}' removida da fila de {1}.".format({0: action_to_remove.skill_data.skill_name, 1: name}))
	else:
		print("Ação '{0}' não encontrada na fila de {1}.".format({0: action_to_remove.skill_data.skill_name, 1: name}))
