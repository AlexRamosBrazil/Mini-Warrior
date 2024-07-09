class_name Player
extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var sword_area = $SwordArea
@onready var hitbox_area = $HitboxArea
@onready var health_progress_bar = $HealthProgressBar

@export_category("Movement")
@export var speed = 500
@export var lerp_factor = 0.05

@export_category("Attack")
@export var sword_damage = 2

@export_category("Life")
@export var health = 50
@export var max_health = 100
@export var death_scene: PackedScene

@export_category("Ritual")
@export var ritual_damage = 1
@export var ritual_interval = 30
@export var ritual_scene: PackedScene

var input_vector = Vector2.ZERO
var is_running = false
var was_running = false
var is_attacking = false
var attack_cooldown = 0.0
var hitbox_cooldown = 0.0
var ritual_cooldown = 0.0

signal meat_collected(value)


func _ready():
	GameManager.player = self
	meat_collected.connect(func(value): GameManager.meat_counter += 1)

func _process(delta):
	# captura direção do jogador
	read_input()
	
	# atualiza cooldown de ataque
	update_attack_cooldown(delta)
	update_ritual_cooldown(delta)
	
	# verifica e define animação de movimento
	play_run_idle_animation()
	
	#verifica e define direção do sprite
	if not is_attacking:
		rotate_sprite()
	
	# processar dano
	update_hitbox(delta)
	
	# atualiza a posição do jogador no GameManager
	GameManager.player_position = position
	
	#atualizar progress bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health


func _physics_process(delta):
	# atualiza a velocidade
	var target_velocity = input_vector * speed
	if is_attacking:
		target_velocity *= 0.1
	velocity = lerp(velocity, target_velocity, lerp_factor)
	move_and_slide()


func read_input():
	# identifica movimento e move o player
	input_vector = Input.get_vector("move_left","move_right","move_up", "move_down")
	
	# atualizar is_running
	was_running = is_running
	is_running =  not input_vector.is_zero_approx()
	
		# checa se está atacando
	if Input.is_action_just_pressed("attack"):
		attack()


func attack():
	# se já está atacando não ataca novamente
	if is_attacking:
		return
	
	#randomiza e executa animação
	if randi_range(0,1):
		animation_player.play("attack_1")
	else:
		animation_player.play("attack_2")
	
	# configurar temporizador
	attack_cooldown = 0.6
	
	# setar is_attacking
	is_attacking = true


func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction
			if sprite_2d.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.5:
					enemy.damage(sword_damage)


func update_attack_cooldown(delta):
	# atualiza temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")


func update_ritual_cooldown(delta):
	ritual_cooldown -= delta
	if ritual_cooldown > 0:
		return
	
	ritual_cooldown = ritual_interval
	
	var ritual = ritual_scene.instantiate()
	add_child(ritual)
	ritual.damage_amount = ritual_damage
	ritual.deal_damage()


func play_run_idle_animation():
	# executar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")


func rotate_sprite():
	# ajustar direção do sprite
	if input_vector.x > 0 :
		sprite_2d.flip_h = false
	elif input_vector.x < 0 :
		sprite_2d.flip_h = true


func update_hitbox(delta):
	# reduz tempo de cooldown
	hitbox_cooldown -= delta
	
	#valida se tem algum tempo para seguir 
	if hitbox_cooldown > 0:
		return
	
	#atualiza cooldown
	hitbox_cooldown = 0.5
	
	#recebe dano dos inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy = body
			damage(enemy.hit_damage)


func damage(amount):
	if health <= 0:
		return
	
	health -= amount
	
	# piscar inimigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# matar o inimigo
	if health <= 0:
		die()

func die():
	GameManager.end_game()
	
	if death_scene:
		var death_object = death_scene.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()


func heal(amount):
	health += amount
	if health > max_health:
		health = max_health
