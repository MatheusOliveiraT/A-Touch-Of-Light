extends Control
class_name SettingsOverlay

signal closed

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel

@onready var general_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Sliders/General/Label
@onready var general_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/Sliders/General/General
@onready var music_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Sliders/Music/Label
@onready var music_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/Sliders/Music/Music
@onready var sfx_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Sliders/SFX/Label
@onready var sfx_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/Sliders/SFX/SFX

@onready var fullscreen_toggle: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/Toggles/FullScreen
@onready var transitions_toggle: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/Toggles/Transitions
@onready var effects_toggle: CheckButton = $PanelContainer/MarginContainer/VBoxContainer/Toggles/Effects

@onready var language_option: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/OptionButton
@onready var reset_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsHBox/ResetButton
@onready var back_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsHBox/BackButton

const LANGUAGES := [
	{"code": "pt", "label": "Português"},
	{"code": "en", "label": "English"}
]

func _ready() -> void:
	_setup_sliders()
	_setup_languages()
	_load_from_global()
	_refresh_texts()
	general_slider.value_changed.connect(func(v: float): _on_volume_changed("master_vol", v))
	music_slider.value_changed.connect(func(v: float): _on_volume_changed("music_vol", v))
	sfx_slider.value_changed.connect(func(v: float): _on_volume_changed("sfx_vol", v))
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	transitions_toggle.toggled.connect(_on_transitions_toggled)
	effects_toggle.toggled.connect(_on_effects_toggled)
	language_option.item_selected.connect(_on_language_selected)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)
	GlobalData.language_changed.connect(func(_l: String): _refresh_texts())
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		general_slider.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		_load_from_global()
		_refresh_texts()
		general_slider.grab_focus()

func _setup_sliders() -> void:
	for s in [general_slider, music_slider, sfx_slider]:
		s.min_value = 0.0
		s.max_value = 1.0
		s.step = 0.05

func _setup_languages() -> void:
	language_option.clear()
	for i in range(LANGUAGES.size()):
		language_option.add_item(LANGUAGES[i]["label"], i)

func _load_from_global() -> void:
	general_slider.set_value_no_signal(float(GlobalData.settings.get("master_vol", 1.0)))
	music_slider.set_value_no_signal(float(GlobalData.settings.get("music_vol", 0.5)))
	sfx_slider.set_value_no_signal(float(GlobalData.settings.get("sfx_vol", 0.5)))
	fullscreen_toggle.set_pressed_no_signal(bool(GlobalData.settings.get("fullscreen", false)))
	transitions_toggle.set_pressed_no_signal(bool(GlobalData.settings.get("transitions_enabled", true)))
	effects_toggle.set_pressed_no_signal(GlobalData.flashing_effects)
	var cur_lang: String = str(GlobalData.settings.get("language", GlobalData.DEFAULT_LANG))
	for i in range(LANGUAGES.size()):
		if LANGUAGES[i]["code"] == cur_lang:
			language_option.select(i)
			break

func _on_volume_changed(setting_key: String, linear_val: float) -> void:
	GlobalData.settings[setting_key] = linear_val
	GlobalData.apply_settings()

func _on_fullscreen_toggled(pressed: bool) -> void:
	GlobalData.settings["fullscreen"] = pressed
	GlobalData.apply_settings()

func _on_transitions_toggled(pressed: bool) -> void:
	GlobalData.settings["transitions_enabled"] = pressed

func _on_effects_toggled(pressed: bool) -> void:
	GlobalData.flashing_effects = pressed

func _on_language_selected(index: int) -> void:
	if index < 0 or index >= LANGUAGES.size():
		return
	var lang_code: String = LANGUAGES[index]["code"]
	if str(GlobalData.settings.get("language", "")) != lang_code:
		GlobalData.set_language(lang_code)

func _on_reset_pressed() -> void:
	GlobalData.settings["master_vol"] = 1.0
	GlobalData.settings["music_vol"] = 0.5
	GlobalData.settings["sfx_vol"] = 0.5
	GlobalData.settings["transitions_enabled"] = true
	GlobalData.settings["fullscreen"] = false
	GlobalData.flashing_effects = true
	GlobalData.apply_settings()
	GlobalData.save_persistent()
	_load_from_global()

func _on_back_pressed() -> void:
	GlobalData.save_persistent()
	emit_signal("closed")
	hide()

func _refresh_texts() -> void:
	title_label.text = _tr_or("menu", "options", "Opções")
	general_label.text = _tr_or("settings", "general_vol", "Volume geral")
	music_label.text = _tr_or("settings", "music_vol", "Volume da música")
	sfx_label.text = _tr_or("settings", "sfx_vol", "Volume do som")
	fullscreen_toggle.text = _tr_or("settings", "fullscreen", "Tela cheia")
	transitions_toggle.text = _tr_or("settings", "transitions", "Transições")
	effects_toggle.text = _tr_or("settings", "flashing_effects", "Efeitos / Flashes")
	reset_button.text = _tr_or("settings", "reset", "Restaurar padrões")
	back_button.text = _tr_or("menu", "back", "Voltar")

func _tr_or(section: String, key: String, fallback: String) -> String:
	var res := GlobalData.tr_ui(section, key)
	if res != "%s.%s" % [section, key]:
		return res
	return fallback
