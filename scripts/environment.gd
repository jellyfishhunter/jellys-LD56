extends Node2D

signal player_lost_rna
signal player_defeated

@export var rna_scene: PackedScene
@export var stage_scenes: Array = [PackedScene]
@export var boss_stage_scene: PackedScene
@export var stages_count = 5
@export var starting_enemies = 8

var current_stage: TileMapLayer
var rna: Area2D
var game_is_over = false
var played_stages = 0

func _ready() -> void:
	create_stage()

func start_game() -> void:
	enter_stage()

func create_stage() -> void:
	# select random stage
	var stage: TileMapLayer
	if (played_stages + 1) == stages_count:
		stage = boss_stage_scene.instantiate()
	else:
		var stage_scene = stage_scenes[randi() % stage_scenes.size()]
		stage = stage_scene.instantiate()

	stage.player = $Player
	stage.enemy_count = starting_enemies + (played_stages * 3)
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
		played_stages += 1
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
	player_lost_rna.emit()

func _on_player_defeated() -> void:
	player_defeated.emit()
	game_is_over = true
