extends CanvasLayer

## 🔗 Node References (ใช้ get_node_or_null ป้องกัน Crash เมื่อหาโหนดไม่เจอ)
@onready var coin_label: Label = get_node_or_null("CoinLabel")

# 🩸 หลอดเลือด Player และ Boss (รองรับทั้ง Range, ProgressBar หรือ TextureProgressBar)
@onready var player_hp_bar: Range = get_node_or_null("PlayerHPBar")
@onready var boss_hp_bar: Range = get_node_or_null("BossHPBar")

# 🏷️ Label สำหรับแสดงตัวเลขเพิ่มเติม (ถ้ามี)
@onready var player_hp_label: Label = get_node_or_null("PlayerHPLabel")
@onready var boss_hp_label: Label = get_node_or_null("BossHPLabel")

## 🎯 ตัวแประอ้างอิงถึง Player และ Boss
var player: Node2D = null
var boss: Node2D = null

func _ready() -> void:
	# เพิ่ม HUD เข้า Group "hud" เพื่อให้สคริปต์อื่นอ้างอิงถึงได้ง่าย
	add_to_group("hud")
	
	# ค้นหา Player และ Boss ตอนเริ่มเกม
	_find_entities()

func _process(_delta: float) -> void:
	# คอยค้นหา Player หรือ Boss อีกครั้ง หากยังหาไม่เจอหรือเกิดใหม่
	if player == null or not is_instance_valid(player) or boss == null or not is_instance_valid(boss):
		_find_entities()

	# 🪙 1. อัปเดตแสดงเหรียญ
	_update_coin_display()

	# ❤️ 2. อัปเดตหลอดเลือดและข้อความของ Player
	_update_player_hp_display()

	# 😈 3. อัปเดตหลอดเลือดและข้อความของ บอส
	_update_boss_hp_display()

## 🔍 ฟังก์ชันค้นหา Player และ Boss จาก Group
func _find_entities() -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		
	if boss == null or not is_instance_valid(boss):
		boss = get_tree().get_first_node_in_group("boss")

## 🪙 อัปเดตเหรียญ
func _update_coin_display() -> void:
	if coin_label:
		if GameData and GameData.has_method("get_display_coins"):
			coin_label.text = "Coins: " + str(GameData.get_display_coins())
		elif GameData and "coins_in_level" in GameData and "total_coins" in GameData:
			coin_label.text = "Coins: " + str(GameData.total_coins + GameData.coins_in_level)

## ❤️ อัปเดต HP ของ Player
func _update_player_hp_display() -> void:
	if player and is_instance_valid(player):
		var current_hp = player.get("current_hp") if "current_hp" in player else 0
		var max_hp = player.get("max_hp") if "max_hp" in player else 100
		
		# อัปเดตหลอดเลือด Player
		if player_hp_bar:
			player_hp_bar.max_value = max_hp
			player_hp_bar.value = current_hp
			
		# อัปเดต Label แสดงข้อความ HP (ถ้ามี)
		if player_hp_label:
			player_hp_label.text = "HP: " + str(current_hp) + " / " + str(max_hp)

## 😈 อัปเดต HP ของ บอส
func _update_boss_hp_display() -> void:
	if boss and is_instance_valid(boss):
		var current_hp = boss.get("current_hp") if "current_hp" in boss else 0
		var max_hp = boss.get("max_hp") if "max_hp" in boss else 2500
		
		# แสดงหลอดเลือดบอส และอัปเดตค่า
		if boss_hp_bar:
			boss_hp_bar.visible = true
			boss_hp_bar.max_value = max_hp
			boss_hp_bar.value = current_hp
			
		# อัปเดต Label บอส
		if boss_hp_label:
			boss_hp_label.text = "Boss HP: " + str(current_hp) + " / " + str(max_hp)
	else:
		# เมื่อบอสตาย หรือยังไม่สปอว์น ให้ซ่อนหลอดเลือดบอส
		if boss_hp_bar:
			boss_hp_bar.visible = false
		if boss_hp_label:
			boss_hp_label.text = "Boss Defeated!"
