extends CharacterBody2D
signal lost_rna
signal gained_rna
signal defeated

@export var speed = 100
var screen_size
var direction := Vector2()
var is_attacking = false
var is_knocked_back = false
var has_rna = true

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play("idle_default")

func _process(_delta):
	if !is_knocked_back:
		velocity = Vector2()
		
	if !is_attacking:
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
			direction = direction.normalized()
			$SpikeHolder.rotation = direction.angle()
			velocity = direction * speed
	
	elif $SpikeHolder/PlayerSpike.is_prepared:
		is_attacking = false

	if has_rna and Input.is_action_just_pressed("attack") and $SpikeHolder/PlayerSpike.is_prepared:
		$SpikeHolder/PlayerSpike.stab()
		is_attacking = true

	move_and_slide()
	update_animation()

func update_animation():
	if is_attacking or is_knocked_back:
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

func hit(spike: Node2D):
	if has_rna:
		call_deferred("lose_rna")
	else:
		defeated.emit()
		# TODO death animation and game over
	
	# knockback from source
	var knockback = (global_position - spike.global_position).normalized() * 100
	velocity += knockback
	is_knocked_back = true
	await get_tree().create_timer(0.5).timeout
	is_knocked_back = false

func lose_rna():
	if has_rna:
		has_rna = false
		lost_rna.emit()

func collect_rna():
	has_rna = true
	gained_rna.emit()