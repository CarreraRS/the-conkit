extends Node

# 💰 เหรียญสะสมถาวร (เฉพาะตอนผ่านด่านแล้ว)
var total_coins: int = 0       
# 🪙 เหรียญชั่วคราวที่เก็บได้ในด่านปัจจุบัน (จะโดนรีเซ็ตถ้าตาย)
var coins_in_level: int = 0    

var bonus_hp: int = 0
var bonus_damage: int = 0
var bonus_stamina: float = 0.0
var hp_upgrade_cost: int = 10
var atk_upgrade_cost: int = 15
var stamina_upgrade_cost: int = 10

var current_level: int = 1

# 🎯 เรียกตอนเก็บเหรียญได้ในด่าน
func add_level_coin(amount: int = 1) -> void:
	coins_in_level += amount

# 🎯 เรียกตอนผู้เล่นตาย / Restart ด่าน
func reset_level_coins() -> void:
	coins_in_level = 0

# 🚪 เรียกตอนเข้าประตูจบด่าน
func confirm_level_coins() -> void:
	total_coins += coins_in_level
	coins_in_level = 0

# 📊 ฟังก์ชันดึงจำนวนเหรียญรวมปัจจุบันมาแสดงบน UI
func get_display_coins() -> int:
	return total_coins + coins_in_level
