extends Node

@export var environment_scene: PackedScene
var environment: Node2D

func _ready() -> void:
	environment = environment_scene.instantiate()
	add_child(environment)

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

func _on_environment_player_won() -> void:
	$HUD.show_game_won()
	await get_tree().create_timer(1.0).timeout
	# TODO show credits?

func _on_environment_new_stage(stage: int, is_boss_stage: bool) -> void:
	if is_boss_stage:
		$HUD.show_message("STAGE " + str(stage + 1) + "\nINFECT THEM")
	else:
		$HUD.show_message("STAGE " + str(stage + 1) + "\nSLAY THEM ALL")
