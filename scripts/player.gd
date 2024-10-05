extends Node2D
signal hit

@export var speed = 100
var screen_size
var direction := Vector2()
var isAttacking = false

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play("idle_default")

func _process(delta):
	if !isAttacking:
		direction = Vector2()
		if Input.is_action_pressed("move_right"):
			direction.x += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_down"):
			direction.y += 1
		if Input.is_action_pressed("move_up"):
			direction.y -= 1

		if direction.length() > 0:
			direction = direction.normalized() * speed
			$SpikeHolder.rotation = direction.angle()
			position += direction * delta
			position = position.clamp(Vector2.ZERO, screen_size)
	elif $SpikeHolder/PlayerSpike.isPrepared:
		isAttacking = false

	if Input.is_action_just_pressed("attack") and $SpikeHolder/PlayerSpike.isPrepared:
		$SpikeHolder/PlayerSpike.stab()
		isAttacking = true

	update_animation()

func update_animation():
	if isAttacking:
		$AnimatedSprite2D.play("attack")
	elif direction.x != 0:
		$AnimatedSprite2D.play("walk_right")
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = direction.x < 0
	elif direction.y < 0:
		$AnimatedSprite2D.play("walk_up")
	elif direction.y > 0:
		$AnimatedSprite2D.play("walk_down")
	else:
		$AnimatedSprite2D.play("idle_default")
