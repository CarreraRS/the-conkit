extends Area2D

@export var heal_amount: int = 25 # 🧪 ปริมาณ HP ที่จะเพิ่มให้ Player

func _ready() -> void:
	# เชื่อมต่อสัญญาณเมื่อมีวัตถุเข้ามาชน
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# เช็กว่าสิ่งที่ชนคือ Player และมีฟังก์ชัน heal หรือไม่
	if body.is_in_group("player") and body.has_method("heal"):
		# สั่งรักษา และเช็กว่าเพิ่มเลือดสำเร็จไหม (ถ้าเลือดเต็มอยู่ heal จะรีเทิร์น false)
		var is_healed = body.heal(heal_amount)
		
		if is_healed:
			print("เก็บยาเพิ่ม HP: +", heal_amount)
			# สามารถเพิ่มเสียงเก็บไอเทม หรือ Effect ตรงนี้ได้
			queue_free() # ลบไอเทมออกจากฉาก
