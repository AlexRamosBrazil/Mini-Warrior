extends Node2D

@export var life_amount = 10


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.heal(life_amount)
		body.meat_collected.emit(life_amount)
		queue_free()
