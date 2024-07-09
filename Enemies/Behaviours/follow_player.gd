extends Node

@export var speed = 300.0

var input_vector = Vector2.ZERO
var animated_sprite_2d: AnimatedSprite2D
var enemy: Enemy

func _ready():
	# obtem os dados do nó raíz
	enemy = get_parent()
	animated_sprite_2d = enemy.get_node("AnimatedSprite2D")


func _physics_process(delta):
	if GameManager.is_game_over: return
	
	# calcula a direção do movimento em relação ao jogador
	input_vector = (GameManager.player_position - enemy.position).normalized()
	
	# aplica movimento ao inimigo
	enemy.velocity = input_vector * speed
	enemy.move_and_slide()
	
	# rotaciona o sprite de acordo com a direção do movimento
	if input_vector.x > 0 :
		animated_sprite_2d.flip_h = false
	elif input_vector.x < 0 :
		animated_sprite_2d.flip_h = true
