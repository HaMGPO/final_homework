extends Node2D

func create_deathEffect():
	var DeathEffect = load("res://effects/SkullDeath.tscn")
	var deathEffect = DeathEffect.instance()
	var world = get_tree().current_scene
	world.add_child(deathEffect)
	deathEffect.global_position = global_position

func _on_Hurtbox_area_entered(area):
	create_deathEffect()
	queue_free()
