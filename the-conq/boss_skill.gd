extends Area2D

@export var speed: float = 1000.0 # ความเร็วที่พุ่งสวนทางมาหา Player (พุ่งไปทางซ้าย)
@export var damage: int = 10

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# วิ่งพุ่งไปทางซ้ายสวนกับ Player
	position.x -= speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# ถ้ามีระบบ HP Player ให้เรียกทำดาเมจตรงนี้
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		queue_free() # ชน Player แล้วลบตัวเองทิ้ง
