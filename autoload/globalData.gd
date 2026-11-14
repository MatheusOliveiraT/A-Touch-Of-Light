extends Node

signal language_changed(lang_code: String)

const SAVE_PATH := "user://persistent.json"
const DEFAULT_LANG := "pt"

var first_launch_done := false
var photosensitivity_warned := false
var flashing_effects := true
var pending_load_path := ""

var unlocked_cgs := {
	"escombros": false,
	"shopping": false
}

var settings := {
	"master_vol": 1.0,
	"music_vol": 0.5,
	"sfx_vol": 0.5,
	"typewriter_speed": 0.022,
	"auto_forward_time": 4.0,
	"skip_unseen": false,
	"skip_after_choices": false,
	"transitions_enabled": true,
	"fullscreen": false,
	"language": "pt"
}

var _ui_strings: Dictionary = {}
var _fallback_strings: Dictionary = {}

func _ready() -> void:
	_fallback_strings = _load_lang_file(DEFAULT_LANG)
	load_persistent()
	_ui_strings = _load_lang_file(settings["language"])
	apply_settings()

func set_language(lang_code: String) -> void:
	settings["language"] = lang_code
	_ui_strings = _load_lang_file(lang_code)
	save_persistent()
	emit_signal("language_changed", lang_code)

func tr_ui(section: String, key: String) -> String:
	if _ui_strings.has(section) and (_ui_strings[section] as Dictionary).has(key):
		return str(_ui_strings[section][key])
	if _fallback_strings.has(section) and (_fallback_strings[section] as Dictionary).has(key):
		return str(_fallback_strings[section][key])
	return "%s.%s" % [section, key]

func get_script_paths() -> Array[String]:
	var lang: String = settings.get("language", DEFAULT_LANG)
	var base_dir := "res://data/%s/" % lang
	if not FileAccess.file_exists(base_dir + "res_script.vn"):
		base_dir = "res://data/%s/" % DEFAULT_LANG
	return [
		base_dir + "res_script.vn",
		base_dir + "res_prologo.vn",
		base_dir + "res_cap1.vn"
	]

func _load_lang_file(lang_code: String) -> Dictionary:
	var path := "res://data/%s/ui.json" % lang_code
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func unlock_cg(cg_id: String) -> void:
	if unlocked_cgs.has(cg_id) and not unlocked_cgs[cg_id]:
		unlocked_cgs[cg_id] = true
		save_persistent()

func apply_settings() -> void:
	_set_bus_volume("Master", settings["master_vol"])
	_set_bus_volume("Music", settings["music_vol"])
	_set_bus_volume("SFX", settings["sfx_vol"])
	
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _set_bus_volume(bus_name: String, linear_val: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(max(linear_val, 0.001)))
	AudioServer.set_bus_mute(idx, linear_val <= 0.001)

func save_persistent() -> void:
	var data := {
		"first_launch_done": first_launch_done,
		"flashing_effects": flashing_effects,
		"unlocked_cgs": unlocked_cgs,
		"settings": settings
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func load_persistent() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		first_launch_done = parsed.get("first_launch_done", false)
		flashing_effects = parsed.get("flashing_effects", true)
		unlocked_cgs.merge(parsed.get("unlocked_cgs", {}), true)
		settings.merge(parsed.get("settings", {}), true)
