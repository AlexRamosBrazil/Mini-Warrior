extends Node2D
class_name Enemy

@export var health = 5
@export var hit_damage = 2
@export var death_scene: PackedScene

@onready var damage_digit_marker = $DamageDigitMarker
@onready var damage_digit_scene = preload("res://Misc/damage_digit.tscn")

@export var drop_chance = 0.1
@export var drop_items:Array[PackedScene]
@export var drop_chances: Array[float]

 
func damage(amount):
	health -= amount
	
	# piscar inimigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	var damage_digit = damage_digit_scene.instantiate()
	damage_digit.value = amount
	damage_digit.global_position = damage_digit_marker.global_position
	get_parent().add_child(damage_digit)
	
	# matar o inimigo
	if health <= 0:
		die()

func die():
	# caveira
	if death_scene:
		var death_object = death_scene.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	#drop de itens
	if randf() <= drop_chance:
		drop_item()
	
	# notificar montro morto 
	GameManager.monsters_defeated_counter += 1
	
	# eliminar cena
	queue_free()


func drop_item():
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop_item():
	# se lista só tem 1 item, retorna este
	if drop_items.size() == 1:
		return drop_items[0]
	
	# definir chance máxima
	var max_chance = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
	
	# jogar dado
	var random_value = randf() * max_chance
	
	# girar a roleta
	var needle = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
		
	return drop_items[0]
