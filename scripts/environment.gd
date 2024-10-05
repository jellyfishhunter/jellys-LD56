extends Node2D

@export var rna_scene: PackedScene
@export var stage_scenes: Array = [PackedScene]
@export var boss_stage_scene: PackedScene

var current_stage: TileMapLayer
var rna: Area2D

func _ready() -> void:
	create_stage()
	enter_stage()

func create_stage() -> void:
	# select random stage
	var stage_scene = stage_scenes[randi() % stage_scenes.size()]
	var stage = stage_scene.instantiate()
	stage.player = $Player
	stage.enemy_count = 5
	add_child(stage)
	current_stage = stage
	current_stage.connect("all_enemies_defeated", _on_stage_all_enemies_defeated)

func enter_stage() -> void:
	current_stage.open_gates()
	$Player.position = $EntryPoint.position
	$Player.is_entering_stage = true

func _on_entry_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Player.is_entering_stage = false
		current_stage.close_gates()

func _on_stage_all_enemies_defeated() -> void:
	current_stage.open_gates()
	current_stage.block_rear()

func _on_exit_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		current_stage.queue_free()
		create_stage()
		enter_stage()
		
		body.collect_rna()
		if is_instance_valid(rna):
			rna.queue_free()

func _on_player_lost_rna() -> void:
	rna = rna_scene.instantiate()
	rna.position = $Player.position
	add_child(rna)
