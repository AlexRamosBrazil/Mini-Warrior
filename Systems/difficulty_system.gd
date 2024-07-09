extends Node

var time = 0.0
@export var spawn_rate_per_minute = 30.0
@export var initial_spawn_rate = 60.0
@export var mob_spawner: MobSpawnner
@export var wave_duration = 15.0
@export var break_intensity = 0.5


func _process(delta):
	if GameManager.is_game_over: return
		
	time += delta
	
	var spawn_rate = initial_spawn_rate + initial_spawn_rate * (time / 60.0)
	var sin_wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	spawn_rate *= wave_factor
	
	mob_spawner.mobs_per_minute = spawn_rate
