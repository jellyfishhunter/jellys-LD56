extends Node2D

@export var speed = 50
var screen_size
var player_node: Node2D

enum State {IDLE, WALK, ATTACK, DEAD}
var state := State.IDLE

enum PlayerDetection {OUTOFREACH, INALERTAREA, INATTACKAREA}
var player_detection := PlayerDetection.OUTOFREACH

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play("idle")

# will be called from a global script
func add_player(player: Node2D):
	player_node = player

func _process(delta):
	if state == State.WALK:
		# Move towards the player
		var direction = (player_node.global_position - global_position).normalized()
		position += direction * speed * delta

		if direction.x > 0.5:
			$AnimatedSprite2D.play("walk_right")
		elif direction.x < 0.5:
			$AnimatedSprite2D.play("walk_left")
		elif direction.y < 0:
			$AnimatedSprite2D.play("walk_up")
		elif direction.y > 0:
			$AnimatedSprite2D.play("walk_down")
		else:
			$AnimatedSprite2D.play("idle")

func attack():
	state = State.ATTACK
	$AnimatedSprite2D.play("attack")
	await get_tree().create_timer(1.0).timeout
	for spike in $SpikeHolder.get_children():
		if spike.is_prepared:
			spike.stab()

func _on_alert_area_body_entered(body: Node2D) -> void:
	if body.name == "PlayerBody":
		player_detection = PlayerDetection.INALERTAREA
		if state == State.IDLE:
			state = State.WALK

func _on_alert_area_body_exited(body: Node2D) -> void:
	if body.name == "PlayerBody":
		player_detection = PlayerDetection.OUTOFREACH

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "PlayerBody":
		player_detection = PlayerDetection.INATTACKAREA
		attack()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "PlayerBody":
		player_detection = PlayerDetection.INALERTAREA

func _on_rigid_body_2d_body_entered(body: Node) -> void:
	# TODO if hit by player spike, change state to DEAD and play death animation
	pass # Replace with function body.

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
		queue_free()
