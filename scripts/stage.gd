extends TileMapLayer

signal all_enemies_defeated

@export var influenza_scene: PackedScene

var enemy_count = 0
var is_boss_stage = false
var player: CharacterBody2D

func _ready() -> void:
	var spawn_points = $EnemySpawnPositions.get_children()
	spawn_points.shuffle()
	spawn_points = spawn_points.slice(0, enemy_count)

	for spawn_point in spawn_points:
		var enemy = influenza_scene.instantiate()
		enemy.position = spawn_point.position
		enemy.add_player(player)
		enemy.connect("defeated", _on_enemy_defeated)
		call_deferred("add_child", enemy)

func open_gates() -> void:
	$GateLayer.enabled = false

func close_gates() -> void:
	$GateLayer.enabled = true

func block_rear() -> void:
	$RearBlocker.enabled = true

func _on_enemy_defeated() -> void:
	enemy_count -= 1
	if enemy_count == 0 and !is_boss_stage:
		all_enemies_defeated.emit()
