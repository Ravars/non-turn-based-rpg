extends Resource
class_name StatusEffect

@export_group("Name")
@export var effect_name: String = "Novo Efeito"
@export var icon: Texture2D
# --- Duracao ---
@export_group("Values")
@export var duration: float = 1.0
@export var value: float = 1.0
@export var type: EffectType = EffectType.STAT_MODIFIER
@export var damage_type: CombatManager.DamageType = CombatManager.DamageType.POISON
@export var target_stat: Stat = Stat.STRENGTH
@export var is_percentage: bool = false

enum EffectType{
	STUN,
	DAMAGE_OVER_TIME,
	HEAL_OVER_TIME,
	STAT_MODIFIER,
	ADD_SHIELD,
	REMOVE_SHIELD,
	TAUNT,
	STEALTH
}
enum Stat {
	NONE,
	STRENGTH,
	DEXTERITY,
	ARMOR,
	MAGIC_RESIST,
	INTELLIGENCE,
	FAITH
}
