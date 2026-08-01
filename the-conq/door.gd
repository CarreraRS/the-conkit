# สคริปต์ door.gd
extends Area2D

@export_file("*.tscn") var target_scene_path: String = "res://item/shop_menu.tscn"
var is_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_triggered:
		is_triggered = true
		
		# 🛡️ ปิด CollisionShape ของประตูแบบปลอดภัย กันการตรวจจับฟิสิกส์ซ้ำ
		$CollisionShape2D.set_deferred("disabled", true)
		
		# 🎯 บวกเลขด่านขึ้นไปอีก 1 ด่านเมื่อเดินเข้าประตู
		GameData.current_level += 1
		GameData.confirm_level_coins()
		
		# 🚪 เปลี่ยนไปยังด่านถัดไป
		get_tree().change_scene_to_file(target_scene_path)
