extends Area2D

## 📊 ค่าสถานะบอส
@export var max_hp: int = 2500
var current_hp: int

@export var boss_offset_x: float = 350.0 # ระยะห่างที่บอสจะลอยนำหน้า Player
@export var attack_cooldown: float = 5 # ปล่อยสกิลทุกๆ กี่วินาที

## 🎯 Reference ถึง Player (สามารถลากตัวละครแมวมาวางใน Inspector ได้เลย)
@export var player: Node2D 

## 📦 Scene ที่เกี่ยวข้อง
@export var skill_scene: PackedScene   # ลากไฟล์ Skill / Obstacle มาใส่
@export var door_scene: PackedScene   # ลากไฟล์ door.tscn มาใส่

## 🔗 Node Reference (ใช้ get_node_or_null ป้องกัน Crash)
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var attack_timer: Timer = get_node_or_null("AttackTimer")
@onready var skill_spawn_point: Node2D = get_node_or_null("SkillSpawnPoint")

var is_dead: bool = false
var is_playing_hit: bool = false # 🛡️ ตัวแปรเช็กว่ากำลังเล่นท่าโดนตีอยู่หรือไม่ (กันแอนิเมชันตีซ้อน)

func _ready() -> void:
	current_hp = max_hp
	
	# 🛡️ ถ้าใน Scene ไม่มี AttackTimer ให้สร้างขึ้นให้อัตโนมัติกันโค้ดพัง
	if attack_timer == null:
		attack_timer = Timer.new()
		attack_timer.name = "AttackTimer"
		add_child(attack_timer)
	
	# ตั้งค่า Timer สำหรับการโจมตี
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()
	
	_play_anim("idle")

func _process(_delta: float) -> void:
	if is_dead:
		return
		
	# 1. แผนสำรอง: ถ้าไม่ได้ลาก Player ใน Inspector ให้หาจาก Group "player"
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	# 2. ย้ายตำแหน่งบอสไปด้านหน้า Player เสมอ
	if player and is_instance_valid(player):
		global_position.x = player.global_position.x + boss_offset_x
		global_position.y = player.global_position.y - 80.0

## 💥 ฟังก์ชันปล่อยสกิลเมื่อ Timer ครบเวลา
func _on_attack_timer_timeout() -> void:
	if is_dead or skill_scene == null or player == null:
		return
		
	# เล่นแอนิเมชันโจมตี (ถ้าไม่ได้โดนตีอยู่)
	if not is_playing_hit:
		_play_anim("attack")
		get_tree().create_timer(0.5).timeout.connect(func(): 
			if not is_dead and not is_playing_hit: 
				_play_anim("idle")
		)

	# เสกสกิล/สิ่งกีดขวาง
	var skill_instance = skill_scene.instantiate()
	get_parent().add_child(skill_instance)
	
	if skill_spawn_point:
		skill_instance.global_position = skill_spawn_point.global_position
	else:
		skill_instance.global_position = global_position

## 🩸 ฟังก์ชันรับความเสียหาย
func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	current_hp -= amount
	current_hp = clamp(current_hp, 0, max_hp)
	
	# 🎬 สั่ง Tween หลอดเลือดบอสใน HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		var boss_bar = hud.get_node_or_null("BossHPBar")
		if boss_bar:
			var tween = create_tween()
			tween.tween_property(boss_bar, "value", current_hp, 0.2).set_trans(Tween.TRANS_QUAD)

	# 💥 เล่นแอนิเมชันโดนตี (hit) + กระพริบสีแดง
	if current_hp > 0:
		is_playing_hit = true
		_play_anim("hit")
		
		# ตัวกระพริบแดง
		var sprite_tween = create_tween()
		sprite_tween.tween_property(self, "modulate", Color.RED, 0.1)
		sprite_tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		
		# เล่นท่า hit เสร็จแล้วให้กลับมาท่า idle
		get_tree().create_timer(0.3).timeout.connect(func():
			is_playing_hit = false
			if not is_dead:
				_play_anim("idle")
		)
	else:
		die()

## ☠️ ฟังก์ชันบอสตาย
## ☠️ ฟังก์ชันบอสตาย
func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	if attack_timer:
		attack_timer.stop()
	
	print("🏆 Boss Defeated!")
	
	# 💀 เล่นแอนิเมชันตาย (death)
	_play_anim("death")
	
	# ปิด Collision ของบอสทันที ไม่ให้โดนตีซ้ำ
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.set_deferred("disabled", true)

	# รอเล่นท่าตายแป๊บหนึ่ง (เช่น 1.0 วินาที) แล้วเด้งไป Scene End Credits ทันที
	var death_duration = 1.0 # สามารถปรับเวลาให้ตรงกับความยาวอนิเมชันตายได้ครับ
	
	get_tree().create_timer(death_duration).timeout.connect(func():
		# 🎬 เด้งไปยัง Scene End Credits ทันที (อย่าลืมเช็ก Path ให้ตรงกับที่เก็บไฟล์ไว้)
		get_tree().change_scene_to_file("res://levels/end_credits.tscn")
	)

## 🎨 ฟังก์ชันช่วยเรียกเล่นแอนิเมชันอย่างปลอดภัย
func _play_anim(anim_name: String) -> void:
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation(anim_name):
		anim.play(anim_name)
