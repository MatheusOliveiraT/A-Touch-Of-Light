extends Node

signal language_changed(lang_code: String)

const SAVE_PATH := "user://persistent.json"
const DEFAULT_LANG := "pt"

const SEEN_FILE_PATH := "user://seen_dialogues.json"
var seen_dialogue_ids: Dictionary = {}

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

var _transition_layer: CanvasLayer
var _fade_rect: ColorRect
var _is_transitioning := false

func _ready() -> void:
	_fallback_strings = _load_lang_file(DEFAULT_LANG)
	load_persistent()
	_ui_strings = _load_lang_file(settings["language"])
	apply_settings()
	load_seen_dialogues()
	sync_custom_ui_inputs()

func sync_custom_ui_inputs() -> void:
	var action_map := {
		"up": "ui_up",
		"down": "ui_down",
		"interact": "ui_accept",
	}
	for custom_act in action_map.keys():
		var ui_act: String = action_map[custom_act]
		if InputMap.has_action(custom_act) and InputMap.has_action(ui_act):
			for ev in InputMap.action_get_events(custom_act):
				if not InputMap.action_has_event(ui_act, ev):
					InputMap.action_add_event(ui_act, ev)

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

func apply_audio_settings() -> void:
	_set_bus_volume("Master", settings["master_vol"])
	_set_bus_volume("Music", settings["music_vol"])
	_set_bus_volume("SFX", settings["sfx_vol"])

func apply_window_settings() -> void:
	var target_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_MAXIMIZED
	if DisplayServer.window_get_mode() != target_mode:
		DisplayServer.window_set_mode(target_mode)

func apply_settings() -> void:
	apply_audio_settings()
	apply_window_settings()

func _set_bus_volume(bus_name: String, linear_val: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(max(linear_val, 0.001)))
	AudioServer.set_bus_mute(idx, linear_val <= 0.001)

func save_persistent() -> void:
	var data := {
		"first_launch_done": first_launch_done,
		"photosensitivity_warned": photosensitivity_warned,
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
		photosensitivity_warned = parsed.get("photosensitivity_warned", false)
		flashing_effects = parsed.get("flashing_effects", true)
		unlocked_cgs.merge(parsed.get("unlocked_cgs", {}), true)
		settings.merge(parsed.get("settings", {}), true)
		
func load_seen_dialogues() -> void:
	if not FileAccess.file_exists(SEEN_FILE_PATH):
		seen_dialogue_ids = {}
		return
	var file := FileAccess.open(SEEN_FILE_PATH, FileAccess.READ)
	if file:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			seen_dialogue_ids = parsed
		
func save_seen_dialogues() -> void:
	var file := FileAccess.open(SEEN_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(seen_dialogue_ids))

func is_dialogue_seen(dialogue_uid: String) -> bool:
	return seen_dialogue_ids.has(dialogue_uid)

func mark_dialogue_seen(dialogue_uid: String) -> void:
	if not seen_dialogue_ids.has(dialogue_uid):
		seen_dialogue_ids[dialogue_uid] = true
		save_seen_dialogues()

func _init_transition_overlay() -> void:
	if is_instance_valid(_transition_layer):
		return
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100
	add_child(_transition_layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_layer.add_child(_fade_rect)

func change_scene_with_fade(scene_path: String, fade_out_time := 0.4, fade_in_time := 0.4) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_init_transition_overlay()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw_out := create_tween()
	tw_out.tween_property(_fade_rect, "color:a", 1.0, fade_out_time)
	await tw_out.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	var tw_in := create_tween()
	tw_in.tween_property(_fade_rect, "color:a", 0.0, fade_in_time)
	await tw_in.finished
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
