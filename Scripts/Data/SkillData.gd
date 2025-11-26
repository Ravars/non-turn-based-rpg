extends Resource
class_name  SkillData

@export var skill_name: String = "New Skill"
@export var skill_description: String = "Description Skill"

@export_group("Combat")
@export var damage: int = 1
@export var heal: int = 0
@export var damage_type: CombatManager.DamageType = CombatManager.DamageType.PHYSICAL
@export var cast_time: float = 1.0
@export var cooldown: float = 1.0
@export var status_effects: Array[StatusEffect] = []
@export var target_team: TargetTeam = TargetTeam.ENEMIES
@export var target_scope: TargetScope = TargetScope.SINGLE
@export var range_rule: RangeRule = RangeRule.MELEE

@export_group("Visuals")
@export var icon: Texture2D

func print_skill_info():
	print("skill_name")
	#print("Skill: {0}, Damage: {1}".format({0: skill_name, 1: damage}))

func calculate_skill_total_time() -> float:
	return cast_time

enum RangeRule {
	MELEE,
	RANGED
}

enum TargetTeam {
	ENEMIES,
	ALLIES,
	SELF
}

enum TargetScope {
	SINGLE,	
	FRONT_LINE,
	BACK_LINE,
	ALL
}
