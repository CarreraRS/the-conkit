extends Area2D

@export var damage_to_boss: int = 100 # ดาเมจที่จะทำใส่บอสเมื่อเก็บได้

func _ready() -> void:
	# เชื่อมสัญญาณเมื่อมีวัตถุเข้ามาชน
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# ตรวจสอบว่าเป็น Player หรือไม่
	if body.is_in_group("player"):
		# 1. ค้นหา Boss ในฉากผ่าน Group "boss"
		var boss = get_tree().get_first_node_in_group("boss")
		
		if boss and boss.has_method("take_damage"):
			# 🎯 (แถม) สร้างเอฟเฟกต์กระสุนเวทมนตร์พุ่งไปหาบอสก่อนลบตัวเอง
			spawn_fly_effect_to_boss(boss.global_position)
			
			# ลด HP บอส
			boss.take_damage(damage_to_boss)
		
		# 2. ลบไอเทมออกจากฉาก
		queue_free()

# 🎨 (ออปชันเสริม) ฟังก์ชันสร้างกระสุนเอฟเฟกต์พุ่งใส่บอส
func spawn_fly_effect_to_boss(target_pos: Vector2) -> void:
	# สร้าง Sprite ชั่วคราวลอยไปหาบอส
	var effect = Sprite2D.new()
	effect.texture = $Sprite2D.texture # ใช้ รูปเดียวกับไอเทม
	effect.global_position = global_position
	effect.scale = Vector2(0.6, 0.6)
	get_parent().add_child(effect)
	
	# ใช้ Tween ให้วิ่งพุ่งไปหาตำแหน่งบอสภายใน 0.2 วินาที
	var tween = effect.create_tween()
	tween.tween_property(effect, "global_position", target_pos, 0.2)
	tween.tween_callback(effect.queue_free) # ถึงตัวบอสแล้วลบทิ้ง
