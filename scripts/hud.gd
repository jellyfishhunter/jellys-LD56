extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("TERMINATED")
	await $MessageTimer.timeout

	$Message.text = "MICROSLAYER"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func show_game_won():
	show_message("INFECTED")
	await $MessageTimer.timeout

	$Message.text = "MICROSLAYER"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func _on_message_timer_timeout():
	$Message.hide()

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()
