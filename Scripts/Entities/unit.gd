extends Node2D
class_name Unit

signal unit_died(Unit)
signal unit_clicked(unit: Unit)

@export var is_enemy := false

var max_hp: int = 100
var current_hp: int = 100
var timeline_id: int = 0
var is_dead: bool = false
@export var characterStats: CharacterStats
@export var skills: Array[SkillData] = []

func _ready() -> void:
	max_hp = characterStats.health
	current_hp = max_hp
	$Label.text = str(current_hp)
	
	# Cria uma área clicável programaticamente
	var clickable_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	
	# Tenta usar o tamanho de um nó de Sprite2D se existir
	if has_node("Sprite2D"):
		rectangle.size = get_node("Sprite2D").texture.get_size()
	else:
		rectangle.size = Vector2(50, 100) # Tamanho padrão
	
	collision_shape.shape = rectangle
	clickable_area.add_child(collision_shape)
	add_child(clickable_area)
	
	# Conecta o sinal de input da área criada à nossa função de clique
	clickable_area.input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		unit_clicked.emit(self)
		get_viewport().set_input_as_handled() # Impede que o clique se propague mais

func take_damage(amount: int):
	current_hp = max(0, current_hp-amount)
	$Label.text = str(current_hp)
	print("{0} sofreu {1} de dano, vida atual: {2}".format({0: name,1: amount, 2: current_hp}))
	if current_hp <= 0:
		print("{0} foi derrotado!".format({0:name}))
		is_dead = true
		unit_died.emit(self)
