extends Node2D

@export var rna_scene: PackedScene

func _ready() -> void:
	for enemy in $Enemies.get_children():
		enemy.add_player($Player)

func _on_player_lost_rna() -> void:
	var rna = rna_scene.instantiate()
	rna.position = $Player.position
	add_child(rna)
