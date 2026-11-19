extends Control

const VN_STAGE_SCENE := "res://ui/VNStage/VNStage.tscn"
const GAME_MENU_SHELL_SCENE := preload("res://ui/GameMenuShell/GameMenuShell.tscn")
const BG_FRAMES_DIR := "res://assets/gui/main_menu_bg"
const BG_FPS := 12.0

@onready var bg_anim: AnimatedSprite2D = $Background/BgAnim
@onready var start_btn: Button = $NavigationVBox/StartButton
@onready var load_btn: Button = $NavigationVBox/LoadButton
@onready var gallery_btn: Button = $NavigationVBox/GalleryButton
@onready var options_btn: Button = $NavigationVBox/OptionsButton
@onready var about_btn: Button = $NavigationVBox/AboutButton
@onready var help_btn: Button = $NavigationVBox/HelpButton
@onready var quit_btn: Button = $NavigationVBox/QuitButton
@onready var version_label: Label = $VersionLabel
@onready var sub_menu_layer: Control = $SubMenuLayer

var _active_shell: Control = null

func _ready() -> void:
	version_label.text = "0.0.1"
	_setup_animated_background()
	_refresh_texts()
	GlobalData.language_changed.connect(func(_l): _refresh_texts())

	quit_btn.visible = OS.has_feature("pc")
	start_btn.pressed.connect(_on_start_pressed)
	load_btn.pressed.connect(func(): _open_shell_tab("load"))
	gallery_btn.pressed.connect(func(): _open_shell_tab("gallery"))
	options_btn.pressed.connect(func(): _open_shell_tab("options"))
	about_btn.pressed.connect(func(): _open_shell_tab("about"))
	help_btn.pressed.connect(func(): _open_shell_tab("help"))
	quit_btn.pressed.connect(_on_quit_pressed)

func _setup_animated_background() -> void:
	if not is_instance_valid(bg_anim):
		return
	if bg_anim.sprite_frames and bg_anim.sprite_frames.get_animation_names().size() > 0:
		var anim_name := bg_anim.sprite_frames.get_animation_names()[0]
		bg_anim.play(anim_name)
		_fit_bg_to_viewport(bg_anim.sprite_frames.get_frame_texture(anim_name, 0))
		return

	var dir := DirAccess.open(BG_FRAMES_DIR)
	if dir == null:
		push_warning("MainMenu: pasta de frames não encontrada em " + BG_FRAMES_DIR)
		return

	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".import"):
			var ext := file_name.get_extension().to_lower()
			if ext in ["png", "webp", "jpg", "jpeg"]:
				files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	files.sort()

	if files.is_empty():
		return

	var frames := SpriteFrames.new()
	frames.add_animation("loop")
	frames.set_animation_loop("loop", true)
	frames.set_animation_speed("loop", BG_FPS)

	var first_tex: Texture2D = null
	for f in files:
		var tex := load(BG_FRAMES_DIR.path_join(f)) as Texture2D
		if tex:
			if first_tex == null:
				first_tex = tex
			frames.add_frame("loop", tex)

	bg_anim.sprite_frames = frames
	bg_anim.centered = false
	bg_anim.play("loop")
	_fit_bg_to_viewport(first_tex)

func _fit_bg_to_viewport(tex: Texture2D) -> void:
	if tex == null:
		return
	var target_size := Vector2(1920.0, 1080.0)
	var tex_size := tex.get_size()
	if tex_size.x > 0.0 and tex_size.y > 0.0:
		bg_anim.scale = target_size / tex_size

func _refresh_texts() -> void:
	start_btn.text = GlobalData.tr_ui("menu", "start")
	load_btn.text = GlobalData.tr_ui("menu", "load")
	gallery_btn.text = GlobalData.tr_ui("menu", "gallery")
	options_btn.text = GlobalData.tr_ui("menu", "options")
	about_btn.text = GlobalData.tr_ui("menu", "about")
	help_btn.text = GlobalData.tr_ui("menu", "help")
	quit_btn.text = GlobalData.tr_ui("menu", "quit")

func _on_start_pressed() -> void:
	GlobalData.pending_load_path = ""
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.35)
	fade.finished.connect(func(): get_tree().change_scene_to_file(VN_STAGE_SCENE))

func _open_shell_tab(tab_id: String) -> void:
	if _active_shell and is_instance_valid(_active_shell):
		_active_shell.open_tab(tab_id)
		return
	var shell := GAME_MENU_SHELL_SCENE.instantiate()
	shell.is_in_game = false
	sub_menu_layer.add_child(shell)
	_active_shell = shell
	shell.closed.connect(func(): _active_shell = null)
	shell.open_tab(tab_id)

func _on_quit_pressed() -> void:
	get_tree().quit()
