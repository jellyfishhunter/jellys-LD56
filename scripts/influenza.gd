extends CharacterBody2D

signal defeated

@export var speed = 50

var player_node: Node2D
var is_knocked_back = false

enum State {IDLE, WALK, ATTACK, DEAD}
var state := State.IDLE

enum PlayerDetection {OUTOFREACH, INALERTAREA, INATTACKAREA}
var player_detection := PlayerDetection.OUTOFREACH

func _ready():
	$AnimatedSprite2D.play("idle")
	# Disable monitoring while the game is loading
	$AlertArea.monitoring = false
	await get_tree().create_timer(1.0).timeout
	$AlertArea.monitoring = true

func add_player(player: Node2D):
	player_node = player

func _process(_delta):
	if !is_knocked_back:
		velocity = Vector2()

	if state == State.WALK:
		# Move towards the player
		var direction = (player_node.global_position - global_position).normalized()
		velocity = direction * speed

		if direction.x > 0.5:
			$AnimatedSprite2D.play("walk_right")
		elif direction.x < -0.5:
			$AnimatedSprite2D.play("walk_left")
		elif direction.y < 0:
			$AnimatedSprite2D.play("walk_up")
		elif direction.y > 0:
			$AnimatedSprite2D.play("walk_down")
		else:
			$AnimatedSprite2D.play("idle")
	
	move_and_slide()

func attack():
	state = State.ATTACK
	$AnimatedSprite2D.play("attack")
	await get_tree().create_timer(1.0).timeout
	for spike in $SpikeHolder.get_children():
		if spike.is_prepared:
			spike.stab()
	$AttackSFX.play()

func hit(spike: Node2D):
	if state == State.DEAD:
		return
	state = State.DEAD
	$AnimatedSprite2D.play("death")
	$ParticleBurster.burst()
	$HurtSFX.play()

	# knockback from source
	var knockback = (global_position - spike.global_position).normalized() * 100
	velocity = knockback
	is_knocked_back = true
	await get_tree().create_timer(0.5).timeout
	is_knocked_back = false

func _on_alert_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_detection = PlayerDetection.INALERTAREA
		if state == State.IDLE:
			state = State.WALK

func _on_alert_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_detection = PlayerDetection.OUTOFREACH

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_detection = PlayerDetection.INATTACKAREA
		if state != State.ATTACK:
			attack()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_detection = PlayerDetection.INALERTAREA

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == State.ATTACK:
		if player_detection == PlayerDetection.INATTACKAREA:
			attack()
		elif player_detection == PlayerDetection.INALERTAREA:
			state = State.WALK
		else:
			state = State.IDLE
			$AnimatedSprite2D.play("idle")
	elif state == State.DEAD:
		defeated.emit()
		queue_free()
