extends Node2D
class_name Unit

signal unit_died(Unit)
signal unit_clicked(unit: Unit)

const AIController = preload("res://Scripts/Controllers/EnemyAIController.gd")

@export var is_enemy := false

var max_hp: int = 100
var current_hp: float = 100
var timeline_id: int = 0
var is_dead: bool = false
var is_stunned: bool = false
@export var characterStats: CharacterStats
@export var skills: Array[SkillData] = []
@export var active_status_effects: Dictionary = {}


func _ready() -> void:
	max_hp = characterStats.health
	current_hp = max_hp
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
	TimelineManager.tick.connect(process_status_effect)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		unit_clicked.emit(self)
		get_viewport().set_input_as_handled()

func take_damage(amount: float):
	current_hp = max(0, current_hp-amount)
	$Label.text = str(current_hp)
	print("DAMAGE {0} sofreu {1} de dano, vida atual: {2}".format({0: name,1: amount, 2: current_hp}))
	if current_hp <= 0:
		_die()

func take_damage_over_time(amount: float):
	current_hp = max(0, current_hp-amount)
	$Label.text = str(current_hp)
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
				print("")
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
		print("EFFECT '{0}' expirou em {1}".format({"0": effect.effect_name, "1": name}))
	# TODO: revert effects

func _on_effect_expired(effect: StatusEffect):
	if effect.type == StatusEffect.EffectType.STUN:
		is_stunned = false
		print("EFFECT {0} NÃO está mais atordoado.".format({0: name}))
