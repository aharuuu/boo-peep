extends CanvasLayer


func _on_ui_cloak_timer_timeout() -> void:
	$ui_center/ui_cooldowns/ui_cloak.value += 0.1
