extends CharacterBody2D

## 🏃 การเคลื่อนที่
@export var run_speed: float = 300.0             # ความเร็วในการวิ่งไปทางขวา
@export var jump_velocity: float = -600.0         # 🚀 แรงส่งตอนกดกระโดด
@export var jump_gravity_multiplier: float = 1.8   # 🚀 ตัวคูณแรงโน้มถ่วงตอน "พุ่งขึ้น"
@export var fall_gravity_multiplier: float = 2.8   # 🪂 ตัวคูณแรงโน้มถ่วงตอน "ตกลงมา"

## 🩸 ระบบ HP
@export var max_hp: int = 100
var current_hp: int = 100
var is_dead: bool = false
var is_playing_hurt: bool = false # 🛡️ ตัวแปรเช็กว่ากำลังโดนตีอยู่หรือไม่

## 🔗 Node Reference
@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

# ดึงค่าแรงโน้มถ่วงหลักจาก Project Settings
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	current_hp = max_hp
	add_to_group("player")
	_play_animation("run")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 1. 🏃 วิ่งไปทางขวาอัตโนมัติ
	velocity.x = run_speed

	# 2. 🦘 ระบบกระโดดแบบ Responsive (พุ่งขึ้นไว + ดิ่งลงไว)
	if not is_on_floor():
		if velocity.y > 0:
			# 🪂 ช่วงกำลัง "ตกลงมา"
			velocity.y += gravity * fall_gravity_multiplier * delta
			if not is_playing_hurt:
				_play_animation("fall")
		else:
			# 🚀 ช่วงกำลัง "พุ่งขึ้น"
			velocity.y += gravity * jump_gravity_multiplier * delta
			if not is_playing_hurt:
				_play_animation("jump")
	else:
		if not is_playing_hurt:
			_play_animation("run")

	# 3. 🎯 การกดปุ่มกระโดด
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

## 🧪 ฟังก์ชันเพิ่ม HP / เก็บยาฮีลเลือด (พอร์ตมาจากสคริปต์เดิม)
func heal(amount: int) -> bool:
	# ถ้าตายอยู่ หรือเลือดเต็มแล้ว จะไม่สามารถเก็บยาได้
	if is_dead or current_hp >= max_hp:
		return false

	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp

	print("🧪 Player Healed! Current HP: ", current_hp, "/", max_hp)

	# ✨ เอฟเฟกต์กระพริบสีเขียวเมื่อฮีลเลือดสำเร็จ
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN, 0.15)
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)

	return true

## 💥 ฟังก์ชันรับความเสียหาย
func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	current_hp -= amount
	current_hp = clamp(current_hp, 0, max_hp)
	print("💔 Player HP: ", current_hp, "/", max_hp)
	
	# ✨ เอฟเฟกต์ตัวกระพริบสีแดงเมื่อโดนทำดาเมจ
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		die()
	else:
		# 💥 เล่นแอนิเมชันโดนตี (hurt) เมื่อเลือดยังไม่หมด
		is_playing_hurt = true
		_play_animation("hurt")
		
		# รอ 0.3 วินาที แล้วค่อยกลับไปเล่นแอนิเมชันวิ่งตามปกติ
		get_tree().create_timer(0.3).timeout.connect(func():
			is_playing_hurt = false
		)


## ☠️ ฟังก์ชันเมื่อ Player เลือดหมด
func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	velocity = Vector2.ZERO
	print("💀 Game Over!")
	
	_play_animation("death")
	
	# ปิด Collision ของตัวละครทันที กันไม่ให้โดนชนซ้ำ
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.set_deferred("disabled", true)

	# 🎬 ค้นหา GameOverUI ในเกม (ค้นหาจาก Group "game_over_ui" หรือ Node ลูก)
	var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
	if game_over_ui == null:
		game_over_ui = get_node_or_null("CanvasLayer/GameOverUI")

	# ถ้าหา UI เจอ ให้สั่งแสดงผล
	if game_over_ui and game_over_ui.has_method("show_game_over"):
		get_tree().create_timer(0.5).timeout.connect(func():
			game_over_ui.show_game_over()
		)
	else:
		print("❌ หา GameOverUI ไม่เจอ! กำลังรีโหลดฉากอัตโนมัติ...")
		if is_inside_tree():
			var tree = get_tree()
			await tree.create_timer(1.0).timeout
			if tree:
				GameData.reset_level_coins()
				tree.reload_current_scene()

## 🎨 ฟังก์ชันช่วยเปลี่ยนแอนิเมชันแบบปลอดภัย
func _play_animation(anim_name: String) -> void:
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation(anim_name):
		if anim.animation != anim_name:
			anim.play(anim_name)
