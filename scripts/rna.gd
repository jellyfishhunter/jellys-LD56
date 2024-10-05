extends Area2D

var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size

	# we wait a bit to avoid the player collecting the RNA immediately
	monitoring = false
	await get_tree().create_timer(.5).timeout
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.collect_rna()
		queue_free()
