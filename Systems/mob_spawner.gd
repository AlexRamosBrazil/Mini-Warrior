class_name MobSpawnner
extends Node2D

@export var creatures: Array[PackedScene]
var mobs_per_minute = 60.0

@onready var path_follow_2d = $Path2D/PathFollow2D

var cooldown = 0.0

func _process(delta):
	if GameManager.is_game_over: return
	
	#reduz temporizador
	cooldown -= delta
	
	if cooldown > 0:
		return
		
	var interval = 60 / mobs_per_minute
	cooldown = interval
	
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	
	var result = world_state.intersect_point(parameters, 1)
	
	if not result.is_empty():
		return
	
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)

func get_point():
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
