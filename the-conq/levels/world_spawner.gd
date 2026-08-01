extends Node2D

## 📦 ลากไฟล์ PlatformChunk.tscn มาใส่ตรงนี้ (ใส่ได้หลายแบบ)
@export var chunk_scenes: Array[PackedScene] = []

## ⚙️ การตั้งค่าระบบ Spawner
@export var initial_chunks: int = 3          # จำนวนพื้นที่จะเสกรอไว้ตอนเริ่มเกม
@export var spawn_distance_threshold: float = 1000.0 # ระยะห่างจาก Player ที่จะสั่งให้เสกชิ้นต่อไป

var player: Node2D = null
var next_spawn_position: Vector2 = Vector2.ZERO
var active_chunks: Array[Node2D] = []

func _ready() -> void:
	# จุดเริ่มต้นการเสกชิ้นแรก จะเริ่มจากตำแหน่งของตัว Spawner เอง
	next_spawn_position = global_position
	
	# เสกพื้นชุดแรกต้อนรับเตรียมไว้ก่อน
	for i in range(initial_chunks):
		spawn_chunk()

func _process(_delta: float) -> void:
	# ถ้ายังหา Player ไม่เจอ ให้ค้นหาจาก Group "player"
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	# 🎯 1. ถ้า Player วิ่งขยับเข้าใกล้จุดสิ้นสุดของพื้นชิ้นล่าสุด -> ให้เสกชิ้นใหม่ทันที
	if player.global_position.x + spawn_distance_threshold > next_spawn_position.x:
		spawn_chunk()
		
	# 🧹 2. ลบพื้นชิ้นเก่าที่ Player วิ่งเลยไปไกลแล้ว ทิ้งไปเพื่อไม่ให้กิน RAM
	clean_old_chunks()

func spawn_chunk() -> void:
	if chunk_scenes.is_empty():
		print("⚠️ Warning: ยังไม่ได้ใส่ไฟล์ Chunk ใน Inspector ของ WorldSpawner!")
		return

	# 🎲 สุ่มสลับแบบ Chunk
	var random_index = randi() % chunk_scenes.size()
	var selected_scene = chunk_scenes[random_index]

	# เสก Chunk ออกมา
	var chunk_instance = selected_scene.instantiate() as Node2D
	
	# 📍 กำหนดตำแหน่งล่วงหน้าก่อนสั่ง add_child
	chunk_instance.global_position = next_spawn_position
	
	# คำนวณจุดเสกถัดไปทันที
	if chunk_instance.has_method("get_end_position"):
		# ใช้ตำแหน่ง EndPosition ที่เทียบกับความยาว Marker2D
		var end_marker = chunk_instance.get_node_or_null("EndPosition")
		if end_marker:
			next_spawn_position += end_marker.position
		else:
			next_spawn_position += Vector2(800, 0)
	else:
		next_spawn_position += Vector2(800, 0)

	# ใช้งาน call_deferred อย่างปลอดภัย
	get_parent().add_child.call_deferred(chunk_instance)
	active_chunks.append(chunk_instance)

func clean_old_chunks() -> void:
	for chunk in active_chunks:
		if is_instance_valid(chunk):
			# ถ้าปลายพื้นชิ้นนั้นอยู่ข้างหลัง Player เกิน 1200px ให้ลบทิ้ง
			if chunk.has_method("get_end_position"):
				if chunk.get_end_position().x < player.global_position.x - 1200.0:
					active_chunks.erase(chunk)
					chunk.queue_free()
