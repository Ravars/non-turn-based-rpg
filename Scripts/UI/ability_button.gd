@tool
extends Button
class_name Ability_button

var skill_data: SkillData
var hero_owner: Unit
@export var timeline_ui: PlayerActionPanel
@export var tooltip_scene: PackedScene
var current_tooltip = null
var is_draging: bool = false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	# pressed.connect(_on_quick_add_pressed)
	gui_input.connect(_on_gui_input)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if timeline_ui and timeline_ui.is_selecting_target:
		print("Bloqueado: Selecione um alvo primeiro")
		return null
	if hero_owner.is_dead:
		return null
	is_draging = true
	var preview = Label.new()
	preview.text = skill_data.skill_name
	preview.set_size(Vector2(100,30))
	set_drag_preview(preview)
	return {
		"skill_data": skill_data,
		"hero_owner": hero_owner
	}


func set_skill(p_skill_data: SkillData):
	self.skill_data = p_skill_data
	
func set_hero_owner(hero: Unit):
	self.hero_owner = hero

func _on_mouse_entered():
	if is_instance_valid(current_tooltip):
		current_tooltip.queue_free()

	current_tooltip = tooltip_scene.instantiate()
	current_tooltip.update_info(skill_data, hero_owner)
	timeline_ui.add_child(current_tooltip)
	current_tooltip.global_position = get_global_mouse_position() + Vector2(20, 20)

func _on_mouse_exited():
	if is_instance_valid(current_tooltip):
		current_tooltip.queue_free()
		current_tooltip = null

# func _on_quick_add_pressed():
	

func _on_gui_input(event: InputEvent):
	if disabled:
		return
	if event is InputEventMouseButton and not event.is_pressed():
		if not is_draging:
			_do_quick_add()
		is_draging = false

func _do_quick_add():
	print("Quick add {0}".format({0: skill_data.skill_name}))
	if is_instance_valid(hero_owner):
		hero_owner.quick_add_skill(skill_data)