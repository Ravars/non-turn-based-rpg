extends Control

@onready var heroes_loop_container = $HBoxContainer/HeroesLoopContainer
@onready var enemies_loop_container = $HBoxContainer/EnemiesLoopContainer

const SkillSquareScene = preload("res://Scenes/UI/SkillSquare.tscn")

func _ready():
	CombatManager.battle_initialized.connect(setup_loops)
	LoopManager.tick.connect(_on_tick)

func setup_loops(heroes: Array[Unit]):
	for hero in heroes:
		var loop_container = create_loop_container(hero)
		heroes_loop_container.add_child(loop_container)
		hero.execution_plan_changed.connect(_on_execution_plan_changed)
	
	for enemy in CombatManager.active_enemies:
		var loop_container = create_loop_container(enemy)
		enemies_loop_container.add_child(loop_container)
		enemy.execution_plan_changed.connect(_on_execution_plan_changed)

func _on_execution_plan_changed(unit: Unit):
	var container_to_update = heroes_loop_container if !unit.is_enemy else enemies_loop_container
	var index = CombatManager.active_heroes.find(unit) if !unit.is_enemy else CombatManager.active_enemies.find(unit)
	
	if index != -1:
		var old_loop_container = container_to_update.get_child(index)
		old_loop_container.queue_free()
		
		var new_loop_container = create_loop_container(unit)
		container_to_update.add_child(new_loop_container)
		container_to_update.move_child(new_loop_container, index)

func create_loop_container(unit: Unit) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.set_meta("unit", unit)
	var name_label = Label.new()
	name_label.text = unit.name
	vbox.add_child(name_label)
	
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	var skill_index = 0
	for step in unit.execution_plan:
		if step.type == "cast":
			var skill = step.skill
			
			var skill_vbox = VBoxContainer.new()
			hbox.add_child(skill_vbox)

			var skill_square = SkillSquareScene.instantiate()
			skill_square.setup(skill)
			skill_vbox.add_child(skill_square)
			
			var progress_bar = ProgressBar.new()
			progress_bar.max_value = skill.cast_time
			progress_bar.name = "ProgressBar_" + str(skill_index)
			skill_vbox.add_child(progress_bar)
			skill_index += 1
	
	return vbox

func _on_tick(_current_time: float, _delta: float):
	for loop_container in heroes_loop_container.get_children():
		var unit = loop_container.get_meta("unit") as Unit
		if is_instance_valid(unit):
			update_progress_bars(loop_container, unit)

	for loop_container in enemies_loop_container.get_children():
		var unit = loop_container.get_meta("unit") as Unit
		if is_instance_valid(unit):
			update_progress_bars(loop_container, unit)

func update_progress_bars(loop_container: VBoxContainer, unit: Unit):
	var hbox = loop_container.get_child(1) as HBoxContainer
	var skill_index = 0
	for step_index in range(unit.execution_plan.size()):
		var step = unit.execution_plan[step_index]
		if step.type == "cast":
			var skill_vbox = hbox.get_child(skill_index)
			var progress_bar = skill_vbox.get_node("ProgressBar_" + str(skill_index))
			
			if step_index == unit.plan_index:
				progress_bar.value = unit.step_progress_timer
			else:
				progress_bar.value = 0
			
			skill_index += 1
