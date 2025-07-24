extends Node2D
class_name Unit

signal unit_died(Unit)
#signal unit_ready(Unit)

@export var is_enemy := false

var max_hp: int = 100
var current_hp: int = 100
var timeline_id: int = 0
var is_dead: bool = false
@export var characterStats: CharacterStats
@export var skills: Array[SkillData] = []

# A timeline interna para esta unidade
#var action_timeline: Array = []

func _ready() -> void:
	max_hp = characterStats.health
	current_hp = max_hp
	$Label.text = str(current_hp)
	
	#For testing only
	#timeline_id = TimelineManager.add_character_timeline(self)
	#var time: int = 0
	#
	#for i in range(skills.size()):
		#var hero = get_tree().get_first_node_in_group("heroes")
		#var enemie = get_tree().get_first_node_in_group("enemies")
		#print("{0} Time: {1}".format({0:name, 1: time}))
		#if is_enemy:
			#TimelineManager._on_player_dropped_skill(timeline_id, skills[i], self, hero, time)	
		#else:
			#TimelineManager._on_player_dropped_skill(timeline_id, skills[i], self, enemie, time)
		#
		#time += skills[i].calculate_skill_total_time()
	
	#print(TimelineManager.planned_actions)

func take_damage(amount: int):
	current_hp = max(0, current_hp-amount)
	$Label.text = str(current_hp)
	print("{0} sofreu {1} de dano, vida atual: {2}".format({0: name,1: amount, 2: current_hp}))
	if current_hp <= 0:
		print("{0} foi derrotado!".format({0:name}))
		is_dead = true
		unit_died.emit(self)

## Adiciona uma ação à timeline interna da unidade
#func add_action(action_data: Dictionary):
	## No futuro, podemos adicionar validações aqui
	#action_timeline.append(action_data)
	#print(name, " adicionou a ação: ", action_data["ability_name"])
#
## Limpa todas as ações da timeline
#func clear_timeline():
	#action_timeline.clear()
#
## Permite que outros scripts leiam a timeline de forma segura
#func get_action_timeline() -> Array:
	#return action_timeline
