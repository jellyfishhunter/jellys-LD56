extends Node2D

var is_prepared = true
var is_player = false

func _ready() -> void:
	hide()
	$Area2D.monitoring = false
	is_player = find_parent("Player") != null

func stab() -> void:
	if is_prepared:
		show()
		$Area2D.monitoring = true
		$AnimatedSprite2D.play("stab")
		is_prepared = false

func _on_animated_sprite_2d_animation_finished() -> void:
	is_prepared = true
	hide()
	$Area2D.monitoring = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	# stab enemy or player
	if is_player:
		if body.is_in_group("Enemy"):
			body.hit(self)
	else:
		if body.name == "Player":
			body.hit(self)
