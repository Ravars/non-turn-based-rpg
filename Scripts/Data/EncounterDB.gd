extends Resource
class_name EncounterDB

@export var normal_encounters: Array[EncounterData] = []
@export var elite_encounters: Array[EncounterData] = []
@export var boss_encounters: EncounterData

func get_random_normal_encounter() -> Array[CharacterArchetype]:
	if normal_encounters.is_empty():
		return []
	return normal_encounters.pick_random().enemy_archetypes

func get_random_elite_encounter() -> Array[CharacterArchetype]:
	if elite_encounters.is_empty():
		return []
	return elite_encounters.pick_random().enemy_archetypes

func get_boss_encounter() -> Array[CharacterArchetype]:
	if boss_encounters:
		return boss_encounters.enemy_archetypes
	return []
