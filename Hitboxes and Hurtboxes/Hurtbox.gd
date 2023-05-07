extends Area2D

const HitEffect = preload("res://effects/HitEffect.tscn")

var invincible = false

signal invincibility_started  
signal invincibility_ended

onready var timer = $Timer
	
func create_Effect():
	var deathEffect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(deathEffect)
	deathEffect.global_position = global_position - Vector2(0, 8)

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
		
func start_invincibility(duration):
	set_invincible(true)
	timer.start(duration)

func _on_Timer_timeout():
	self.invincible = false

func _on_Hurtbox_invincibility_ended():
	monitorable = true	

func _on_Hurtbox_invincibility_started():
	 set_deferred("monitorable", false)
