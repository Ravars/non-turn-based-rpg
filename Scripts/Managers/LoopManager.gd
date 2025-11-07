extends Node

var current_time: float = 0.0
var is_paused: bool = true
var is_selecting_target: bool = false
var time_scale: float = 1
var action_awaiting_target: TimelineAction = null
signal tick(current_time: float, delta: float)
signal time_scale_changed(time_scale: float)

func _ready():
	LimboConsole.register_command(play_game, "timeline play", "Play the game")
	LimboConsole.register_command(pause_game, "timeline pause", "Pause the game")
	LimboConsole.register_command(set_time_scale, "timeline setscale", "Set timeline scale")

func pause_game():
	if not is_paused:
		is_paused = true
		print("Jogo Pausado")
	
func play_game():
	if is_paused:
		is_paused = false
		print("Jogo iniciado")

func _physics_process(p_delta: float) -> void:
	if is_paused:
		return
	current_time += p_delta * time_scale
	tick.emit(current_time, p_delta * time_scale)

func set_time_scale(p_time_scale: float):
	self.time_scale = p_time_scale
	time_scale_changed.emit(p_time_scale)

func reset_timeline():
	current_time = 0.0
	is_paused = true
	time_scale = 1