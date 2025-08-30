extends Panel
class_name TimelineLane

signal target_selection_requested(action: TimelineAction)
signal target_selection_stoped()
signal action_added(action: TimelineAction)
var hero_owner: Unit
@onready var indicator_image: Sprite2D = $Indicator
# --- Variáveis de Configuração ---
@export var time_snap_interval := 0.1
var pixels_per_second := 0.0
var progress_empty = preload("res://Icons/progress_empty.png")
var progress_25 = preload("res://Icons/progress_CCW_25.png")
var progress_50 = preload("res://Icons/progress_CCW_50.png")
var progress_75 = preload("res://Icons/progress_CCW_75.png")
var progress_full = preload("res://Icons/progress_full.png")
var targeting_line: TargetingLine
var player_action_panel: PlayerActionPanel

@export var timeline_action_block_scene: PackedScene
# --- Estado Interno ---
var placed_actions: Array = []
var ghost_block: Panel = null # Variável para o bloco fantasma

#==============================================================================
# Funções Nativas do Godot
#==============================================================================

func _ready():
	print(name)

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
	
	# Cria a ação com o alvo NULO.
	var new_action = TimelineAction.new(data["skill_data"], hero_owner, null, start_time)
	# Adiciona a ação (ainda sem alvo) ao manager.
	hero_owner.add_action_to_queue(new_action)
	# TimelineManager.add_planned_action(new_action)

	# Emite o sinal para que a UI saiba que esta ação precisa de um alvo.
	target_selection_requested.emit(new_action)
	action_added.emit(new_action)

	if not timeline_action_block_scene:
		print("ERRO: Timeline block nao definido")
		return
	var real_block:TimelineActionBlock = timeline_action_block_scene.instantiate()
	real_block.setup_block(new_action, pixels_per_second)

	# var real_block = _create_action_block_visual(data["skill_data"])
	real_block.position.x = _snap_position_x(at_position.x)
	real_block.position.y = (size.y - real_block.size.y) / 2.0
	add_child(real_block)
	real_block.removed.connect(_on_action_block_removed)
	real_block.target_change_requested.connect(player_action_panel._on_target_selection_requested)
	if is_instance_valid(targeting_line):
		real_block.show_target_line.connect(targeting_line.update_and_show_line)
		real_block.hide_target_line.connect(targeting_line.clear_line)
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

func _create_action_block_visual(data: SkillData) -> Panel:
	var action_block = Panel.new()
	action_block.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	action_block.self_modulate = Color(1, 1, 1, 0.8)
	
	var hbox = HBoxContainer.new()
	action_block.add_child(hbox)
	
	var cast_width = data.cast_time * pixels_per_second
	var impact_width = 4
	
	var cast_rect = ColorRect.new()
	cast_rect.color = Color("e6db74") # Amarelo
	cast_rect.custom_minimum_size = Vector2(cast_width, 30)
	hbox.add_child(cast_rect)
	
	var impact_rect = ColorRect.new()
	impact_rect.color = Color("f92672") # Rosa/Vermelho
	impact_rect.custom_minimum_size = Vector2(impact_width, 30)
	hbox.add_child(impact_rect)
		
	var texto = Label.new()
	texto.text = data.skill_name
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	action_block.add_child(texto)
	
	var total_width = cast_width + impact_width
	action_block.size = Vector2(total_width, 30)
	
	return action_block

#==============================================================================
# Conexões de Sinais
#==============================================================================

func _on_mouse_exited():
	if is_instance_valid(ghost_block):
		ghost_block.queue_free()
		ghost_block = null


func _on_mouse_entered() -> void:
	pass

func _snap_position_x(x_pos: float) -> float:
	var snap_interval_pixels = pixels_per_second * time_snap_interval
	if snap_interval_pixels == 0:
		return x_pos
	var snapped_x = round(x_pos / snap_interval_pixels) * snap_interval_pixels
	return snapped_x

func set_hero_owner(hero: Unit) -> void:
	self.hero_owner = hero
	$Label.text = hero.name
	self.hero_owner.action_executed.connect(action_executed)
	self.hero_owner.action_started.connect(action_started)
	self.hero_owner.action_tick.connect(action_tick)

func action_executed(action: TimelineAction) -> void:
	if action.caster == hero_owner:
		indicator_image.texture = progress_full
		
func action_started(action: TimelineAction) -> void:
	if action.caster == hero_owner:
		indicator_image.texture = progress_empty

func action_tick(percent: float) -> void:
	if percent == 0:
		indicator_image.texture = progress_empty
	elif percent >= 75:
		indicator_image.texture = progress_75
	elif percent >= 50:
		indicator_image.texture = progress_50
	elif percent >= 25:
		indicator_image.texture = progress_25


func _on_action_block_removed(action_to_remove: TimelineAction):
	hero_owner.remove_action_from_queue(action_to_remove)
	for i in range(placed_actions.size()-1, -1, -1):
		if placed_actions[i].action_data == action_to_remove:
			target_selection_stoped.emit()
			var block_node = placed_actions[i].visual_block
			if is_instance_valid(block_node):
				block_node.queue_free()
			placed_actions.remove_at(i)
			break


func set_dependencies(p_targeting_line: TargetingLine, p_player_action_panel: PlayerActionPanel) -> void:
	self.targeting_line = p_targeting_line
	self.player_action_panel = p_player_action_panel
