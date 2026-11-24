extends Control
class_name GameMenuShell

signal closed
signal request_main_menu

@export var is_in_game := false

@onready var in_game_bg: TextureRect = $InGameBackground
@onready var title_label: Label = $TitleLabel
@onready var history_btn: Button = $NavigationVBox/HistoryButton
@onready var save_btn: Button = $NavigationVBox/SaveButton
@onready var load_btn: Button = $NavigationVBox/LoadButton
@onready var gallery_btn: Button = $NavigationVBox/GalleryButton
@onready var options_btn: Button = $NavigationVBox/OptionsButton
@onready var main_menu_btn: Button = $NavigationVBox/MainMenuButton
@onready var about_btn: Button = $NavigationVBox/AboutButton
@onready var help_btn: Button = $NavigationVBox/HelpButton
@onready var quit_btn: Button = $NavigationVBox/QuitButton
@onready var return_btn: Button = $ReturnButton
@onready var content_slot: Control = $ContentSlot

var _tab_scenes: Dictionary = {
	 "save": preload("res://ui/overlays/SlotsPanel/SlotsPanel.tscn"),
	 "load": preload("res://ui/overlays/SlotsPanel/SlotsPanel.tscn"),
	 "gallery": preload("res://ui/overlays/GalleryOverlay/GalleryOverlay.tscn"),
	 "options": preload("res://ui/overlays/SettingsOverlay/SettingsOverlay.tscn"),
	 "history": preload("res://ui/overlays/HistoryOverlay/HistoryOverlay.tscn"),
	 "about": preload("res://ui/overlays/AboutOverlay/AboutOverlay.tscn"),
	 "help": preload("res://ui/overlays/ControlsOverlay/ControlsOverlay.tscn"),
}

var _current_tab := ""
var _vn_stage_ref: VNStageController = null

func _ready() -> void:
	in_game_bg.visible = is_in_game
	history_btn.visible = is_in_game
	save_btn.visible = is_in_game
	main_menu_btn.visible = is_in_game
	quit_btn.visible = OS.has_feature("pc")
	_refresh_texts()
	GlobalData.language_changed.connect(func(_l): _refresh_texts())
	history_btn.pressed.connect(func(): open_tab("history"))
	save_btn.pressed.connect(func(): open_tab("save"))
	load_btn.pressed.connect(func(): open_tab("load"))
	gallery_btn.pressed.connect(func(): open_tab("gallery"))
	options_btn.pressed.connect(func(): open_tab("options"))
	about_btn.pressed.connect(func(): open_tab("about"))
	help_btn.pressed.connect(func(): open_tab("help"))
	main_menu_btn.pressed.connect(func(): emit_signal("request_main_menu"))
	quit_btn.pressed.connect(func(): get_tree().quit())
	return_btn.pressed.connect(close_shell)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_shell()

func bind_vn_stage(stage: VNStageController) -> void:
	_vn_stage_ref = stage

func _refresh_texts() -> void:
	history_btn.text = GlobalData.tr_ui("menu", "history")
	save_btn.text = GlobalData.tr_ui("menu", "save")
	load_btn.text = GlobalData.tr_ui("menu", "load")
	gallery_btn.text = GlobalData.tr_ui("menu", "gallery")
	options_btn.text = GlobalData.tr_ui("menu", "options")
	main_menu_btn.text = GlobalData.tr_ui("menu", "main_menu")
	about_btn.text = GlobalData.tr_ui("menu", "about")
	help_btn.text = GlobalData.tr_ui("menu", "help")
	quit_btn.text = GlobalData.tr_ui("menu", "quit")
	return_btn.text = GlobalData.tr_ui("menu", "back")
	if not _current_tab.is_empty():
		title_label.text = GlobalData.tr_ui("menu", _current_tab)

func open_tab(tab_id: String) -> void:
	_current_tab = tab_id
	title_label.text = GlobalData.tr_ui("menu", tab_id)
	for child in content_slot.get_children():
		child.queue_free()
	if _tab_scenes.has(tab_id):
		var panel: Control = (_tab_scenes[tab_id] as PackedScene).instantiate()
		if panel.has_method("configure"):
			panel.configure(tab_id, _vn_stage_ref, self)
		content_slot.add_child(panel)

func close_shell() -> void:
	emit_signal("closed")
	queue_free()
