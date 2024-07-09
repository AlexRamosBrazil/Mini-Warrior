extends CanvasLayer



@onready var timer_label = $TimerLabel
@onready var meat_label = $Panel/MeatLabel
@onready var kills_label = $Panel/KillsLabel


func _process(delta):
	meat_label.text = str(GameManager.meat_counter)
	timer_label.text = GameManager.time_elapsed_string
