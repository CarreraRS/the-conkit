extends CanvasLayer

@onready var game_over_sound: AudioStreamPlayer = $GameOverSound
@onready var restart_button: Button = $RestartButton
@onready var main_menu_button: Button = $MainMenuButton

func _ready() -> void:
	# ซ่อนหน้าต่างเมื่อเริ่มเกม
	hide()
	
	# เชื่อมต่อปุ่มกด
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

## 💀 ฟังก์ชันแสดงหน้าต่าง GameOver และเล่นเสียง
func show_game_over() -> void:
	get_tree().call_group("bgm", "stop")
	show()
	
	# เล่นเสียง Game Over
	if game_over_sound and game_over_sound.stream:
		game_over_sound.play()

## 🔄 กดปุ่มเริ่มใหม่
func _on_restart_pressed() -> void:
	GameData.reset_level_coins() # ล้างเหรียญที่เก็บได้ในด่านนี้
	get_tree().reload_current_scene()

## 🏠 กดปุ่มกลับหน้าหลัก
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu/main_menu.tscn") # เช็ก Path ให้ตรงกับ Scene ของคุณ
