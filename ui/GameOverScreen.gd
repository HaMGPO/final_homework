extends CanvasLayer


func _on_QUIT_pressed():
	get_tree().quit()

func _on_RESTART_pressed():
	get_tree().change_scene("res://World.tscn")
	
