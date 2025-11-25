extends VBoxContainer

signal hero_dropped(hero_data: PlayerCharacterData)

func _can_drop_data(at_position, data):
	return data is Dictionary and data.has("hero_data")

func _drop_data(at_position, data):
	var hero_data = data["hero_data"]
	hero_dropped.emit(hero_data)
