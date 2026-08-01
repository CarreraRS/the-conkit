extends Area2D

@export var coin_value: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 🪙 สั่งเพิ่มเหรียญชั่วคราวในด่าน
		if GameData:
			GameData.add_level_coin(1)
		
		queue_free() # ลบเหรียญทิ้ง
