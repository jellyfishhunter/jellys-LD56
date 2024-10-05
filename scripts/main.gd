extends Node

func _on_hud_start_game() -> void:
	$Environment.start_game()
	$HUD.show_message("SLAY THEM ALL")
