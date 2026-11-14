extends Node

const SAVE_PATH := "user://persistent.json"

var first_launch_done := false
var flashing_effects := true
var unlocked_cgs := {
	"escombros": false,
	"shopping": false
}
var settings := {
	"master_vol": 1.0,
	"music_vol": 0.85,
	"sfx_vol": 0.9,
	"typewriter_speed": 0.022,
	"fullscreen": false,
	"language": "pt"
}

func _ready() -> void:
	load_persistent()
	apply_settings()

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
