extends Node

@export var environment_scene: PackedScene
var environment: Node2D

func _ready() -> void:
	environment = environment_scene.instantiate()
	add_child(environment)
	if !$MainBGMPlayer.playing:
		$MainBGMPlayer.play()
	$StageBGMPlayer.stop()
	$BossBGMPlayer.stop()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("screenshot"):
			take_screenshot()

func _on_hud_start_game() -> void:
	if environment.game_is_over:
		environment.queue_free()
		environment = environment_scene.instantiate()
		add_child(environment)

	environment.connect("player_lost_rna", _on_environment_player_lost_rna)
	environment.connect("player_defeated", _on_environment_player_defeated)
	environment.connect("player_won", _on_environment_player_won)
	environment.connect("new_stage", _on_environment_new_stage)
	
	environment.start_game()

func _on_environment_player_lost_rna() -> void:
	pass # Replace with function body.

func _on_environment_player_defeated() -> void:
	$HUD.show_game_over()
	if !$MainBGMPlayer.playing:
		$MainBGMPlayer.play()
	$StageBGMPlayer.stop()
	$BossBGMPlayer.stop()

func _on_environment_player_won() -> void:
	$HUD.show_game_won()
	if !$MainBGMPlayer.playing:
		$MainBGMPlayer.play()
	$StageBGMPlayer.stop()
	$BossBGMPlayer.stop()
	await get_tree().create_timer(1.0).timeout
	# TODO show credits?

func _on_environment_new_stage(stage: int, is_boss_stage: bool) -> void:
	if is_boss_stage:
		$HUD.show_message("STAGE " + str(stage + 1) + "\nINFECT THEM")
		$MainBGMPlayer.stop()
		$StageBGMPlayer.stop()
		if !$BossBGMPlayer.playing:
			$BossBGMPlayer.play()
	else:
		$HUD.show_message("STAGE " + str(stage + 1) + "\nSLAY THEM ALL")
		$MainBGMPlayer.stop()
		if !$StageBGMPlayer.playing:
			$StageBGMPlayer.play()
		$BossBGMPlayer.stop()

func take_screenshot():
	var date = Time.get_date_string_from_system().replace(".", "_")
	var time: String = Time.get_time_string_from_system().replace(":", "")
	var screenshot_path = "res://" + "screenshot_" + date + "_" + time + ".jpg"
	var image = get_viewport().get_texture().get_image()
	image.save_jpg(screenshot_path)
