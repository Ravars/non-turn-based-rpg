extends PanelContainer

@onready var effect_name_label = $VBoxContainer/EffectNameLabel
@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var duration_label = $VBoxContainer/DurationLabel
var effect: StatusEffect
func setup(p_effect: StatusEffect):
	self.effect = p_effect
	

func _ready() -> void:
	effect_name_label.text = effect.effect_name
	description_label.text = "This is a placeholder description for the status effect." # Replace with actual description
	duration_label.text = "Duration: " + str(effect.duration)
