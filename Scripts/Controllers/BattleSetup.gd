extends Node
class_name BattleSetup

@export var hero_scenes: Array[PackedScene]
@export var enemy_scenes: Array[PackedScene]

@export var player_spawn_points: Array[Node2D] = []
@export var enemie_spawn_points: Array[Node2D] = []

@export var lane_offset: float = 60.0

var hero_lane_occupancy: Dictionary = {}
var enemy_lane_occupancy: Dictionary = {}


func _ready() -> void:
	hero_lane_occupancy.clear()
	enemy_lane_occupancy.clear()
	CombatManager.initialize_battle(hero_scenes, enemy_scenes, self)
