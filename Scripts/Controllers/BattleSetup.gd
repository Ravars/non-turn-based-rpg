extends Node
class_name BattleSetup


@export var player_spawn_points: Array[Node2D] = []
@export var enemie_spawn_points: Array[Node2D] = []

@export var lane_offset: float = 60.0

var hero_lane_occupancy: Dictionary = {}
var enemy_lane_occupancy: Dictionary = {}


func _ready() -> void:
	hero_lane_occupancy.clear()
	enemy_lane_occupancy.clear()
	var player_team_data = GameManager.player_team
	var enemy_team_data = GameManager.next_encounter_enemies

	CombatManager.initialize_battle(player_team_data, enemy_team_data, self)
