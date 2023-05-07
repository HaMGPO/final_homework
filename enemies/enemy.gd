extends KinematicBody2D

onready var stats = $Stats
onready var detectionPlayerZone = $PlayerDetection
onready var animatedSprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var actionTimer = $ActionTimer
onready var attackTimer = $AttackTimer
onready var attackWindow = $AttackWindow

const DeathEffect = preload("res://effects/AngelDeath.tscn")
const halfHealthEffect = preload("res://effects/halfHealthEffect.tscn")

enum{
	IDDLE,
	ATTACK,
	CHASE
}

export var ACCELERATION = 300
export var MAX_SPEED = 150
export var FRICTION = 200

export(PackedScene) var RANGE:PackedScene = preload("res://enemies/attacks/RangeAttack.tscn")
export(PackedScene) var AREA:PackedScene = preload("res://enemies/attacks/AreaAttack.tscn")
export(PackedScene) var MELEE:PackedScene = preload("res://enemies/attacks/MeleeAttack.tscn")

var rng = RandomNumberGenerator.new()
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var attacks_list = ["BASIC", "RANGE", "AREA", "CANALIZATION"] #Posibles ataques
var attacks_val = [1, 1, 1, 1] # n5 posibilidades de que se realice un ataque
var actions_list = [IDDLE, ATTACK, CHASE] #Posibles acciones
var actions_val = [1, 10, 2] #posibilidades de que se realice una accion
var state = ATTACK  
var time_between_attacks = 2
var time_between_actions = 2
var on_melee_attack = false
var objective
var half_health = false

signal boss_health_changed

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	action_cicle()
	
	match state:
		IDDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			animatedSprite.play("Fly")
					
		ATTACK:
			animatedSprite.play("attack")
			attack_cicle(delta)
			
		CHASE:
			objective = detectionPlayerZone.player
			if objective and  PlayerStats.health > 0:
				var direction = (objective.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			animatedSprite.flip_h = velocity.x < 0
			
	velocity = move_and_slide(velocity)
	
	if on_melee_attack:
		if objective and PlayerStats.health > 0:
			var distance = objective.global_position.distance_to(self.global_position)
			MAX_SPEED = 400
			if distance < 100:
				melee_attack()
		else:
			MAX_SPEED = 150\
			
							
							
	
func _on_Hurtbox_area_entered(area):
	take_damage(area.damage)
	hurtbox.create_Effect()

func take_damage(damage):
	stats.health -= damage
	
func create_deathEffect():
	var deathEffect = DeathEffect.instance()
	var world = get_tree().current_scene
	world.add_child(deathEffect)
	deathEffect.global_position = global_position

func _on_Stats_no_health():
	create_deathEffect()
	queue_free()
	
	
func attack_cicle(delta):
	var attack
	if !is_attacking():
		start_attack(time_between_attacks)
		attack = choose_element(attacks_list, attacks_val)
		execute_attack(attack, delta)
		
func action_cicle():
	if !is_on_action():
		start_action(time_between_actions)
		state = choose_element(actions_list, actions_val)
	
func choose_element(opciones, pesos):
	var suma_pesos = 0
	for peso in pesos:
		suma_pesos += peso

	var numero_aleatorio = randi() % suma_pesos
	var acumulado = 0
	for i in range(opciones.size()):
		acumulado += pesos[i]
		if numero_aleatorio < acumulado:
			return opciones[i]
	return opciones[opciones.size() - 1]
	
func start_attack(duration):
	attackTimer.wait_time = duration
	attackTimer.start()
	
	
func start_action(duration):
	actionTimer.wait_time = duration
	actionTimer.start()
	
func is_attacking():
	return !attackTimer.is_stopped()
	
func is_on_action():
	return !actionTimer.is_stopped()
	
func generate_attack_range(list_of_angles):
	for x in 4:
		yield(get_tree().create_timer(0.1), "timeout")
		for angle in list_of_angles:
			attack_range(angle)
		
func attack_range(extra_degree):
	if RANGE:
		var ranged_attack = RANGE.instance()
		get_tree().current_scene.add_child(ranged_attack)
		ranged_attack.global_position = global_position
		
		if objective and PlayerStats.health > 0:
			var dagger_rotation = global_position.direction_to(objective.global_position).angle() +deg2rad(extra_degree)
			ranged_attack.rotation = dagger_rotation

func attack_area():
	if AREA:
		var area_attack = AREA.instance()
		get_tree().current_scene.add_child(area_attack)
		
		if objective and PlayerStats.health > 0:	
			area_attack.global_position = objective.global_position
	
func generate_attack_canalization(amount:int):
	for x in amount:
		yield(get_tree().create_timer(0.1), "timeout")
		attack_canalization_instance(Vector2(rng.randi_range (-200, 800), rng.randi_range (0, 700)))
		
func attack_canalization_instance(position):
	if AREA:
		var area_attack = AREA.instance()
		get_tree().current_scene.add_child(area_attack)
		area_attack.global_position = position	
	
func melee_attack():
	if MELEE:
		var melee = MELEE.instance()
		get_tree().current_scene.add_child(melee)
		melee.global_position = global_position - Vector2(0, -70)
		on_melee_attack = false	
	
			
func execute_attack(attack_selected:String, delta):
	match attack_selected:
		"BASIC":
			state = CHASE
			on_melee_attack = true
			
		"RANGE":
			generate_attack_range([0, 20, 10, -10, -20])
			
		"AREA":
			attack_area()
			
		"CANALIZATION":
			generate_attack_canalization(30)

func create_halfHealth_effect():
	var halfHealthEffect = DeathEffect.instance()
	var world = get_tree().current_scene
	world.add_child(halfHealthEffect)
	halfHealthEffect.global_position = global_position

func _on_Stats_half_health():
	create_halfHealth_effect()
	half_health = true

