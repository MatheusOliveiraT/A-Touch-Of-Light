extends Control

const MAIN_MENU_SCENE := "res://ui/MainMenu.tscn"

const TEXT_ABOUT := "A Touch Of Light é uma obra de ficção. Quaisquer menções ou citações a eventos, pessoas e lugares reais são utilizadas de forma fantasiosa ou alteradas para fins narrativos. Qualquer outra semelhança com a realidade é mera coincidência."
const TEXT_DEV := "Este jogo está em fase de desenvolvimento. Portanto, a história, os recursos visuais e os elementos do jogo estão sujeitos a alterações a qualquer momento."

@onready var splash_label: RichTextLabel = $CenterContainer/SplashLabel
@onready var photo_panel: Control = $PhotosensitivityOverlay
@onready var effects_check: CheckBox = $PhotosensitivityOverlay/VBox/EffectsCheckBox
@onready var confirm_btn: Button = $PhotosensitivityOverlay/VBox/ConfirmButton

var _step := 0
var _active_tween: Tween

func _ready() -> void:
	photo_panel.visible = false
	splash_label.modulate.a = 0.0
	effects_check.button_pressed = GlobalData.flashing_effects
	confirm_btn.pressed.connect(_on_photosensitivity_confirmed)
	await get_tree().create_timer(1.0).timeout
	_show_splash_text(TEXT_ABOUT, 1)

func _unhandled_input(event: InputEvent) -> void:
	if photo_panel.visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		if _active_tween and _active_tween.is_valid():
			_active_tween.kill()
		_advance_splash()

func _show_splash_text(bbcode: String, step_id: int) -> void:
	_step = step_id
	splash_label.text = "[center]%s[/center]" % bbcode
	_active_tween = create_tween()
	_active_tween.tween_property(splash_label, "modulate:a", 1.0, 0.4)
	_active_tween.tween_interval(5.0)
	_active_tween.tween_property(splash_label, "modulate:a", 0.0, 0.4)
	_active_tween.finished.connect(_advance_splash)

func _advance_splash() -> void:
	splash_label.modulate.a = 0.0
	if _step == 1:
		_show_splash_text(TEXT_DEV, 2)
	elif _step == 2:
		_step = 3
		if not GlobalData.photosensitivity_warned:
			photo_panel.visible = true
			photo_panel.modulate.a = 0.0
			create_tween().tween_property(photo_panel, "modulate:a", 1.0, 0.35)
		else:
			_go_to_main_menu()

func _on_photosensitivity_confirmed() -> void:
	GlobalData.flashing_effects = effects_check.button_pressed
	GlobalData.photosensitivity_warned = true
	GlobalData.save_persistent()
	_go_to_main_menu()

func _go_to_main_menu() -> void:
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.4)
	fade.finished.connect(func(): get_tree().change_scene_to_file(MAIN_MENU_SCENE))
