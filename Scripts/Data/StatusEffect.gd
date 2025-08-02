extends Resource
class_name StatusEffect

@export_group("Name")
@export var effect_name: String = "Novo Efeito"
@export var icon: Texture2D
@export var type: EffectType = EffectType.STAT_MODIFIER
# --- Duracao ---
@export_group("Values")
@export var duration: float = 1.0
@export var value: float = 1.0
@export var target_stat: Stat = Stat.STRENGTH
@export var is_percentage: bool = false

enum EffectType{
	STUN,
	DAMAGE_OVER_TIME,
	HEAL_OVER_TIME,
	STAT_MODIFIER
}
enum Stat {
	STRENGTH,
	DEXTERITY,
	ARMOR,
	MAGIC_RESIST
}
