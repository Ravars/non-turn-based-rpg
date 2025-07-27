extends Panel
class_name TimelineLane
var hero_owner: Unit

# --- Variáveis de Configuração ---
@export var pixels_per_second := 182.0
@export var time_snap_interval := 0.1

# --- Estado Interno ---
var placed_actions: Array = []
var ghost_block: Panel = null # Variável para o bloco fantasma

#==============================================================================
# Funções Nativas do Godot
#==============================================================================

func _ready():
	print(name)
	# Conectamos o sinal 'mouse_exited' do próprio Panel a uma função de limpeza.
	# Você precisa fazer isso no editor do Godot:
	# 1. Selecione o nó do Panel da Timeline.
	# 2. Vá para a aba "Node" ao lado do "Inspector".
	# 3. Clique em "Signals" e encontre "mouse_exited()".
	# 4. Dê um duplo clique e conecte-o a este script (função _on_mouse_exited).
	mouse_exited.connect(_on_mouse_exited)

#==============================================================================
# Funções de Drag-and-Drop
#==============================================================================

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not data["skill_data"] is SkillData:
		return false
	
	if not data["hero_owner"] == hero_owner:
		return false

	if not is_instance_valid(ghost_block):
		ghost_block = _create_action_block_visual(data["skill_data"])
		ghost_block.modulate.a = 0.5
		add_child(ghost_block)

	var snapped_x = _snap_position_x(at_position.x)
	ghost_block.position.x = snapped_x
	ghost_block.position.y = (size.y - ghost_block.size.y) / 2

	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not hero_owner:
		return
	
	if is_instance_valid(ghost_block):
		ghost_block.queue_free()
		ghost_block = null
	
	
	var start_time: float = _snap_position_x(at_position.x) / pixels_per_second
	
	var enemie = get_tree().get_first_node_in_group("enemies")
	var hero = get_tree().get_first_node_in_group("heroes")
	var target: Node2D = null
	if hero_owner.is_enemy:
		target = hero
	else:
		target = enemie
	var new_action = TimelineAction.new(data["skill_data"], hero_owner, target, start_time)
	TimelineManager.add_planed_action(new_action)

	var real_block = _create_action_block_visual(data["skill_data"])
	real_block.position.x = _snap_position_x(at_position.x)
	real_block.position.y = (size.y - real_block.size.y) / 2.0
	add_child(real_block)
	
	placed_actions.append({
		"action_data": new_action,
		"visual_block": real_block
	})
	

#==============================================================================
# Funções de Lógica e Auxiliares
#==============================================================================

func is_overlapping(new_start_time: float, new_end_time: float) -> bool:
	for action in placed_actions:
		if new_start_time < action["end_time"] and action["start_time"] < new_end_time:
			return true
	return false

# Função auxiliar para criar o NÓ visual do bloco de ação.
# Isso evita código duplicado entre o fantasma e o bloco final.
func _create_action_block_visual(data: SkillData) -> Panel:
	var action_block = Panel.new()
	action_block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	action_block.self_modulate = Color(1, 1, 1, 0.8)
	
	var hbox = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_block.add_child(hbox)
	
	var cast_width = data.cast_time * pixels_per_second
	var impact_width = 4
	# var recovery_width = data.get("recovery_time", 0.0) * pixels_per_second
	
	var cast_rect = ColorRect.new()
	cast_rect.color = Color("e6db74") # Amarelo
	cast_rect.custom_minimum_size = Vector2(cast_width, 30)
	cast_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(cast_rect)
	
	var impact_rect = ColorRect.new()
	impact_rect.color = Color("f92672") # Rosa/Vermelho
	impact_rect.custom_minimum_size = Vector2(impact_width, 30)
	impact_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(impact_rect)
	
	# if recovery_width > 0:
	# 	var recovery_rect = ColorRect.new()
	# 	recovery_rect.color = Color("ae81ff") # Roxo
	# 	recovery_rect.custom_minimum_size = Vector2(recovery_width, 30)
	# 	hbox.add_child(recovery_rect)
		
	var texto = Label.new()
	texto.text = data.skill_name
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	action_block.add_child(texto)
	
	var total_width = cast_width + impact_width
	action_block.size = Vector2(total_width, 30)
	
	return action_block

#==============================================================================
# Conexões de Sinais
#==============================================================================

# Chamado quando o mouse sai da área do Panel da timeline.
func _on_mouse_exited():
	print("mouse exited")
	# Se houver um bloco fantasma, destrua-o para limpar a tela.
	if is_instance_valid(ghost_block):
		ghost_block.queue_free()
		ghost_block = null


func _on_mouse_entered() -> void:
	pass # Replace with function body.

func _snap_position_x(x_pos: float) -> float:
	var snap_interval_pixels = pixels_per_second * time_snap_interval
	if snap_interval_pixels == 0:
		return x_pos
	var snapped_x = round(x_pos / snap_interval_pixels) * snap_interval_pixels
	return snapped_x

func set_hero_owner(hero: Unit) -> void:
	self.hero_owner = hero
	$Label.text = hero.name
