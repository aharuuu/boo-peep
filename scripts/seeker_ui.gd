extends CanvasLayer

func _on_ui_dash_timer_timeout() -> void:
	$ui_cooldowns/ui_dash.value += 0.1

func _on_ui_tag_timer_timeout() -> void:
	$ui_cooldowns/ui_tag.value += 0.1
