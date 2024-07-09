extends Node2D

var value = 0
@onready var label = $Node2D/Label

func _ready():
	label.text = str(value)
