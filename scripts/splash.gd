extends Control

func _process(delta):
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
