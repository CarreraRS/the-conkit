extends CharacterBody2D

@export var max_hp: int = 100
var current_hp: int
var is_dead: bool = false # 💀 สถานะการตาย

# ⚡ ระบบ Stamina
@export var stamina_jump_cost = 10.0
@export var max_stamina: float = 100.0
@export var stamina_attack_cost: float = 20.0
@export var stamina_regen_rate: float = 15.0
@export var stamina_regen_delay: float = 1.0

var current_stamina: float
var stamina_delay_timer: float = 0.0

@export var attack_damage: int = 10
const SPEED = 100.0
const JUMP_VELOCITY = -300.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

# 🎯 อ้างอิง UI
@onready var hp_bar: ProgressBar = $CanvasLayer/HPBar
@onready var stamina_bar: ProgressBar = $CanvasLayer/StaminaBar
@onready var game_over_ui = $CanvasLayer/GameOverUI
@onready var coin_label: Label = $CanvasLayer/CoinLabel

var is_attacking: bool = false

func _ready() -> void:
	max_hp += GameData.bonus_hp
	max_stamina += GameData.bonus_stamina
	attack_damage += GameData.bonus_damage

	current_hp = max_hp
	current_stamina = max_stamina
	attack_collision.disabled = true
	
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
		
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina

	# 🪙 อัปเดตแสดงเหรียญเริ่มต้น
	update_coin_ui()

func _process(_delta: float) -> void:
	# 🪙 คอยอัปเดตตัวเลขเหรียญบนหน้าจอให้เป็นปัจจุบันเสมอ
	update_coin_ui()

func update_coin_ui() -> void:
	if coin_label:
		coin_label.text = "Meow Coins: " + str(GameData.get_display_coins())

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	handle_stamina_regen(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# ⚔️ กดปุ่มโจมตี
	if Input.is_action_just_pressed("attack") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_stamina >= stamina_attack_cost:
			start_attack()
		else:
			print("Stamina ไม่พอฟัน!")
		return

	# 🦘 กดปุ่มกระโดด
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if current_stamina >= stamina_jump_cost:
			velocity.y = JUMP_VELOCITY
			
			current_stamina -= stamina_jump_cost
			if current_stamina < 0:
				current_stamina = 0
			stamina_delay_timer = stamina_regen_delay
			
			if stamina_bar:
				stamina_bar.value = current_stamina
		else:
			print("Stamina ไม่พอกระโดด!")

	var direction := Input.get_axis("walk_left", "walk_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if direction < 0:
			anim.flip_h = true
			attack_area.scale.x = -1
		elif direction > 0:
			anim.flip_h = false
			attack_area.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animations(direction)

func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_hp -= amount
	if current_hp < 0:
		current_hp = 0

	# 🩸 อัปเดตแถบเลือด UI
	if hp_bar:
		hp_bar.value = current_hp

	# เอฟเฟกต์กระพริบสีแดง
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color.RED, 0.1)
	tween.tween_property(anim, "modulate", Color.WHITE, 0.1)

	# 💀 เช็กว่าเลือดหมดหรือยัง
	if current_hp <= 0:
		die()

# 💀 ฟังก์ชันเมื่อ Player ตาย (แก้ไขจุดนี้)
func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	is_attacking = false
	velocity.x = 0
	
	# ปิด Collision ของตัวละคร และการโจมตี
	attack_collision.disabled = true
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.set_deferred("disabled", true)

	# 🎵 สั่งหยุดเพลงประกอบด่าน (BGM) ทั้งหมดในกลุ่ม "bgm"
	get_tree().call_group("bgm", "stop")

	# เล่น Animation ตาย
	if anim.sprite_frames.has_animation("death"):
		anim.play("death")
	else:
		# แผนสำรอง: ถ้าไม่มีแอนิเมชัน death ให้เรียก GameOverUI ทันที
		_trigger_game_over()

# 🎬 ฟังก์ชันเรียกแสดง GameOverUI
func _trigger_game_over() -> void:
	if game_over_ui and game_over_ui.has_method("show_game_over"):
		game_over_ui.show_game_over()
	else:
		# แผนสำรองหากหา GameOverUI ไม่เจอ
		var ui = get_tree().get_first_node_in_group("game_over_ui")
		if ui and ui.has_method("show_game_over"):
			ui.show_game_over()
		else:
			print("❌ ไม่พบ GameOverUI, รีโหลดฉาก...")
			GameData.reset_level_coins()
			get_tree().reload_current_scene()

func start_attack() -> void:
	if is_attacking or is_dead:
		return
		
	current_stamina -= stamina_attack_cost
	if current_stamina < 0:
		current_stamina = 0
	stamina_delay_timer = stamina_regen_delay
	
	if stamina_bar:
		stamina_bar.value = current_stamina

	is_attacking = true
	velocity.x = 0
	anim.play("attack")
	attack_collision.disabled = false

	await get_tree().create_timer(0.4).timeout
	if is_attacking:
		attack_collision.disabled = true
		is_attacking = false

func handle_stamina_regen(delta: float) -> void:
	if stamina_delay_timer > 0:
		stamina_delay_timer -= delta
	else:
		if current_stamina < max_stamina:
			current_stamina += stamina_regen_rate * delta
			if current_stamina > max_stamina:
				current_stamina = max_stamina
			if stamina_bar:
				stamina_bar.value = current_stamina

func update_animations(direction: float) -> void:
	if is_attacking or is_dead:
		return

	if is_on_floor():
		if direction != 0:
			anim.play("run")
		else:
			anim.play("idle")
	else:
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")

	if anim.animation == "run":
		anim.offset.y = 6.0
	else:
		anim.offset.y = 0.0

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body != self:
		body.take_damage(attack_damage, global_position)

# 🎯 สัญญาณเมื่อ Animation เล่นจบ
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		attack_collision.disabled = true
		is_attacking = false
	elif anim.animation == "death":
		# 💀 เมื่อ Animation "death" เล่นจบ สั่งเปิดหน้าต่าง GameOver
		_trigger_game_over()

# 🧪 ฟังก์ชันเพิ่ม HP ให้กับ Player
func heal(amount: int) -> bool:
	if is_dead or current_hp >= max_hp:
		return false

	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp

	if hp_bar:
		hp_bar.value = current_hp

	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color.GREEN, 0.15)
	tween.tween_property(anim, "modulate", Color.WHITE, 0.15)

	return true
