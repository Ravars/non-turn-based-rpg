extends Control
class_name SkillLoopPanel
const SkillLoopItemScene = preload("res://Scenes/UI/SkillLoopItem.tscn")

@onready var available_container: VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer_Available
@onready var loop_container: VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer_Loop
@onready var hero_name_label: Label = $MarginContainer/VBoxContainer/Label_HeroName
@onready var cast_time_label: Label = $MarginContainer/VBoxContainer/GridContainer_Stats/Label_CastTimeValue
@onready var idle_time_label: Label = $MarginContainer/VBoxContainer/GridContainer_Stats/Label_IdleTimeValue
@onready var total_time_label: Label = $MarginContainer/VBoxContainer/GridContainer_Stats/Label_TotalTimeValue

var selected_hero: Unit

func display_for_hero(hero:Unit):
	self.selected_hero = hero
	update_ui()

func update_ui():
	if not is_instance_valid(selected_hero):
		# limpar UI
		hero_name_label.text = "Nenhum Herói selecionado"
		cast_time_label.text = "0.00 s"
		idle_time_label.text = "0.00 s"
		total_time_label.text = "0.00 s"
		for child in available_container.get_children():
			if child is PanelContainer: 
				child.queue_free()
		for child in loop_container.get_children():
			if child is PanelContainer: 
				child.queue_free()
		return
	hero_name_label.text = selected_hero.name
	for child in available_container.get_children():
		if child is PanelContainer: 
			child.queue_free()
	for child in loop_container.get_children():
		if child is PanelContainer: 
			child.queue_free()
	
	for skill in selected_hero.skills:
		var item: SkillLoopItem = SkillLoopItemScene.instantiate()
		item.setup(skill, -1, false, 0.0)
		item.action_button_pressed.connect(_on_add_skill_pressed)
		available_container.add_child(item)

	 # Popula a lista do loop atual (agora usando o execution_plan para visualização)
	var current_total_cast_time = 0.0
	var current_total_idle_time = 0.0
	var current_total_duration = 0.0
	var skill_loop_index_counter = 0
	for step in selected_hero.execution_plan:
		if step.type == "cast":
			var skill = step.skill
			var item: SkillLoopItem = SkillLoopItemScene.instantiate()
			# Encontra o índice da skill no skill_loop original para o botão de remover
			# var original_index = selected_hero.skill_loop.find(skill)
			var index_to_remove = skill_loop_index_counter
			item.setup(skill, index_to_remove, true, 0.0)
			item.action_button_pressed.connect(_on_remove_skill_pressed)
			loop_container.add_child(item)
			current_total_cast_time += skill.cast_time
			skill_loop_index_counter += 1
		elif step.type == "idle":
			# Para o tempo ocioso, podemos adicionar um item visual diferente ou apenas somar ao total
			var idle_duration = step.duration
			# Opcional: Adicionar um item visual para o tempo ocioso
			var idle_item: SkillLoopItem = SkillLoopItemScene.instantiate()
			idle_item.setup(null, -1, true, idle_duration) # Skill nula para indicar idle
			#idle_item.label_skill_name.text = "Ocioso (%.2f s)" % idle_duration
			#idle_item.button_action.visible = false # Não pode remover tempo ocioso diretamente
			loop_container.add_child(idle_item)
			current_total_idle_time += idle_duration
		# current_total_duration += step.duration # Soma a duração de cada passo

	# Atualiza os status do loop
	cast_time_label.text = "%.2f s" % current_total_cast_time
	idle_time_label.text = "%.2f s" % current_total_idle_time
	total_time_label.text = "%.2f s" % current_total_duration

func _on_add_skill_pressed(skill_data: SkillData, _index: int):
	if is_instance_valid(selected_hero):
		selected_hero.add_skill_to_loop(skill_data)
		update_ui()

func _on_remove_skill_pressed(_skill_data: SkillData, index: int):
	if is_instance_valid(selected_hero):
		print("Index {0}".format({0: index}))
		selected_hero.remove_skill_from_loop(index)
		update_ui()
