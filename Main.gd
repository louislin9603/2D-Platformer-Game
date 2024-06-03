extends Node2D



func _on_ready():
	#DisplayServer.window_set_size(Vector2i(1920, 1080))
	get_tree().change_scene_to_file("res://world.tscn")
	
func _input(event):
	if event.is_action_pressed("ui_escape"): 
		get_tree().quit()
		
