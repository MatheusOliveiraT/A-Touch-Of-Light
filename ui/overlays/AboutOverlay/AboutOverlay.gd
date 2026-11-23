extends Control
class_name AboutOverlay

signal closed

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var version_label: Label = $PanelContainer/MarginContainer/VBoxContainer/VersionLabel
@onready var body_text: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/BodyText

func _ready() -> void:
	body_text.bbcode_enabled = true
	body_text.meta_clicked.connect(_on_meta_clicked)
	GlobalData.language_changed.connect(func(_l: String): _refresh_texts())
	visibility_changed.connect(_on_visibility_changed)
	_refresh_texts()

func _on_visibility_changed() -> void:
	if visible:
		_refresh_texts()
		body_text.scroll_to_line(0)

func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_back_pressed() -> void:
	emit_signal("closed")
	hide()

func _refresh_texts() -> void:
	title_label.text = _tr_or("menu", "about", "Sobre")
	version_label.text = _tr_or("about", "version", "Versão 0.0.1")
	body_text.text = _tr_or("about", "body", "")

func _tr_or(section: String, key: String, fallback: String) -> String:
	var res := GlobalData.tr_ui(section, key)
	if res != "%s.%s" % [section, key]:
		return res
	return fallback
