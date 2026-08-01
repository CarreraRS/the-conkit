extends Control

# Path ของ Scene เกมของคุณ (อย่าลืมเปลี่ยนให้ตรงกับตำแหน่งไฟล์เกมจริง)
@export_file("*.tscn") var game_scene_path: String = "res://levels/howtoplay.tscn"

@onready var play_button: Button = $MenuButtons/PlayButton
@onready var option_button: Button = $MenuButtons/OptionButton
@onready var credits_button: Button = $MenuButtons/CreditsButton
@onready var exit_button: Button = $MenuButtons/ExitButton

@onready var option_panel: Control = $OptionPanel
@onready var credits_panel: Control = $CreditsPanel
@onready var volume_slider: HSlider = $OptionPanel/VolumeSlider
@onready var close_option_button: Button = $OptionPanel/CloseOptionButton
@onready var close_credits_button: Button = $CreditsPanel/CloseCreditsButton

func _ready() -> void:
	# ซ่อน Pop-up ไว้ก่อนตอนเริ่ม
	option_panel.hide()
	credits_panel.hide()

	# เชื่อมต่อสัญญาณปุ่มหลัก
	play_button.pressed.connect(_on_play_pressed)
	option_button.pressed.connect(_on_option_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	# เชื่อมต่อสัญญาณปุ่มปิด Pop-up
	close_option_button.pressed.connect(func(): option_panel.hide())
	close_credits_button.pressed.connect(func(): credits_panel.hide())

	# เชื่อมต่อ Slider ปรับเสียง
	volume_slider.value_changed.connect(_on_volume_changed)

# 🎮 ปุ่ม PLAY
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)

# ⚙️ ปุ่ม OPTION
func _on_option_pressed() -> void:
	credits_panel.hide()
	option_panel.show()

# 📜 ปุ่ม CREDITS
func _on_credits_pressed() -> void:
	option_panel.hide()
	credits_panel.show()

# ❌ ปุ่ม EXIT
func _on_exit_pressed() -> void:
	get_tree().quit()

# 🔊 ระบบปรับลดเสียงMaster ใน Godot
func _on_volume_changed(value: float) -> void:
	var master_bus_index = AudioServer.get_bus_index("Master")
	# แปลงค่า 0.0 - 1.0 เป็น dB (Decibels)
	if value == 0:
		AudioServer.set_bus_mute(master_bus_index, true)
	else:
		AudioServer.set_bus_mute(master_bus_index, false)
		AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))
