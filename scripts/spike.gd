extends Node2D

var isPrepared = true

func _ready() -> void:
	hide()

func stab() -> void:
	if isPrepared:
		show()
		$AnimatedSprite2D.play("stab")
		isPrepared = false

func _on_animated_sprite_2d_animation_finished() -> void:
	isPrepared = true
	hide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	# stab enemy or player
	pass
