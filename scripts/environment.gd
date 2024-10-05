extends Node2D

func _ready() -> void:
	# foreach child in $Enemies
	for enemy in $Enemies.get_children():
		enemy.add_player($Player)
