extends StaticBody2D

signal defeated

@export var pseudopod_scene: PackedScene
@export var life = 12
@export var attack_count = 8

var player_node: Node2D

enum State {IDLE, AIM, ATTACK, DEAD}
var state := State.IDLE

var is_hurt = false

func _ready() -> void:
	$Offspring.hide()
	$AnimatedSprite2D.play("idle")

func add_player(player: Node2D):
	player_node = player

func start():
	# Wait for a moment before starting
	await get_tree().create_timer(2.0).timeout
	idle()

func idle():
	state = State.IDLE
	$AnimatedSprite2D.play("idle")
	await get_tree().create_timer(2.0).timeout
	if state == State.IDLE:
		aim()

func aim():
	state = State.AIM
	await get_tree().create_timer(1.0).timeout
	if state == State.AIM:
		attack()

func attack():
	state = State.ATTACK
	$AnimatedSprite2D.play("attack")

	var direction = (player_node.global_position - global_position).normalized()
	pseudopod_attack(direction)
	pseudopod_attack(direction.rotated(PI / 8))
	pseudopod_attack(direction.rotated(-PI / 8))

	await get_tree().create_timer(1.0).timeout
	if state == State.ATTACK:
		idle()

func pseudopod_attack(direction: Vector2):
	for i in range(attack_count):
		var pseudopod = pseudopod_scene.instantiate()
		add_child(pseudopod)
		pseudopod.global_position = global_position + direction * 16 * (i + 1)
		await get_tree().create_timer(.1).timeout

func _process(_delta):
	if state == State.IDLE:
		if is_hurt:
			$AnimatedSprite2D.play("hurt")
		else:
			$AnimatedSprite2D.play("idle")
	if state == State.AIM:
		if is_hurt:
			$AnimatedSprite2D.play("hurt")
		else:
			# Look towards the player
			var direction = (player_node.global_position - global_position).normalized()
			if direction.x > 0.5:
				$AnimatedSprite2D.play("right")
			elif direction.x < -0.5:
				$AnimatedSprite2D.play("left")
			elif direction.y < 0:
				$AnimatedSprite2D.play("up")
			elif direction.y > 0:
				$AnimatedSprite2D.play("down")

func hit(_spike: Node2D):
	life -= 1
	if life <= 0:
		die()
	is_hurt = true
	await get_tree().create_timer(.2).timeout
	is_hurt = false

func die():
	if state == State.DEAD:
		return
	state = State.DEAD
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1.0).timeout
	$Offspring.show()
	await get_tree().create_timer(.8).timeout
	$AnimatedSprite2D.hide()
	defeated.emit()
