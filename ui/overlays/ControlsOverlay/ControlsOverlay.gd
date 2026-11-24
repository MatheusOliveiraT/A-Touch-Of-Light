extends Control
class_name ControlsOverlay

signal closed

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var controls_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ControlsGrid
@onready var back_button: Button = $PanelContainer/MarginContainer/VBoxContainer/BackButton

const CONTROL_ROWS := [
	{"key": "advance", "pt": "Avançar diálogo", "en": "Advance dialogue", "actions": ["interact", "right"], "extra_pt": "Clique Esquerdo / Enter", "extra_en": "Left Click / Enter"},
	{"key": "rollback", "pt": "Voltar fala (Rollback)", "en": "Rollback dialogue", "actions": ["left"], "extra_pt": "Roda do Mouse ↑", "extra_en": "Mouse Wheel ↑"},
	{"key": "skip", "pt": "Pular texto já lido", "en": "Skip seen text", "actions": ["skip"], "extra_pt": "", "extra_en": ""},
	{"key": "navigate", "pt": "Navegar escolhas / menus", "en": "Navigate choices / menus", "actions": ["up", "down"], "extra_pt": "", "extra_en": ""},
	{"key": "menu", "pt": "Abrir menu / pausar", "en": "Open menu / pause", "actions": ["menu"], "extra_pt": "", "extra_en": ""}
]

func _ready() -> void:
	controls_grid.columns = 2
	back_button.pressed.connect(_on_back_pressed)

	GlobalData.language_changed.connect(func(_l: String): _refresh_ui())
	visibility_changed.connect(_on_visibility_changed)

	_refresh_ui()
	if visible:
		back_button.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		_refresh_ui()
		back_button.grab_focus()

func _on_back_pressed() -> void:
	emit_signal("closed")
	hide()

func _refresh_ui() -> void:
	title_label.text = _tr_or("menu", "help", "Ajuda")
	back_button.text = _tr_or("menu", "back", "Voltar")
	_populate_controls()

func _populate_controls() -> void:
	for child in controls_grid.get_children():
		child.queue_free()

	var lang: String = str(GlobalData.settings.get("language", GlobalData.DEFAULT_LANG))
	var is_en := lang == "en"

	for row in CONTROL_ROWS:
		var action_lbl := Label.new()
		var fallback_desc: String = row["en"] if is_en else row["pt"]
		action_lbl.text = _tr_or("controls", row["key"], fallback_desc)
		action_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		controls_grid.add_child(action_lbl)

		var keys_lbl := Label.new()
		keys_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		keys_lbl.text = _format_row_keys(row, is_en)
		controls_grid.add_child(keys_lbl)

func _format_row_keys(row: Dictionary, is_en: bool) -> String:
	var parts: Array[String] = []
	for act_name in (row["actions"] as Array):
		var act := str(act_name)
		if InputMap.has_action(act):
			for ev in InputMap.action_get_events(act):
				var txt := _event_to_readable_string(ev)
				if not txt.is_empty() and not txt in parts:
					parts.append(txt)
	var extra: String = row["extra_en"] if is_en else row["extra_pt"]
	if not extra.is_empty():
		parts.append(extra)
	return " / ".join(parts)

func _event_to_readable_string(ev: InputEvent) -> String:
	if ev is InputEventKey:
		var code: Key = ev.physical_keycode if ev.physical_keycode != KEY_NONE else ev.keycode
		return OS.get_keycode_string(code)
	if ev is InputEventJoypadButton:
		return "Joy %d" % ev.button_index
	return ""

func _tr_or(section: String, key: String, fallback: String) -> String:
	var res := GlobalData.tr_ui(section, key)
	if res != "%s.%s" % [section, key]:
		return res
	return fallback
