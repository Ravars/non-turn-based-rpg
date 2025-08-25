extends Control

@export var timeline_lane_scene: PackedScene
@export var player_action_panel: Control 
@export var pixels_per_second := 182.0
@onready var playhead = $ColorRect/Playhead
@onready var lanes_container = $ColorRect/ScrollContainer/VBoxContainer
@onready var scroll_container = $ColorRect/ScrollContainer
@onready var time_label = $ColorRect/Time
@onready var targeting_line: TargetingLine = $ColorRect/TargetingLine

func _ready() -> void:
	CombatManager.battle_initialized.connect(_on_battle_initialized)
	TimelineManager.time_updated.connect(_on_time_updated)
	
func _on_battle_initialized(heroes: Array[Unit]):
	# Limpa lanes antigas
	for child in lanes_container.get_children():
		child.queue_free()
	
	for hero in heroes:
		var new_lane: TimelineLane = timeline_lane_scene.instantiate()
		new_lane.set_hero_owner(hero)
		new_lane.action_added.connect(_on_action_added)
		new_lane.set_dependencies(targeting_line, player_action_panel)
		lanes_container.add_child(new_lane)
	
	if player_action_panel:
		player_action_panel.setup_lane_connections(lanes_container)
	else:
		print("ERRO em timeline.gd: A referência para player_action_panel não foi definida no Inspetor!")

func _on_time_updated(new_time: float):
	playhead.position.x = new_time * pixels_per_second
	time_label.text = "%.2f" % new_time
	var target_scroll: int = playhead.position.x - (scroll_container.size.x / 2)
	scroll_container.scroll_horizontal = lerp(scroll_container.scroll_horizontal, target_scroll, 0.1)
	
func _on_action_added(action: TimelineAction):
	var required_width = action.get_execution_time() * pixels_per_second
	if required_width > lanes_container.custom_minimum_size.x:
		lanes_container.custom_minimum_size.x = required_width
