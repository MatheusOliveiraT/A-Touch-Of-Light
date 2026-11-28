extends Control
class_name GalleryOverlay

const MANIFEST_PATH := "res://data/res_manifest.json"

@onready var gallery_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/GalleryGrid

@onready var lightbox: Control = $Lightbox
@onready var cg_display: TextureRect = $Lightbox/CgDisplay
@onready var prev_button: Button = $Lightbox/ControlsHBox/PrevButton
@onready var counter_label: Label = $Lightbox/ControlsHBox/CounterLabel
@onready var next_button: Button = $Lightbox/ControlsHBox/NextButton
@onready var close_lightbox_button: Button = $Lightbox/ControlsHBox/CloseLightboxButton

var _cgs_manifest: Dictionary = {}
var _active_cg_textures: Array[Texture2D] = []
var _active_cg_index := 0

func _ready() -> void:
	_load_cgs_from_manifest()
	lightbox.visible = false
	prev_button.pressed.connect(func(): _step_lightbox(-1))
	next_button.pressed.connect(func(): _step_lightbox(1))
	close_lightbox_button.pressed.connect(_close_lightbox)
	GlobalData.language_changed.connect(func(_l: String): _refresh_ui())
	visibility_changed.connect(_on_visibility_changed)
	_refresh_ui()

func _on_visibility_changed() -> void:
	if visible:
		_close_lightbox()
		_refresh_ui()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not lightbox.visible:
		return
	if event.is_action_pressed("left"):
		get_viewport().set_input_as_handled()
		_step_lightbox(-1)
	elif event.is_action_pressed("right"):
		get_viewport().set_input_as_handled()
		_step_lightbox(1)
	elif event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_lightbox()

func _load_cgs_from_manifest() -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_cgs_manifest = parsed.get("cgs", {})

func _refresh_ui() -> void:
	_populate_gallery()

func _populate_gallery() -> void:
	for child in gallery_grid.get_children():
		child.queue_free()
	var locked_path: String = _cgs_manifest.get("icone_bloqueado", "")
	var locked_tex: Texture2D = load(locked_path) if not locked_path.is_empty() and ResourceLoader.exists(locked_path) else null
	for cg_id in GlobalData.unlocked_cgs.keys():
		var is_unlocked: bool = bool(GlobalData.unlocked_cgs[cg_id])
		var btn := TextureButton.new()
		btn.custom_minimum_size = Vector2(260, 150)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.disabled = not is_unlocked
		if is_unlocked:
			var icon_key := "icone_" + str(cg_id)
			var icon_path: String = _cgs_manifest.get(icon_key, "")
			if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
				btn.texture_normal = load(icon_path)
			btn.pressed.connect(func(): _open_cg_lightbox(str(cg_id)))
		else:
			if locked_tex:
				btn.texture_normal = locked_tex
		gallery_grid.add_child(btn)

func _open_cg_lightbox(cg_id: String) -> void:
	_active_cg_textures.clear()
	_active_cg_index = 0
	var single_key := "cg_" + cg_id
	if _cgs_manifest.has(single_key) and ResourceLoader.exists(_cgs_manifest[single_key]):
		_active_cg_textures.append(load(_cgs_manifest[single_key]))
	else:
		var idx := 1
		while _cgs_manifest.has(single_key + str(idx)):
			var p: String = _cgs_manifest[single_key + str(idx)]
			if ResourceLoader.exists(p):
				_active_cg_textures.append(load(p))
			idx += 1
	if _active_cg_textures.is_empty():
		return
	lightbox.visible = true
	_update_lightbox_view()
	close_lightbox_button.grab_focus()

func _step_lightbox(delta: int) -> void:
	if _active_cg_textures.size() <= 1:
		return
	_active_cg_index = wrapi(_active_cg_index + delta, 0, _active_cg_textures.size())
	_update_lightbox_view()

func _update_lightbox_view() -> void:
	cg_display.texture = _active_cg_textures[_active_cg_index]
	var total := _active_cg_textures.size()
	var has_multiple := total > 1
	prev_button.visible = has_multiple
	next_button.visible = has_multiple
	counter_label.visible = has_multiple
	counter_label.text = "%d / %d" % [_active_cg_index + 1, total]

func _close_lightbox() -> void:
	lightbox.visible = false
	_active_cg_textures.clear()

func _tr_or(section: String, key: String, fallback: String) -> String:
	var res := GlobalData.tr_ui(section, key)
	if res != "%s.%s" % [section, key]:
		return res
	return fallback
