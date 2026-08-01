extends CharacterBody2D

@export var max_hp: int = 30
var current_hp: int
@export var coin_scene: PackedScene = preload("res://item/coin.tscn") # 👈 เช็ก Path ให้ตรงกับไฟล์ coin.tscn ของคุณ

# 🎲 ตั้งค่าโอกาสดรอป (0.0 ถึง 1.0 -> 0.7 คือ 70%)
@export_range(0.0, 1.0) var drop_chance: float = 1 

# 💰 สุ่มจำนวนเหรียญที่จะดรอป (เช่น สุ่มดรอป 1 ถึง 3 เหรียญ)
@export var min_coins: int = 1
@export var max_coins: int = 3
@export var damage: int = 20
@export var speed: float = 80.0
@export var detection_range: float = 100.0
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 3

@export var knockback_force: float = 200.0
@export var knockback_up_force: float = -100.0
var is_knocked_back: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

# 🎯 เรียกใช้งาน Node แถบเลือด
@onready var hp_bar: ProgressBar = $HPBar

var player: Node2D = null
var is_attacking: bool = false
var cooldown_timer: float = 0.0

func _ready() -> void:
	current_hp = max_hp
	hitbox_collision.disabled = true
	
	# 🩸 เซ็ตค่าเริ่มต้นให้แถบเลือด
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_knocked_back:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 5)
		move_and_slide()
		return

	if cooldown_timer > 0:
		cooldown_timer -= delta

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
		return

	if player:
		var distance = global_position.distance_to(player.global_position)
		var diff_x = player.global_position.x - global_position.x
		var direction_x = sign(diff_x)
		
		if diff_x != 0:
			update_facing_direction(direction_x)

		if abs(diff_x) <= attack_range:
			if cooldown_timer <= 0:
				start_attack()
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
		elif distance <= detection_range:
			velocity.x = direction_x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	update_animations()

# 🎯 ฟังก์ชันรับดาเมจ + อัปเดตแถบเลือด
func take_damage(amount: int, attacker_position: Vector2 = Vector2.ZERO) -> void:
	current_hp -= amount
	
	# 🩸 อัปเดตค่าของแถบเลือดตาม HP ที่เหลือ
	if hp_bar:
		hp_bar.value = current_hp

	# กระพริบสีแดงเมื่อโดนตี
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color.RED, 0.1)
	tween.tween_property(anim, "modulate", Color.WHITE, 0.1)

	if attacker_position != Vector2.ZERO:
		var knockback_direction = sign(global_position.x - attacker_position.x)
		if knockback_direction == 0:
			knockback_direction = 1
			
		velocity.x = knockback_direction * knockback_force
		velocity.y = knockback_up_force
		
		apply_knockback_stun(0.2)

	if current_hp <= 0:
		die()

func apply_knockback_stun(duration: float) -> void:
	is_knocked_back = true
	is_attacking = false
	hitbox_collision.disabled = true
	
	await get_tree().create_timer(duration).timeout
	is_knocked_back = false

func die() -> void:
	drop_coins()
	queue_free()

func start_attack() -> void:
	is_attacking = true
	cooldown_timer = attack_cooldown
	velocity.x = 0
	anim.play("attack")

func update_facing_direction(dir_x: float) -> void:
	if is_attacking or is_knocked_back:
		return
	if dir_x < 0:
		anim.flip_h = true
		hitbox.scale.x = -1
	elif dir_x > 0:
		anim.flip_h = false
		hitbox.scale.x = 1

func update_animations() -> void:
	if is_attacking or is_knocked_back:
		return

	if abs(velocity.x) > 0:
		anim.play("walk")
	else:
		anim.play("idle")

func _on_animated_sprite_2d_frame_changed() -> void:
	if anim.animation == "attack" and not is_knocked_back:
		if anim.frame == 5:
			hitbox_collision.disabled = false
		elif anim.frame > 5:
			hitbox_collision.disabled = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		hitbox_collision.disabled = true
		is_attacking = false

func drop_coins() -> void:
	if randf() > drop_chance:
		return
		
	if coin_scene == null:
		return

	var coin_count = randi_range(min_coins, max_coins)

	for i in range(coin_count):
		var coin_instance = coin_scene.instantiate()
		get_parent().add_child(coin_instance)
		
		# 🎯 ปรับให้สุ่ม X ซ้าย-ขวา แต่ Y ให้ลอยขึ้นไปข้างบนเสมอ (-20 ถึง -5)
		var random_offset = Vector2(randf_range(-25, 25), randf_range(-20, -5))
		
		# เสกเหรียญให้อยู่เหนือน้ำหนักจุดศูนย์กลางศัตรูเล็กน้อย
		coin_instance.global_position = global_position + random_offset
