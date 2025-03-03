extends Node2D

func _process(delta: float) -> void:
	var back_menu_ui = $back_menu/back_menu_ui

	if Input.is_action_just_pressed("back_key"):
		back_menu_ui.visible = true
		 
	if back_menu_ui.visible:
		$/root/game/seeker.set_process_input(false)
