extends Node2D

@export var rna_scene: PackedScene
@export var stage_scene: PackedScene

var current_stage: TileMapLayer

func _ready() -> void:
	create_stage()

func _on_player_lost_rna() -> void:
	var rna = rna_scene.instantiate()
	rna.position = $Player.position
	add_child(rna)

func create_stage() -> void:
	var stage = stage_scene.instantiate()
	stage.player = $Player
	stage.enemy_count = 5
	add_child(stage)
	current_stage = stage
	current_stage.connect("all_enemies_defeated", _on_stage_all_enemies_defeated)

func _on_stage_all_enemies_defeated() -> void:
	current_stage.open_gates()