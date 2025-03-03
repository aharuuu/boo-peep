extends TextureProgressBar


func _on_ui_tag_timer_timeout() -> void:
	$/root/game/seeker/seeker_ui/ui_cooldowns/ui_tag.value += 0.1
