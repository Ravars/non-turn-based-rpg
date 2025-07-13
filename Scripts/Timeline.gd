extends Panel

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

func _can_drop_data(position: Vector2, data: Variant) -> bool:
	var is_valid_data = typeof(data) == TYPE_DICTIONARY and data.has("cast_time")
	if not is_valid_data:
		return false

	# Se não houver um bloco fantasma, crie um.
	if not is_instance_valid(ghost_block):
		ghost_block = _create_action_block_visual(data)
		ghost_block.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ghost_block.modulate.a = 0.5 # Deixa semi-transparente
		add_child(ghost_block)

	# Atualiza a posição do fantasma
	var snapped_x = _snap_position_x(position.x)
	ghost_block.position = Vector2(snapped_x, 15)

	# Calcula o intervalo de tempo e verifica a sobreposição
	var new_start_time = position.x / pixels_per_second
	var duration = data.get("cast_time", 0.0) + data.get("recovery_time", 0.0)
	var new_end_time = new_start_time + duration
	
	var is_valid_position = not is_overlapping(new_start_time, new_end_time)
	
	# Muda a cor do fantasma para dar feedback visual
	if is_valid_position:
		ghost_block.self_modulate = Color.GREEN
	else:
		ghost_block.self_modulate = Color.RED
		
	return is_valid_position

func _drop_data(position: Vector2, data: Variant) -> void:
	if not is_instance_valid(ghost_block):
		return # Não deveria acontecer, mas é uma boa segurança

	# Torna o bloco fantasma permanente
	ghost_block.modulate.a = 1.0 # Opacidade total
	ghost_block.self_modulate = Color.WHITE # Cor normal
	
	# Armazena os dados da ação
	var start_time = ghost_block.position.x / pixels_per_second
	var duration = data.get("cast_time", 0.0) + data.get("recovery_time", 0.0)
	var end_time = start_time + duration
	
	var new_action_data = {
		"start_time": start_time,
		"end_time": end_time,
		"node": ghost_block,
		"details": data
	}
	placed_actions.append(new_action_data)
	print("Ação adicionada: ", new_action_data)
	
	# Limpa a referência para que um novo fantasma possa ser criado
	ghost_block = null

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
func _create_action_block_visual(data: Dictionary) -> Panel:
	var action_block = Panel.new()
	action_block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	action_block.self_modulate = Color(1, 1, 1, 0.8)
	
	var hbox = HBoxContainer.new()
	action_block.add_child(hbox)
	
	var cast_width = data.get("cast_time", 0.5) * pixels_per_second
	var impact_width = 4
	var recovery_width = data.get("recovery_time", 0.0) * pixels_per_second
	
	var cast_rect = ColorRect.new()
	cast_rect.color = Color("e6db74") # Amarelo
	cast_rect.custom_minimum_size = Vector2(cast_width, 30)
	hbox.add_child(cast_rect)
	
	var impact_rect = ColorRect.new()
	impact_rect.color = Color("f92672") # Rosa/Vermelho
	impact_rect.custom_minimum_size = Vector2(impact_width, 30)
	hbox.add_child(impact_rect)
	
	if recovery_width > 0:
		var recovery_rect = ColorRect.new()
		recovery_rect.color = Color("ae81ff") # Roxo
		recovery_rect.custom_minimum_size = Vector2(recovery_width, 30)
		hbox.add_child(recovery_rect)
		
	var texto = Label.new()
	texto.text = data["ability_name"]
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	action_block.add_child(texto)
	
	var total_width = cast_width + impact_width + recovery_width
	action_block.size = Vector2(total_width, 30)
	
	return action_block

#==============================================================================
# Conexões de Sinais
#==============================================================================

# Chamado quando o mouse sai da área do Panel da timeline.
func _on_mouse_exited():
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
			
