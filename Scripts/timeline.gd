extends Control

@export var timeline_lane_scene: PackedScene
var lanes_container: VBoxContainer
func _ready() -> void:
	CombatManager.battle_initialized.connect(_on_battle_initialized)
	lanes_container = $ColorRect/VBoxContainer
	
func _on_battle_initialized(heroes: Array[Unit]):
	#Maybe need to queue_free
	
	for hero in heroes:
		var new_lane: TimelineLane = timeline_lane_scene.instantiate()
		new_lane.set_hero_owner(hero)
		
		lanes_container.add_child(new_lane)
