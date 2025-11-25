extends Node

var player_team: Array[PlayerCharacterData] = []
var next_encounter_enemies: Array[CharacterArchetype] = []
var map_data: Array[Array] = []
var map_generator = MapGenerator.new()

const PLAYABLE_HEROES_DB: PlayableArchetypes = preload("res://Resources/Archetypes/PlayableHeroes.tres")
const SKILL_REWARD_DB: SkillRewardDB = preload("res://Resources/Skills/SkillRewardDB.tres")
var current_map_node = 0
var gold: int = 0
signal run_started
signal combat_ended(was_victory: bool)

func _ready():
	combat_ended.connect(_on_combat_ended)
	get_tree().change_scene_to_file("res://Scenes/TeamSelectionScreen.tscn")

var current_player_pos := Vector2i.ZERO

var current_map_node_ref: GraphNode = null

var front_lane_heroes: Array[PlayerCharacterData] = []
var back_lane_heroes: Array[PlayerCharacterData] = []

var visited_nodes: Array[Vector2i] = []

func start_new_run(chosen_archetypes: Array[CharacterArchetype]):
	print("GAME MANAGER: Iniciando nova partida")
	player_team.clear();
	front_lane_heroes.clear()
	back_lane_heroes.clear()

	for archetype in chosen_archetypes:
		var character_data = PlayerCharacterData.new()
		character_data.archetype = archetype
		character_data.current_hp = archetype.base_stats.health
		player_team.append(character_data)
	
	map_data = map_generator.generate_map()
	
	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
			if map_data[y][x] and map_data[y][x].type == MapGenerator.NodeType.START:
				current_player_pos = Vector2i(x, y)
				break
	
	current_map_node_ref = null
	visited_nodes.clear()
	run_started.emit()
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func set_team_formation(_front_lane_heroes: Array[PlayerCharacterData], _back_lane_heroes: Array[PlayerCharacterData]):
	front_lane_heroes = _front_lane_heroes
	back_lane_heroes = _back_lane_heroes

func update_player_pos(new_pos: Vector2i):
	current_player_pos = new_pos

func update_current_map_node_ref(node: GraphNode):
	current_map_node_ref = node

func add_visited_node(node_pos: Vector2i):
	if not visited_nodes.has(node_pos):
		visited_nodes.append(node_pos)

func start_combat(enemy_archetypes: Array[CharacterArchetype]):
	print("GAME MANAGER: Preparando para iniciar o combate.")
	next_encounter_enemies = enemy_archetypes
	get_tree().change_scene_to_file("res://Scenes/UI/TeamFormationScreen.tscn")

func _on_combat_ended(was_victory: bool):
	if was_victory:
		print("GAME MANAGER: Vitória! Retornando ao mapa.")
		for hero_data in player_team:
			var hero_survived = false
			for hero_in_combat in CombatManager.active_heroes:
				if hero_in_combat.archetype == hero_data.archetype:
					hero_data.current_hp = hero_in_combat.current_hp
					hero_survived = true
					print("Heroi {0} sobreviveu com {1} HP".format({0: hero_data.archetype.character_name, 1: str(hero_data.current_hp)}))
					break
			if not hero_survived:
				hero_data.current_hp = 0
				print("Heroi {0} foi derrotado em combate".format({0: hero_data.archetype.character_name}))
		LoopManager.reset_timeline()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/RewardScreen.tscn")

	else:
		print("GAME MANAGER: Derrota! Fim da partida.")
		get_tree().change_scene_to_file("res://Scenes/UI/GameOverScreen.tscn")

	
func get_available_hero_archetype(): #TODO:  -> Array[CharacterArchetype]
	return PLAYABLE_HEROES_DB.available_heroes


func get_skill_reward_options(count: int) -> Array[SkillData]:
	var options: Array[SkillData] = []
	if SKILL_REWARD_DB.skill_pool.is_empty():
		return options
	var available_skills = SKILL_REWARD_DB.skill_pool.duplicate()
	available_skills.shuffle()
	for i in range(min(count, available_skills.size())):
		options.append(available_skills[i])
	return options

func add_skill_to_hero(new_skill: SkillData, target_hero_data: PlayerCharacterData):
	if not player_team.has(target_hero_data):
		print("Erro: Character not found")
		return
	target_hero_data.archetype.starting_skills.append(new_skill)
	print("Habilidade {0} adicionada ao {1}!".format({0: new_skill.skill_name, 1: target_hero_data.archetype.character_name}))
