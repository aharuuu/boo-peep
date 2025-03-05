extends Control



func _on_continue_button_pressed() -> void:
	$back_menu_ui.visible = false


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
