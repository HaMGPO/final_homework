extends Node2D

const dash_cooldown = 0.4 

onready var durationTimer = $DurationTimer
onready var ghostTimer = $GhostTimer
var ghost_scene = preload("res://player/DashGhost.tscn")
var can_dash = true
var sprite

func start_dash(sprite, duration):
	self.sprite = sprite
	#sprite.material.set_shader_param("min_weigth", 0.7)
	#sprite.material.set_shader_param("whiten", true)
	#print("dash iniciado")
	durationTimer.wait_time = duration
	
	durationTimer.start()
	ghostTimer.start()
	
	instance_ghost()
	
func instance_ghost():
	var ghost: Sprite = ghost_scene.instance()
	get_parent().get_parent().add_child(ghost)
	
	ghost.global_position = global_position
	ghost.texture = sprite.texture 
	ghost.vframes = sprite.vframes
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	
func is_dashing():
	return !durationTimer.is_stopped()

func end_dash():
	ghostTimer.stop()
	
	can_dash = false
	yield(get_tree().create_timer(dash_cooldown), "timeout")
	can_dash = true

func _on_DurationTimer_timeout():
	end_dash()


func _on_GhostTimer_timeout():
	instance_ghost()
