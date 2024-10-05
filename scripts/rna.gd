extends Area2D

var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size

	monitoring = false

	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var random_distance = randi_range(80, 100)
	var target_position = position + random_direction * random_distance
	target_position = target_position.clamp(Vector2.ZERO, screen_size)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, .4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(on_tween_completed)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.collect_rna()
		queue_free()

func on_tween_completed():
	monitoring = true