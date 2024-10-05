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
	environment.start_game()

	environment.connect("player_lost_rna", _on_environment_player_lost_rna)
	environment.connect("player_defeated", _on_environment_player_defeated)

	$HUD.show_message("SLAY THEM ALL")

func _on_environment_player_lost_rna() -> void:
	pass # Replace with function body.

func _on_environment_player_defeated() -> void:
	$HUD.show_game_over()
	await get_tree().create_timer(1.0).timeout
