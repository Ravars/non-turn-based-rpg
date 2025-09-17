extends Node

var player_team: Array[PlayerCharacterData] = []
var next_encounter_enemies: Array[CharacterArchetype] = []

const PLAYABLE_HEROES_DB: PlayableArchetypes = preload("res://Resources/Archetypes/PlayableHeroes.tres")
# const skill_reward: Array[SkillData] = preload("")
var skill_reward: Array[SkillData] = []
var current_map_node = 0
var gold: int = 0
signal run_started
signal combat_ended(was_victory: bool)

func _ready():
	combat_ended.connect(_on_combat_ended)
	get_tree().change_scene_to_file("res://Scenes/TeamSelectionScreen.tscn")

func start_new_run(chosen_archetypes: Array[CharacterArchetype]):
	print("GAME MANAGER: Iniciando nova partida")
	player_team.clear();

	for archetype in chosen_archetypes:
		var character_data = PlayerCharacterData.new()
		character_data.archetype = archetype
		character_data.current_hp = archetype.base_stats.health
		player_team.append(character_data)
	
	run_started.emit()
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")

func start_combat(enemy_archetypes: Array[CharacterArchetype]):
	print("GAME MANAGER: Preparando para iniciar o combate.")
	next_encounter_enemies = enemy_archetypes
	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")

func _on_combat_ended(was_victory: bool):
	if was_victory:
		print("GAME MANAGER: Vitória! Retornando ao mapa.")
		for i in range(player_team.size()):
			var hero_data = player_team[i]
			var hero_in_combat = CombatManager.active_heroes[i]
			hero_data.current_hp = hero_in_combat.current_hp
		get_tree().change_scene_to_file("res://Scenes/RewardScreen.tscn")

	else:
		print("GAME MANAGER: Derrota! Fim da partida.")
		# start_new_run()

	
func get_available_hero_archetype(): #TODO:  -> Array[CharacterArchetype]
	return PLAYABLE_HEROES_DB.available_heroes


func get_skill_reward_options(count: int) -> Array[SkillData]:
	var options: Array[SkillData] = []
	if skill_reward.is_empty():
		return options
	var available_skills = skill_reward.duplicate()
	available_skills.shuffle()
	for i in range(min(count, available_skills.size())):
		options.append(available_skills[i])
	return options

func add_skill_to_hero(new_skill: SkillData):
	if player_team.is_empty():
		return
	var hero_archetype = player_team[0].archetype # Choose hero
	hero_archetype.starting_skills.append(new_skill)
	print("Habilidade {0} adicionada ao {1}!".format({0: new_skill.skill_name, 1: hero_archetype.character_name}))
