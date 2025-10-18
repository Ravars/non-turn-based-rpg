extends Resource
class_name  SkillData

@export var skill_name: String = "New Skill"
@export var skill_description: String = "Description Skill"

@export_group("Combat")
@export var damage: int = 1
@export var damage_type: CombatManager.DamageType = CombatManager.DamageType.PHYSICAL
@export var cast_time: float = 1.0
@export var cooldown: float = 1.0
@export var status_effects: Array[StatusEffect] = []
@export var targeting_rule: TargetingRule = TargetingRule.SINGLE_TARGET
@export var range_rule: RangeRule = RangeRule.RANGED
@export var area_target: AreaTarget = AreaTarget.NONE

@export_group("Visuals")
@export var icon: Texture2D

func print_skill_info():
	print("skill_name")
	#print("Skill: {0}, Damage: {1}".format({0: skill_name, 1: damage}))

func calculate_skill_total_time() -> float:
	return cast_time


enum TargetingRule {
	SINGLE_TARGET,
	AREA_OF_EFFECT
}

enum RangeRule {
	MELEE,
	RANGED
}

enum AreaTarget {
	NONE,
	ENEMY_FRONT_LINE,
	ENEMY_BACK_LINE,
	ALL_ENEMIES,
	ALLY_FRONT_LINE,
	ALLY_BACK_LINE,
	ALL_ALLIES
}