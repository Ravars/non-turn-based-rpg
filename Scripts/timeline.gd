extends Control

@export var timeline_lane_scene: PackedScene

# A CORREÇÃO: Exporte a variável para que possamos conectá-la no editor.
# Usamos o tipo "Control" para garantir que só possamos arrastar nós de UI aqui.
@export var timeline_ui: Control 

var lanes_container: VBoxContainer

func _ready() -> void:
	CombatManager.battle_initialized.connect(_on_battle_initialized)
	lanes_container = $ColorRect/VBoxContainer
	
func _on_battle_initialized(heroes: Array[Unit]):
	# Limpa lanes antigas
	for child in lanes_container.get_children():
		child.queue_free()
	
	for hero in heroes:
		var new_lane: TimelineLane = timeline_lane_scene.instantiate()
		new_lane.set_hero_owner(hero)
		lanes_container.add_child(new_lane)
	
	# Esta linha agora funcionará, porque a variável timeline_ui
	# será preenchida pelo editor.
	if timeline_ui:
		timeline_ui.setup_lane_connections(lanes_container)
	else:
		print("ERRO em timeline.gd: A referência para timeline_ui não foi definida no Inspetor!")
