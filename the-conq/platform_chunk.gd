extends Node2D

@onready var end_position: Node2D = $EndPosition

# 📏 ฟังก์ชันดึงตำแหน่งจุดจบของ Chunk นี้
func get_end_position() -> Vector2:
	if end_position:
		return end_position.global_position
	# ถ้าลืมใส่ EndPosition ให้ fallback เป็นการบวก x ไป 800px
	return global_position + Vector2(800, 0)
