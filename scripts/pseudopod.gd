extends Node2D

func _ready() -> void:
	$Area2D.monitoring = false
	$AnimatedSprite2D.play("slap")
	await get_tree().create_timer(.15).timeout
	$Area2D.monitoring = true

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.hit(self)
