extends Control

## 📦 Scene ปลายทางที่ต้องการเปลี่ยนไป (ลากไฟล์ Scene มาใส่ใน Inspector ได้)
@export var target_scene_path: String = "res://levels/level_1.tscn"

@onready var next_button: Button = $NextButton

func _ready() -> void:
	# เชื่อมต่อสัญญาณเมื่อกดปุ่ม Next เข้ากับฟังก์ชัน _on_next_button_pressed
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)

## 🎯 ฟังก์ชันเมื่อกดปุ่ม Next
func _on_next_button_pressed() -> void:
	# เช็กว่ามีไฟล์ Scene ปลายทางอยู่จริงหรือไม่ ก่อนสลับหน้า
	if ResourceLoader.exists(target_scene_path):
		get_tree().change_scene_to_file(target_scene_path)
	else:
		print("❌ หาไฟล์ Scene ปลายทางไม่เจอ! โปรดตรวจสอบ Path: ", target_scene_path)
