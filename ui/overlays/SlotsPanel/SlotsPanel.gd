extends Control
class_name SlotsPanel

signal slot_saved(slot_path: String)
signal slot_loaded(slot_path: String)

enum Mode { LOAD, SAVE }

const SAVE_DIR := "user://saves/"
const SLOTS_PER_PAGE := 6
const TOTAL_PAGES := 10

@export var stage_scene_path := "res://ui/VNStage/VNStage.tscn"

@onready var prev_page_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/PageControlsHBox/PrevPageButton
@onready var page_label: Label = $PanelContainer/MarginContainer/VBoxContainer/PageControlsHBox/PageLabel
@onready var next_page_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/PageControlsHBox/NextPageButton
@onready var slots_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/SlotsGrid
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog


var current_mode: Mode = Mode.LOAD
var stage_controller: VNStageController = null
var menu_shell: GameMenuShell = null

var _current_page := 1
var _pending_slot_index := -1

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if prev_page_btn:
		prev_page_btn.pressed.connect(func(): _change_page(-1))
	if next_page_btn:
		next_page_btn.pressed.connect(func(): _change_page(1))
	if confirm_dialog:
		confirm_dialog.confirmed.connect(_on_confirm_accepted)
	GlobalData.language_changed.connect(func(_l: String): _refresh_ui())
	_refresh_ui()

func configure(tab_id: String, stage_ref: VNStageController, shell: GameMenuShell) -> void:
	current_mode = Mode.SAVE if tab_id == "save" else Mode.LOAD
	stage_controller = stage_ref
	menu_shell = shell
	if is_node_ready():
		_refresh_ui()

func _change_page(delta: int) -> void:
	_current_page = wrapi(_current_page + delta, 1, TOTAL_PAGES + 1)
	_refresh_ui()

func _refresh_ui() -> void:
	if page_label:
		var prefix := _tr_or("slots", "page_prefix", "Página")
		page_label.text = "%s %d / %d" % [prefix, _current_page, TOTAL_PAGES]
	_populate_slots()

func _populate_slots() -> void:
	if not slots_grid:
		return
	for child in slots_grid.get_children():
		child.queue_free()
	var empty_text := _tr_or("slots", "empty", "Slot vazio")
	var start_idx := (_current_page - 1) * SLOTS_PER_PAGE + 1
	var first_enabled_btn: Button = null
	for i in range(SLOTS_PER_PAGE):
		var slot_num := start_idx + i
		var path := _get_slot_path(slot_num)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(240, 110)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if FileAccess.file_exists(path):
			var info := _read_slot_metadata(path)
			var label_str := str(info.get("label", ""))
			var date_str := str(info.get("timestamp", ""))
			btn.text = "Slot %02d\n%s\n%s" % [slot_num, label_str, date_str]
			btn.pressed.connect(func(): _on_slot_pressed(slot_num))
		else:
			btn.text = "Slot %02d\n%s" % [slot_num, empty_text]
			btn.disabled = (current_mode == Mode.LOAD)
			if current_mode == Mode.SAVE:
				btn.pressed.connect(func(): _on_slot_pressed(slot_num))
		slots_grid.add_child(btn)
		if first_enabled_btn == null and not btn.disabled:
			first_enabled_btn = btn
	if first_enabled_btn:
		first_enabled_btn.call_deferred("grab_focus")

func _on_slot_pressed(slot_num: int) -> void:
	var path := _get_slot_path(slot_num)
	if current_mode == Mode.SAVE:
		if FileAccess.file_exists(path) and confirm_dialog:
			_pending_slot_index = slot_num
			confirm_dialog.title = _tr_or("menu", "save", "Salvar")
			confirm_dialog.dialog_text = _tr_or("confirm", "overwrite", "Deseja sobrescrever este save?")
			confirm_dialog.ok_button_text = _tr_or("confirm", "yes", "Sim")
			confirm_dialog.cancel_button_text = _tr_or("confirm", "no", "Não")
			confirm_dialog.popup_centered()
		else:
			_execute_save(slot_num)
	else:
		_execute_load(slot_num)

func _on_confirm_accepted() -> void:
	if _pending_slot_index != -1:
		var idx := _pending_slot_index
		_pending_slot_index = -1
		_execute_save(idx)

func _execute_save(slot_num: int) -> void:
	if not is_instance_valid(stage_controller):
		push_warning("VNStageController não vinculado ao SlotsPanel para salvar.")
		return
	var path := _get_slot_path(slot_num)
	var snap := stage_controller.create_state_snapshot()
	var save_payload := {
		"slot": slot_num,
		"label": str(snap.get("label", "start")),
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"snapshot": snap
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_payload))
		file.close()
		emit_signal("slot_saved", path)
		_refresh_ui()

func _execute_load(slot_num: int) -> void:
	var path := _get_slot_path(slot_num)
	if not FileAccess.file_exists(path):
		return
	if is_instance_valid(stage_controller):
		var file := FileAccess.open(path, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary and parsed.has("snapshot"):
			stage_controller.restore_state_snapshot(parsed["snapshot"])
			emit_signal("slot_loaded", path)
			if is_instance_valid(menu_shell):
				menu_shell.close_shell()
	else:
		GlobalData.pending_load_path = path
		emit_signal("slot_loaded", path)
		GlobalData.change_scene_with_fade(stage_scene_path)

func _get_slot_path(slot_num: int) -> String:
	return "%sslot_%02d.json" % [SAVE_DIR, slot_num]

func _read_slot_metadata(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(content) == OK and json.data is Dictionary:
		return json.data
	return {}

func _tr_or(section: String, key: String, fallback: String) -> String:
	var res := GlobalData.tr_ui(section, key)
	if res != "%s.%s" % [section, key]:
		return res
	return fallback
