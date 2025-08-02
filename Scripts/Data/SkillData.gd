extends Resource
class_name  SkillData

@export var skill_name: String = "New Skill"
@export var skill_description: String = "Description Skill"

@export_group("Combat")
@export var damage: int = 1
@export var cast_time: float = 1.0
@export var cooldown: float = 1.0
@export var status_effects: Array[StatusEffect] = []

@export_group("Visuals")
@export var icon: Texture2D

func print_skill_info():
	print("skill_name")
	#print("Skill: {0}, Damage: {1}".format({0: skill_name, 1: damage}))

func calculate_skill_total_time() -> float:
	return cast_time
