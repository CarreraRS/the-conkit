extends Control

@onready var coins_label: Label = $CoinsLabel
@onready var hp_button: Button = $UpgradesContainer/HPUpgradeRow/HPButton
@onready var atk_button: Button = $UpgradesContainer/ATKUpgradeRow/ATKButton
@onready var stamina_button: Button = $UpgradesContainer/StaminaUpgradeRow/StaminaButton
@onready var next_level_button: Button = $NextLevelButton
@onready var warning_label: Label = $WarningLabel

var warning_tween: Tween

func _ready() -> void:
	# ซ่อนข้อความแจ้งเตือนไว้ตอนเริ่ม
	if warning_label:
		warning_label.text = ""
		warning_label.modulate.a = 0.0

	update_ui()
	
	hp_button.pressed.connect(_on_buy_hp)
	atk_button.pressed.connect(_on_buy_atk)
	stamina_button.pressed.connect(_on_buy_stamina)
	next_level_button.pressed.connect(_on_next_level)

func update_ui() -> void:
	coins_label.text = "Coins: " + str(GameData.total_coins)
	
	hp_button.text = "Upgrade HP (+20) - Cost: " + str(GameData.hp_upgrade_cost)
	atk_button.text = "Upgrade ATK (+5) - Cost: " + str(GameData.atk_upgrade_cost)
	stamina_button.text = "Upgrade Stamina (+15) - Cost: " + str(GameData.stamina_upgrade_cost)

# ⚠️ ฟังก์ชันแสดงข้อความแจ้งเตือน และค่อยๆ จางหายไป
func show_warning(msg: String) -> void:
	print("สั่งแสดงแจ้งเตือน: ", msg)
	if not warning_label:
		print("❌ หา WarningLabel ไม่เจอ!")
		return
		
	warning_label.text = msg
	warning_label.modulate.a = 1.0  # ดึงค่าความทึบแสงกลับมา 100%
	warning_label.visible = true    # เปิดให้มองเห็น
	
	if warning_tween and warning_tween.is_running():
		warning_tween.kill()
		
	warning_tween = create_tween()
	warning_tween.tween_interval(1.2) # แสดงค้างไว้ 1.2 วินาที
	warning_tween.tween_property(warning_label, "modulate:a", 0.0, 0.3) # ค่อยๆ จางลง
	await warning_tween.finished
	warning_label.visible = false   # ซ่อนไว้เมื่อจางเสร็จ

func _on_buy_hp() -> void:
	if GameData.total_coins >= GameData.hp_upgrade_cost:
		GameData.total_coins -= GameData.hp_upgrade_cost
		GameData.bonus_hp += 20
		GameData.hp_upgrade_cost += 2 # เพิ่มราคาอัปเกรดครั้งถัดไป
		update_ui()
	else:
		show_warning("Not enough coins!") # 👈 เตือนเมื่อเงินไม่พอ

func _on_buy_atk() -> void:
	if GameData.total_coins >= GameData.atk_upgrade_cost:
		GameData.total_coins -= GameData.atk_upgrade_cost
		GameData.bonus_damage += 5
		GameData.atk_upgrade_cost += 5
		update_ui()
	else:
		show_warning("Not enough coins!") # 👈 เตือนเมื่อเงินไม่พอ

func _on_buy_stamina() -> void:
	if GameData.total_coins >= GameData.stamina_upgrade_cost:
		GameData.total_coins -= GameData.stamina_upgrade_cost
		GameData.bonus_stamina += 15.0
		GameData.stamina_upgrade_cost += 5
		update_ui()
	else:
		show_warning("Not enough coins!") # 👈 เตือนเมื่อเงินไม่พอ

func _on_next_level() -> void:
	var next_scene: String = "res://levels/level_" + str(GameData.current_level) + ".tscn"
	
	# เช็กว่ามีไฟล์ฉากด่านถัดไปอยู่จริงไหม
	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		print("🎉 ยินดีด้วย! คุณเล่นจบทุกด่านแล้ว (หาไฟล์ " + next_scene + " ไม่พบ)")
		# หรือส่งกลับหน้า Main Menu:
		# get_tree().change_scene_to_file("res://main_menu.tscn")
