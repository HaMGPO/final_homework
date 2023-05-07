extends Node

export(int) var damage = 25
export(int) var max_health = 100 setget set_max_health
var health = max_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal half_health

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)
	
		
func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
	if health <= (max_health / 2 ):
		print("mitad de vida")
		emit_signal("half_health")
		
func _ready():
	self.health = max_health
