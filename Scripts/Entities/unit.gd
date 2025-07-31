extends Node2D
class_name Unit

signal unit_died(Unit)
signal unit_clicked(unit: Unit)

const AIController = preload("res://Scripts/Controllers/EnemyAIController.gd")

@export var is_enemy := false

var max_hp: int = 100
var current_hp: int = 100
var timeline_id: int = 0
var is_dead: bool = false
@export var characterStats: CharacterStats
@export var skills: Array[SkillData] = []



func _ready() -> void:
	print("UNit ready")
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

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		unit_clicked.emit(self)
		get_viewport().set_input_as_handled()

func take_damage(amount: int):
	current_hp = max(0, current_hp-amount)
	$Label.text = str(current_hp)
	print("{0} sofreu {1} de dano, vida atual: {2}".format({0: name,1: amount, 2: current_hp}))
	if current_hp <= 0:
		print("{0} foi derrotado!".format({0:name}))
		is_dead = true
		unit_died.emit(self)
