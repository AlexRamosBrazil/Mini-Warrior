extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var monsters_label = %MonstersLabel

@export var restart_delay = 5
var restart_cooldown

func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	restart_cooldown = restart_delay


func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0:
		restart_game()
		
	
func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
