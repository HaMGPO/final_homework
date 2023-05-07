extends KinematicBody2D

const attack_cooldown = 0.4
const dash_speed = 700
const dash_duration = 0.3

var velocity = Vector2.ZERO
var stats = PlayerStats

const ACCELERATION = 50
const FRICTION = 500
const MAX_SPEED = 200
const DeathEffect = preload("res://effects/PlayerDeath.tscn")

onready var anim_player = $AnimationTree.get("parameters/playback")
onready var playerback =$AnimationPlayer
onready var sprite = $Sprite
onready var sword_box = $HitboxPivot
onready var hurbox = $Hurtbox
onready var dash = $Dash
onready var attackTimer = $AttackTimer


func _ready():
	stats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	var input_vector = get_move_direction()
	play_animation(input_vector)
	input_vector = input_vector.normalized()
	
	if Input.is_action_just_pressed("ui_dash") && !dash.is_dashing() && dash.can_dash:
		dash.start_dash(sprite, dash_duration)
		
	if Input.is_action_just_pressed("ui_attack"):# && !dash.is_dashing() && dash.can_dash:
		start_attack()
	
		
	var speed = dash_speed if dash.is_dashing() else MAX_SPEED #LLevamos a cabo el Dash
	speed = 0 if attack_in_progress() else speed #En caso de estar atacando, que se detenga el personaje en seco
	
	velocity = velocity.move_toward(input_vector * speed , ACCELERATION)
	velocity = move_and_slide(velocity)
	
func get_move_direction():
	return Vector2(
		int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed('ui_left')),
		int(Input.is_action_pressed('ui_down')) - int(Input.is_action_pressed('ui_up'))
	)
	
func play_animation(move_direction):
	if move_direction == Vector2.ZERO:
		anim_player.travel("iddle")
	else:
		sprite.flip_h = move_direction.x < 0
		sword_box.scale.x = -1 if move_direction.x < 0 else 1
		anim_player.travel("run")	
		
func start_attack():
	attackTimer.wait_time = attack_cooldown
	playerback.play("attack")
	attackTimer.start()
	
func attack_in_progress():
	return !attackTimer.is_stopped()

func create_deathEffect():
	var deathEffect = DeathEffect.instance()
	var world = get_tree().current_scene
	world.add_child(deathEffect)
	deathEffect.global_position = global_position

func _on_Hurtbox_area_entered(area):
	if !dash.is_dashing():
		take_damage(area.damage)
		print("ataque recibido en jugador, salud: "+str(stats.health))
		hurbox.start_invincibility(0.5)
		hurbox.create_Effect()
	
func take_damage(damage):
	stats.health -= damage
	if stats.health <= 0:
		create_deathEffect()
		get_tree().change_scene("res://ui/GameOverScreen.tscn")
		

