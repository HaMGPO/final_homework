extends "res://Hitboxes and Hurtboxes/Hitbox.gd"


onready var animation = $AnimatedSprite
onready var hitbox = $AnimationPlayer

func _ready():
	animation.frame = 0
	animation.play("animate")
	hitbox.play("animate")

func destroy():
	queue_free()

func _on_AnimatedSprite_animation_finished():
	destroy()
