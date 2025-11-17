extends Node

var unit_owner: Unit

func _ready() -> void:
	unit_owner = get_parent()
	
	if unit_owner and not unit_owner.skills.is_empty():
		# Simple AI: just add all skills to the loop
		for skill in unit_owner.skills:
			unit_owner.add_skill_to_loop(skill)
		
		unit_owner.is_loop_active = true
		print("IA: {name} loop initialized with {skill_count} skills.".format({
			"name": unit_owner.name,
			"skill_count": unit_owner.skill_loop.size()
		}))
