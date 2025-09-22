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
var ghost_block: Dictionary = {}

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

	var proposed_start_time = _snap_position_x(at_position.x) / pixels_per_second
	var skill_cast_time = data["skill_data"].cast_time

	var is_in_future = proposed_start_time >= TimelineManager.current_time
	var is_slot_free = _is_timeslot_free(proposed_start_time, skill_cast_time)

	var is_valid_position = is_in_future and is_slot_free
	
	if ghost_block.is_empty():
		ghost_block = _create_action_block_visual(data["skill_data"])
		ghost_block.node.modulate.a = 0.5
		add_child(ghost_block.node)

	var snapped_x = _snap_position_x(at_position.x)
	ghost_block.node.position.x = snapped_x
	ghost_block.node.position.y = (size.y - ghost_block.node.size.y) / 2

	if is_valid_position:
		ghost_block.cast_rect.self_modulate = Color.GREEN.lightened(0.5)
	else:
		ghost_block.cast_rect.self_modulate = Color.RED.lightened(0.5)


	return is_valid_position

func _is_timeslot_free(new_start_time: float, new_cast_time: float, ignored_action: TimelineAction = null) -> bool:
	if not is_instance_valid(hero_owner):
		return false
	var new_end_time = new_start_time + new_cast_time

	for existing_action in hero_owner.action_queue:
		if existing_action == ignored_action:
			continue
		var existing_end_time = existing_action.start_time + existing_action.skill_data.cast_time
		if new_start_time < existing_end_time and existing_action.start_time < new_end_time:
			return false
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not hero_owner:
		return
	
	if not ghost_block.is_empty():
		if is_instance_valid(ghost_block.node):
			ghost_block.node.queue_free()
		ghost_block.clear()
	
	
	var start_time: float = _snap_position_x(at_position.x) / pixels_per_second
	var skill_cast_time = data["skill_data"].cast_time

	if start_time < TimelineManager.current_time:
		print("ERROR: Ação no passado")
		return
	if not _is_timeslot_free(start_time, skill_cast_time):
		print("ERRO: Slot ocupado")
		return

	var new_action = TimelineAction.new(data["skill_data"], hero_owner, null, start_time)
	hero_owner.add_action_to_queue(new_action)
	target_selection_requested.emit(new_action)
	action_added.emit(new_action)
	_create_and_place_action_block(new_action)
	
	
func _on_action_added_to_unit(new_action: TimelineAction):
	_create_and_place_action_block(new_action)
	
func _create_and_place_action_block(new_action: TimelineAction):
	for item in placed_actions:
		if item.action_data == new_action:
			return
	if not timeline_action_block_scene:
		print("ERRO: Cena nao definida")
		return
	var real_block:TimelineActionBlock = timeline_action_block_scene.instantiate()
	real_block.setup_block(new_action, pixels_per_second)
	real_block.position.x = new_action.start_time * pixels_per_second
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

func _create_action_block_visual(data: SkillData) -> Dictionary:
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
	cast_rect.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	hbox.add_child(cast_rect)
	
	var impact_rect = ColorRect.new()
	impact_rect.color = Color("f92672") # Rosa/Vermelho
	impact_rect.custom_minimum_size = Vector2(impact_width, 30)
	impact_rect.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	hbox.add_child(impact_rect)
		
	var texto = Label.new()
	texto.text = data.skill_name
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texto.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	action_block.add_child(texto)
	
	var total_width = cast_width + impact_width
	action_block.size = Vector2(total_width, 30)
	
	return {
		"node": action_block,
		"cast_rect": cast_rect
	}

	
#==============================================================================
# Conexões de Sinais
#==============================================================================

func _on_mouse_exited():
	if not ghost_block.is_empty():
		if is_instance_valid(ghost_block.node):
			ghost_block.node.queue_free()
		ghost_block.clear()


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
	self.hero_owner.action_added.connect(_on_action_added_to_unit)

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
