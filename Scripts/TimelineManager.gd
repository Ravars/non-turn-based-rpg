extends Node

var characters: Array[TimelineCharacter] = []
var current_time: float = 0.0
var is_paused: bool = false

func pause_game():
	if not is_paused:
		is_paused = true
		print("Jogo Pausado")
	
func play_game():
	if is_paused:
		is_paused = false
		print("Jogo iniciado")

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	current_time += delta / 5
	CombatManager.batata(current_time)
	

func add_character_timeline(character: Unit) -> int:
	var new_timeline_character = TimelineCharacter.new(character)
	characters.append(new_timeline_character)
	print(characters.size())
	#
	if characters.size() == 4:
		play_game()
	
	return characters.size()-1

func _on_player_dropped_skill(timeline_id: int, skill: SkillData, caster: Node2D, target: Node2D, time: float):
	var new_action = TimelineAction.new(skill,caster,target, time)
	characters[timeline_id].actions.append(new_action)
