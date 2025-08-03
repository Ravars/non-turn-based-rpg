extends RefCounted
class_name TimelineAction

var skill_data: SkillData
var caster: Unit
var target: Unit
var start_time: float
var cast_progress: float = 0.0

func _init(p_skill_data: SkillData, p_caster: Unit, p_target: Unit, p_start_time: float) -> void:
	self.skill_data = p_skill_data
	self.caster = p_caster
	self.target = p_target
	self.start_time = p_start_time

func set_start_time(new_start_time: float) -> void:
	self.execution_time = new_start_time

func get_execution_time() -> float:
	return self.start_time + self.skill_data.cast_time
