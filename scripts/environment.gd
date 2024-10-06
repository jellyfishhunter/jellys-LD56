extends Node2D

signal player_lost_rna
signal player_defeated
signal player_won
signal new_stage

@export var rna_scene: PackedScene
@export var stage_scenes: Array = [PackedScene]
@export var boss_stage_scene: PackedScene
@export var stages_count = 5
@export var starting_enemies = 8

var current_stage: TileMapLayer
var rna: Area2D
var game_is_over = false
var played_stages = 0
var is_boss_stage = false

func _ready() -> void:
	create_stage()

func start_game() -> void:
	enter_stage()

func create_stage() -> void:
	# select random stage
	var stage: TileMapLayer
	if (played_stages + 1) == stages_count:
		stage = boss_stage_scene.instantiate()
		is_boss_stage = true
	else:
		var stage_scene = stage_scenes[randi() % stage_scenes.size()]
		stage = stage_scene.instantiate()

	stage.player = $Player
	stage.enemy_count = starting_enemies + (played_stages * 3)
	$StageHolder.add_child(stage)
	current_stage = stage
	current_stage.connect("all_enemies_defeated", _on_stage_all_enemies_defeated)

func enter_stage() -> void:
	current_stage.open_gates()
	$Player.position = $EntryPoint.position
	$Player.is_entering_stage = true
	new_stage.emit(played_stages, is_boss_stage)
	call_deferred("set_entry_monitoring", true)

func set_entry_monitoring(value: bool) -> void:
	$EntryArea.monitoring = value

func _on_entry_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Player.is_entering_stage = false
		call_deferred("set_entry_monitoring", false)
		current_stage.close_gates()

func _on_stage_all_enemies_defeated() -> void:
	if !is_boss_stage:
		current_stage.open_gates()
		current_stage.block_rear()
	else:
		player_won.emit()
		game_is_over = true

func _on_exit_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		played_stages += 1
		current_stage.queue_free()
		call_deferred("proceed_to_next_stage")

		body.collect_rna()
		if is_instance_valid(rna):
			rna.queue_free()

func proceed_to_next_stage() -> void:
	create_stage()
	enter_stage()

func _on_player_lost_rna() -> void:
	rna = rna_scene.instantiate()
	rna.position = $Player.position
	add_child(rna)
	player_lost_rna.emit()

func _on_player_defeated() -> void:
	player_defeated.emit()
	game_is_over = true
