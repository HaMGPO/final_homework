extends "res://Hitboxes and Hurtboxes/Hitbox.gd"


export(int) var SPEED:int = 500

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += SPEED * direction * delta

func destroy():
	queue_free()

func _on_RangeAttack_area_entered(area):
	destroy()

func _on_RangeAttack_body_entered(body):
	destroy()

func _on_VisibilityNotifier2D_screen_exited():
	destroy()
