extends Area2D

func _ready() -> void:
	# เชื่อมต่อสัญญาณการชน
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# เช็กว่าสิ่งที่ตกลงมาชนคือ Player หรือไม่
	if body.is_in_group("player"):
		print("Player ตกแมพ!")
		
		# ถ้าใน player.gd มีฟังก์ชัน die() ให้สั่งทำงานทันที
		if body.has_method("die"):
			body.die()
		else:
			# หรือสั่งเปิดหน้า GameOver ตรงๆ (กรณีไม่มีฟังก์ชัน die)
			get_tree().paused = true
			# เปลี่ยน Path ด้านล่างให้ตรงกับ GameOver UI ของคุณ
			# body.get_node("CanvasLayer/GameOverUI").show()
