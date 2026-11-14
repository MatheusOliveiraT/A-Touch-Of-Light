extends Control

const VN_STAGE_SCENE := "res://ui/VNStage/VNStage.tscn"
const SLOTS_OVERLAY := preload("res://ui/overlays/SlotsPanel/SlotsPanel.tscn")
const GALLERY_OVERLAY := preload("res://ui/overlays/GalleryOverlay/GalleryOverlay.tscn")
const SETTINGS_OVERLAY := preload("res://ui/overlays/SettingsOverlay/SettingsOverlay.tscn")
const CONTROLS_OVERLAY := preload("res://ui/overlays/ControlsOverlay/ControlsOverlay.tscn")
const CREDITS_OVERLAY := preload("res://ui/overlays/CreditsOverlay/CreditsOverlay.tscn")

@onready var animated_bg: TextureRect = $AnimatedBg
@onready var new_game_btn: Button = $MenuMargin/MenuButtons/NewGameBtn
@onready var continue_btn: Button = $MenuMargin/MenuButtons/ContinueBtn
@onready var load_btn: Button = $MenuMargin/MenuButtons/LoadBtn
@onready var gallery_btn: Button = $MenuMargin/MenuButtons/GalleryBtn
@onready var settings_btn: Button = $MenuMargin/MenuButtons/SettingsBtn
@onready var controls_btn: Button = $MenuMargin/MenuButtons/ControlsBtn
@onready var credits_btn: Button = $MenuMargin/MenuButtons/CreditsBtn
@onready var quit_btn: Button = $MenuMargin/MenuButtons/QuitBtn
@onready var overlay_host: Control = $OverlayHost

var _bg_frames: Array[Texture2D] = []
var _frame_idx := 0

func _ready() -> void:
	_setup_bg_animation()
	_connect_buttons()
	continue_btn.disabled = not FileAccess.file_exists("user://saves/autosave.json")

func _setup_bg_animation() -> void:
	for i in range(1, 7):
		var path := "res://assets/gui/mainmenu/%d.png" % i
		if ResourceLoader.exists(path):
			_bg_frames.append(load(path))
	if _bg_frames.is_empty():
		return
	animated_bg.texture = _bg_frames[0]
	var timer := Timer.new()
	timer.wait_time = 0.35
	timer.autostart = true
	timer.timeout.connect(func():
		_frame_idx = (_frame_idx + 1) % _bg_frames.size()
		animated_bg.texture = _bg_frames[_frame_idx]
	)
	add_child(timer)

func _connect_buttons() -> void:
	new_game_btn.pressed.connect(func(): get_tree().change_scene_to_file(VN_STAGE_SCENE))
	continue_btn.pressed.connect(_on_continue_pressed)
	load_btn.pressed.connect(func():
		var panel := _open_overlay(SLOTS_OVERLAY)
		if panel.has_method("setup_mode"):
			panel.setup_mode(false)
	)
	gallery_btn.pressed.connect(func(): _open_overlay(GALLERY_OVERLAY))
	settings_btn.pressed.connect(func(): _open_overlay(SETTINGS_OVERLAY))
	controls_btn.pressed.connect(func(): _open_overlay(CONTROLS_OVERLAY))
	credits_btn.pressed.connect(func(): _open_overlay(CREDITS_OVERLAY))
	quit_btn.pressed.connect(func(): get_tree().quit())

func _open_overlay(scene: PackedScene) -> Control:
	for child in overlay_host.get_children():
		child.queue_free()
	var instance: Control = scene.instantiate()
	overlay_host.add_child(instance)
	return instance

func _on_continue_pressed() -> void:
	GlobalData.pending_load_path = "user://saves/autosave.json"
	get_tree().change_scene_to_file(VN_STAGE_SCENE)
