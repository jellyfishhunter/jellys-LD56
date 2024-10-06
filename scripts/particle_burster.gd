extends Node2D

@export var particle_burst_scene: PackedScene
@export var color: Color

func burst() -> void:
	var particle_burst = particle_burst_scene.instantiate()
	particle_burst.process_material.color = color
	add_child(particle_burst)
	particle_burst.emitting = true
	particle_burst.one_shot = true
	await get_tree().create_timer(1.0).timeout
	particle_burst.queue_free()