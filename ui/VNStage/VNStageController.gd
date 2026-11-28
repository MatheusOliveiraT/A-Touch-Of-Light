extends Control
class_name VNStageController

signal returned_to_main_menu
signal chapter_finished(label_name: String)
signal skip_state_changed(is_skipping: bool)

const LAYERED_CHAR_SCENE := preload("res://personagens/layeredCharacter.tscn")
const GAME_MENU_SHELL_PATH := "res://ui/GameMenuShell/GameMenuShell.tscn"
const MAX_ROLLBACK_STEPS := 60
const MAX_HISTORY_ENTRIES := 250
const SKIP_STEP_INTERVAL := 0.03

const FULLSCREEN_FIT_IDS := ["sangue", "poeira", "portal", "vapor", "carro"]
const FOREGROUND_OVERLAY_IDS := ["sangue", "poeira", "portal", "vapor"]

@export var manifest_path := "res://data/res_manifest.json"

@onready var camera: Camera2D = $Camera2D
@onready var bg_back: TextureRect = $BackgroundLayer/BgBack
@onready var bg_front: TextureRect = $BackgroundLayer/BgFront
@onready var character_layer: Control = $CharacterLayer
@onready var center_text_label: RichTextLabel = $OverlayLayer/CenterTextLabel
@onready var transition_rect: ColorRect = $OverlayLayer/TransitionRect

@onready var dialogue_box: PanelContainer = $UILayer/DialogueBox
@onready var speaker_label: RichTextLabel = $UILayer/DialogueBox/VBox/SpeakerLabel
@onready var dialogue_text: RichTextLabel = $UILayer/DialogueBox/VBox/DialogueText
@onready var choices_container: VBoxContainer = $UILayer/ChoicesContainer
@onready var input_panel: PanelContainer = $UILayer/InputPanel
@onready var input_prompt: Label = $UILayer/InputPanel/VBox/InputPrompt
@onready var name_line_edit: LineEdit = $UILayer/InputPanel/VBox/NameLineEdit
@onready var confirm_button: Button = $UILayer/InputPanel/VBox/ConfirmButton

@onready var music_a: AudioStreamPlayer = $AudioPlayers/MusicA
@onready var music_b: AudioStreamPlayer = $AudioPlayers/MusicB
@onready var sfx_player: AudioStreamPlayer = $AudioPlayers/SfxPlayer
@onready var loop_sfx_player: AudioStreamPlayer = $AudioPlayers/LoopSfxPlayer

var manifest: Dictionary = {}
var labels: Dictionary = {}
var variables: Dictionary = {}

var current_label := "start"
var event_queue: Array = []
var current_index := 0
var active_characters: Dictionary = {}
var current_bg_id := ""
var active_music_player: AudioStreamPlayer

var is_typing := false
var is_waiting_choice := false
var is_waiting_input := false
var is_paused := false
var is_skipping := false
var _skip_timer := 0.0
var _current_dialogue_uid := ""
var _active_menu_shell: GameMenuShell = null
var _confirm_main_menu_dialog: ConfirmationDialog = null

var pending_input_var := ""
var type_tween: Tween
var earthquake_tween: Tween
var rollback_stack: Array[Dictionary] = []
var dialogue_history: Array[Dictionary] = []

var current_music_id := ""
var current_music_volume := 1.0
var current_loop_sfx_id := ""
var current_loop_sfx_volume := 1.0
var current_camera_effect := ""

var cached_stage_screenshot: Image = null

func _ready() -> void:
	active_music_player = music_a
	music_a.finished.connect(func(): _on_music_finished(music_a))
	music_b.finished.connect(func(): _on_music_finished(music_b))
	confirm_button.pressed.connect(_on_input_confirmed)
	name_line_edit.text_submitted.connect(func(_t): _on_input_confirmed())
	GlobalData.language_changed.connect(_on_language_changed)
	_load_manifest()
	_load_all_scripts()
	if not GlobalData.pending_load_path.is_empty() and FileAccess.file_exists(GlobalData.pending_load_path):
		var save_file := FileAccess.open(GlobalData.pending_load_path, FileAccess.READ)
		var content := save_file.get_as_text()
		save_file.close()
		var parsed: Variant = JSON.parse_string(content)
		GlobalData.pending_load_path = ""
		if parsed is Dictionary and parsed.has("snapshot"):
			restore_state_snapshot(parsed["snapshot"])
			return
	jump_to_label("start")

func _on_music_finished(player: AudioStreamPlayer) -> void:
	if player == active_music_player and not current_music_id.is_empty():
		player.play()

func _process(delta: float) -> void:
	if not is_skipping:
		return
	if is_waiting_choice or is_waiting_input or is_paused:
		set_skipping(false)
		return
	if not _is_current_event_skippable():
		set_skipping(false)
		return
	_skip_timer += delta
	if _skip_timer >= SKIP_STEP_INTERVAL:
		_skip_timer = 0.0
		if is_typing:
			if type_tween:
				type_tween.kill()
			dialogue_text.visible_ratio = 1.0
			is_typing = false
		advance()

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_active_menu_shell):
		return
	if event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel"):
		set_skipping(false)
		get_viewport().set_input_as_handled()
		open_pause_menu()
		return
	if is_waiting_input or is_paused:
		return
	if is_waiting_choice:
		if event.is_action_pressed("up") or event.is_action_pressed("down"):
			_ensure_choice_focus()
		return
	if event.is_action_pressed("skip"):
		get_viewport().set_input_as_handled()
		toggle_skip()
		return
	if (
		event.is_action_pressed("right")
		or event.is_action_pressed("interact")
		or event.is_action_pressed("ui_accept")
		or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	):
		if is_skipping:
			set_skipping(false)
		get_viewport().set_input_as_handled()
		advance()
		return
	if (
		event.is_action_pressed("left")
		or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed)
	):
		if is_skipping:
			set_skipping(false)
		get_viewport().set_input_as_handled()
		rollback()

func open_pause_menu(default_tab: String = "options") -> void:
	if is_instance_valid(_active_menu_shell):
		return
	set_skipping(false)
	var prev_ui_visible : bool = $UILayer.visible
	$UILayer.visible = false
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if img:
		img.resize(320, 180, Image.INTERPOLATE_BILINEAR)
		cached_stage_screenshot = img
	$UILayer.visible = prev_ui_visible
	var shell_scene := load(GAME_MENU_SHELL_PATH) as PackedScene
	var shell: GameMenuShell = shell_scene.instantiate()
	shell.is_in_game = true
	shell.bind_vn_stage(self)
	shell.closed.connect(_on_pause_menu_closed)
	shell.request_main_menu.connect(_on_pause_request_main_menu)
	$UILayer.add_child(shell)
	_active_menu_shell = shell
	shell.open_tab(default_tab)

func _on_pause_menu_closed() -> void:
	if is_instance_valid(_confirm_main_menu_dialog):
		_confirm_main_menu_dialog.queue_free()
		_confirm_main_menu_dialog = null
	_active_menu_shell = null
	is_paused = false

func _on_pause_request_main_menu() -> void:
	if is_instance_valid(_confirm_main_menu_dialog):
		_confirm_main_menu_dialog.popup_centered()
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = GlobalData.tr_ui("menu", "main_menu")
	dialog.dialog_text = GlobalData.tr_ui("confirm", "main_menu")
	dialog.ok_button_text = GlobalData.tr_ui("confirm", "yes")
	dialog.cancel_button_text = GlobalData.tr_ui("confirm", "no")
	dialog.confirmed.connect(func():
		if is_instance_valid(_active_menu_shell):
			_active_menu_shell.queue_free()
			_active_menu_shell = null
		_confirm_main_menu_dialog = null
		is_paused = false
		emit_signal("returned_to_main_menu")
		GlobalData.change_scene_with_fade("res://ui/MainMenu/MainMenu.tscn")
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
		_confirm_main_menu_dialog = null
	)
	$UILayer.add_child(dialog)
	_confirm_main_menu_dialog = dialog
	dialog.popup_centered()

func toggle_skip() -> void:
	if is_skipping:
		set_skipping(false)
		return
	if _is_current_event_skippable():
		set_skipping(true)

func set_skipping(active: bool) -> void:
	if is_skipping == active:
		return
	is_skipping = active
	_skip_timer = 0.0
	emit_signal("skip_state_changed", is_skipping)

func _set_stream_loop(stream: AudioStream, enable: bool) -> void:
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = enable
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if enable else AudioStreamWAV.LOOP_DISABLED

func _has_trailing_dissolve(start_idx: int) -> bool:
	var idx := start_idx + 1
	while idx < event_queue.size():
		var t: String = event_queue[idx].get("type", "")
		if t in ["show", "hide", "scene"]:
			idx += 1
			continue
		if t == "transition":
			return not _is_fade_effect(event_queue[idx].get("effect", ""))
		break
	return false

func _build_event_uid(label_name: String, idx: int, ev: Dictionary) -> String:
	var ev_type: String = ev.get("type", "")
	var speaker: String = ev.get("speaker", "")
	return "%s::%d::%s::%s" % [label_name, idx, ev_type, speaker]

func _is_current_event_skippable() -> bool:
	if current_index < 0 or current_index >= event_queue.size():
		return false
	var ev: Dictionary = event_queue[current_index]
	var ev_type: String = ev.get("type", "")
	if ev_type == "dialogue" or ev_type == "narration":
		return GlobalData.is_dialogue_seen(_current_dialogue_uid)
	return ev_type not in ["menu", "input", "pause", "return"]

func _ensure_choice_focus() -> void:
	if get_viewport().gui_get_focus_owner() == null and choices_container.get_child_count() > 0:
		var first_btn := choices_container.get_child(0) as Control
		if first_btn:
			first_btn.grab_focus()

func _on_language_changed(_lang: String) -> void:
	_load_all_scripts()
	if labels.has(current_label):
		event_queue = (labels[current_label] as Array).duplicate(true)
		_process_current_event()

func _load_manifest() -> void:
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	if not file:
		push_error("Manifesto não encontrado: " + manifest_path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		manifest = parsed
		var vars_dict: Dictionary = manifest.get("variables", {})
		variables = vars_dict.duplicate(true)

func _load_all_scripts() -> void:
	labels.clear()
	for path in GlobalData.get_script_paths():
		if not FileAccess.file_exists(path):
			continue
		var file := FileAccess.open(path, FileAccess.READ)
		var parsed_labels := _parse_vn_script(file.get_as_text())
		labels.merge(parsed_labels, true)

func _parse_vn_script(raw_text: String) -> Dictionary:
	var result: Dictionary = {}
	var merged_lines := _preprocess_vn_lines(raw_text)
	var cur_label := ""
	var mode := ""
	var block_indent := 0
	var menu_opts: Array = []
	var cur_opt: Dictionary = {}
	var if_cond := ""
	var if_acts: Array = []
	for entry in merged_lines:
		var line_str: String = entry["text"]
		var indent: int = entry["indent"]
		var trimmed := line_str.strip_edges()
		if trimmed.begins_with("==") and trimmed.ends_with("=="):
			if mode == "menu" and not cur_label.is_empty():
				if not cur_opt.is_empty():
					menu_opts.append(cur_opt)
				(result[cur_label] as Array).append({"type": "menu", "options": menu_opts})
			elif mode == "if" and not cur_label.is_empty():
				(result[cur_label] as Array).append({"type": "if", "condition": if_cond, "actions": if_acts})
			mode = ""
			cur_opt = {}
			menu_opts = []
			if_acts = []
			cur_label = trimmed.trim_prefix("==").trim_suffix("==").strip_edges()
			result[cur_label] = []
			continue
		if cur_label.is_empty():
			continue
		if not mode.is_empty() and indent <= block_indent:
			if mode == "menu":
				if not cur_opt.is_empty():
					menu_opts.append(cur_opt)
				(result[cur_label] as Array).append({"type": "menu", "options": menu_opts})
				menu_opts = []
				cur_opt = {}
			elif mode == "if":
				(result[cur_label] as Array).append({"type": "if", "condition": if_cond, "actions": if_acts})
				if_acts = []
			mode = ""
		if trimmed == "menu:":
			mode = "menu"
			block_indent = indent
			menu_opts = []
			cur_opt = {}
			continue
		if trimmed.begins_with("if ") and trimmed.ends_with(":"):
			mode = "if"
			block_indent = indent
			if_cond = trimmed.trim_prefix("if ").trim_suffix(":").strip_edges()
			if_acts = []
			continue
		if mode == "menu":
			if trimmed.begins_with(">"):
				if not cur_opt.is_empty():
					menu_opts.append(cur_opt)
				var opt_text := trimmed.trim_prefix(">").strip_edges().trim_prefix('"').trim_suffix('"')
				cur_opt = {"text": opt_text, "actions": []}
			elif not cur_opt.is_empty():
				var ev := _parse_vn_line(trimmed)
				if not ev.is_empty():
					(cur_opt["actions"] as Array).append(ev)
			continue
		if mode == "if":
			var ev := _parse_vn_line(trimmed)
			if not ev.is_empty():
				if_acts.append(ev)
			continue
		var event := _parse_vn_line(trimmed)
		if not event.is_empty():
			(result[cur_label] as Array).append(event)
	if mode == "menu" and not cur_label.is_empty():
		if not cur_opt.is_empty():
			menu_opts.append(cur_opt)
		(result[cur_label] as Array).append({"type": "menu", "options": menu_opts})
	elif mode == "if" and not cur_label.is_empty():
		(result[cur_label] as Array).append({"type": "if", "condition": if_cond, "actions": if_acts})

	return result

func _preprocess_vn_lines(raw_text: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var buffer := ""
	var start_indent := 0
	var in_quotes := false
	for raw in raw_text.split("\n"):
		var clean := raw.rstrip("\r")
		var stripped := clean.strip_edges()
		if not in_quotes:
			if stripped.is_empty() or stripped.begins_with("#"):
				continue
			start_indent = clean.length() - clean.lstrip(" \t").length()
			buffer = stripped
		else:
			buffer += " " + stripped
		var quote_count := buffer.count('"') - buffer.count('\\"')
		in_quotes = (quote_count % 2) != 0
		if not in_quotes:
			out.append({"indent": start_indent, "text": buffer})
			buffer = ""
	return out

func _parse_vn_line(line: String) -> Dictionary:
	if line.begins_with('"') and line.ends_with('"') and line.length() >= 2:
		return {"type": "narration", "text": line.substr(1, line.length() - 2).replace('\\"', '"')}
	var first_quote := line.find('"')
	if first_quote > 0 and line.ends_with('"'):
		var prefix := line.substr(0, first_quote).strip_edges()
		if not " " in prefix:
			var body := line.substr(first_quote + 1, line.length() - first_quote - 2).replace('\\"', '"')
			return {"type": "dialogue", "speaker": prefix, "text": body}
	if line.begins_with("$"):
		return {"type": "expression", "code": line.substr(1).strip_edges()}
	if line.begins_with("input "):
		var rest := line.substr(6).strip_edges()
		var q := rest.find('"')
		return {
			"type": "input",
			"var": rest.substr(0, q).strip_edges(),
			"prompt": rest.substr(q + 1, rest.length() - q - 2)
		}
	if line.begins_with("show text "):
		var rest := line.substr(10).strip_edges()
		var parts := rest.split(" with ", false, 1)
		var txt := parts[0].strip_edges().trim_prefix('"').trim_suffix('"')
		var trans_name := parts[1].strip_edges() if parts.size() > 1 else ""
		return {"type": "show_text", "text": txt, "transition": trans_name}
	if line.begins_with("scene "):
		var parts := line.substr(6).strip_edges().split(" with ", false, 1)
		var trans_name := parts[1].strip_edges() if parts.size() > 1 else ""
		return {"type": "scene", "asset": parts[0].strip_edges(), "transition": trans_name}
	if line.begins_with("show "):
		var rest := line.substr(5).strip_edges()
		var trans_name := ""
		var pos := ""
		if " with " in rest:
			var p := rest.split(" with ", false, 1)
			rest = p[0].strip_edges()
			trans_name = p[1].strip_edges()
		if " at " in rest:
			var p := rest.split(" at ", false, 1)
			rest = p[0].strip_edges()
			pos = p[1].strip_edges()
		var tokens := rest.split(" ", false)
		var attrs: Array[String] = []
		var rems: Array[String] = []
		for i in range(1, tokens.size()):
			if tokens[i].begins_with("-"):
				rems.append(tokens[i].substr(1))
			else:
				attrs.append(tokens[i])
		return {"type": "show", "character": tokens[0], "attributes": attrs, "removed_attributes": rems, "position": pos, "transition": trans_name}
	if line.begins_with("hide "):
		var parts := line.substr(5).strip_edges().split(" with ", false, 1)
		var trans_name := parts[1].strip_edges() if parts.size() > 1 else ""
		return {"type": "hide", "character": parts[0].strip_edges(), "transition": trans_name}
	if line.begins_with("play ") or line.begins_with("queue "):
		var tokens := line.split(" ", false)
		var ev: Dictionary = {"type": "audio", "action": tokens[0], "channel": tokens[1], "track": tokens[2], "loop": "loop" in tokens}
		var vol_i := tokens.find("volume")
		if vol_i != -1 and vol_i + 1 < tokens.size():
			ev["volume"] = float(tokens[vol_i + 1])
		var fi_i := tokens.find("fadein")
		if fi_i != -1 and fi_i + 1 < tokens.size():
			ev["fadein"] = float(tokens[fi_i + 1])
		return ev
	if line.begins_with("stop "):
		var tokens := line.split(" ", false)
		var fo := 0.0
		var fo_i := tokens.find("fadeout")
		if fo_i != -1 and fo_i + 1 < tokens.size():
			fo = float(tokens[fo_i + 1])
		return {"type": "stop_audio", "channel": tokens[1], "fadeout": fo}
	if line.begins_with("with "):
		return {"type": "transition", "effect": line.substr(5).strip_edges()}
	if line.begins_with("pause"):
		var parts := line.split(" ", false)
		var dur := float(parts[1]) if parts.size() > 1 else -1.0
		return {"type": "pause", "duration": dur}
	if line.begins_with("camera at "):
		return {"type": "camera", "effect": line.substr(10).strip_edges()}
	if line.begins_with("jump "):
		return {"type": "jump", "target": line.substr(5).strip_edges()}
	if line == "return":
		return {"type": "return"}
	return {}

func jump_to_label(label_name: String) -> void:
	if not labels.has(label_name):
		push_error("Label inexistente: " + label_name)
		return
	current_label = label_name
	event_queue = (labels[label_name] as Array).duplicate(true)
	current_index = 0
	_process_current_event()

func advance() -> void:
	if is_typing:
		if type_tween:
			type_tween.kill()
		dialogue_text.visible_ratio = 1.0
		is_typing = false
		return
	current_index += 1
	_process_current_event()

func _process_current_event() -> void:
	while current_index < event_queue.size():
		var ev: Dictionary = event_queue[current_index]
		var ev_type: String = ev.get("type", "")
		match ev_type:
			"dialogue", "narration":
				var uid := _build_event_uid(current_label, current_index, ev)
				var was_seen := GlobalData.is_dialogue_seen(uid)
				_current_dialogue_uid = uid
				if is_skipping and not was_seen:
					set_skipping(false)
				_record_rollback_snapshot()
				var spk: String = ev.get("speaker", "") if ev_type == "dialogue" else ""
				_show_dialogue(spk, ev.get("text", ""), was_seen and is_skipping)
				GlobalData.mark_dialogue_seen(uid)
				return
			"menu":
				set_skipping(false)
				_record_rollback_snapshot()
				_show_choices(ev.get("options", []))
				return
			"input":
				set_skipping(false)
				_show_input_prompt(ev.get("var", "povnome"), ev.get("prompt", "Digite:"))
				return
			"scene":
				var inline_tr: String = ev.get("transition", "")
				var next_ev: Dictionary = event_queue[current_index + 1] if current_index + 1 < event_queue.size() else {}
				if inline_tr.is_empty() and next_ev.get("type", "") == "transition":
					var eff: String = next_ev.get("effect", "fade")
					if _is_fade_effect(eff):
						current_index += 1
						if GlobalData.settings.get("transitions_enabled", true) and not is_skipping:
							var p := _parse_fade_params(eff)
							transition_rect.visible = true
							transition_rect.color = Color(0, 0, 0, 0)
							if p.x > 0.0:
								var tw_in := create_tween()
								tw_in.tween_property(transition_rect, "color:a", 1.0, p.x)
								await tw_in.finished
							_change_background(ev.get("asset", ""), "")
							if p.y > 0.0:
								await get_tree().create_timer(p.y).timeout
							if p.z > 0.0:
								var tw_out := create_tween()
								tw_out.tween_property(transition_rect, "color:a", 0.0, p.z)
								await tw_out.finished
							transition_rect.visible = false
						else:
							_change_background(ev.get("asset", ""), eff)
					else:
						_change_background(ev.get("asset", ""), eff)
				elif inline_tr.is_empty() and _has_trailing_dissolve(current_index):
					_change_background(ev.get("asset", ""), "dissolve")
				else:
					_change_background(ev.get("asset", ""), inline_tr)
			"show":
				var inline_tr: String = ev.get("transition", "")
				if inline_tr.is_empty() and _has_trailing_dissolve(current_index):
					inline_tr = "dissolve"
				_show_character(
					ev.get("character", ""),
					ev.get("attributes", []),
					ev.get("removed_attributes", []),
					ev.get("position", "center"),
					inline_tr
				)
			"hide":
				var inline_tr: String = ev.get("transition", "")
				if inline_tr.is_empty() and _has_trailing_dissolve(current_index):
					inline_tr = "dissolve"
				_hide_character(ev.get("character", ""), inline_tr)
			"show_text":
				_show_center_text(ev.get("text", ""), ev.get("transition", ""))
			"transition":
				var eff: String = ev.get("effect", "fade")
				if _is_fade_effect(eff):
					await _play_screen_transition(eff)
			"pause":
				var dur := float(ev.get("duration", -1.0))
				if dur > 0.0:
					if not is_skipping:
						is_paused = true
						await get_tree().create_timer(dur).timeout
						is_paused = false
				else:
					set_skipping(false)
					return
			"audio":
				_play_audio_event(ev)
			"stop_audio":
				_stop_audio_event(ev.get("channel", "music"), ev.get("fadeout", 0.0))
			"camera":
				_handle_camera_effect(ev.get("effect", ""))
			"if":
				if _evaluate_condition(ev.get("condition", "")):
					var actions: Array = ev.get("actions", [])
					_inject_events_at_next(actions)
			"expression", "python_block":
				_execute_inline_expression(ev.get("code", ""))
			"jump":
				jump_to_label(ev.get("target", ""))
				return
			"return":
				set_skipping(false)
				emit_signal("returned_to_main_menu")
				GlobalData.change_scene_with_fade("res://ui/MainMenu/MainMenu.tscn")
				return
		current_index += 1
	set_skipping(false)
	emit_signal("chapter_finished", current_label)

func _inject_events_at_next(actions: Array) -> void:
	for i in range(actions.size()):
		event_queue.insert(current_index + 1 + i, (actions[i] as Dictionary).duplicate(true))

func _create_red_alarm_overlay() -> Control:
	var overlay := ColorRect.new()
	overlay.name = "red_alarm_overlay"
	overlay.color = Color(1.0, 0.0, 0.0, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 20
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	character_layer.add_child(overlay)
	if GlobalData.flashing_effects:
		var tw := overlay.create_tween().set_loops()
		tw.tween_property(overlay, "color:a", 0.25, 0.5).set_trans(Tween.TRANS_SINE)
		tw.tween_property(overlay, "color:a", 0.04, 0.5).set_trans(Tween.TRANS_SINE)
	else:
		overlay.color.a = 0.14
	return overlay

func _get_character_display_name(speaker_id: String) -> String:
	var tr_name := GlobalData.tr_ui("characters", speaker_id)
	if not tr_name.begins_with("characters."):
		return tr_name
	var char_info: Dictionary = manifest.get("characters", {}).get(speaker_id, {})
	return str(char_info.get("default_name", speaker_id))

func _show_dialogue(speaker_id: String, raw_text: String, instant: bool = false) -> void:
	dialogue_box.visible = true
	center_text_label.visible = false
	var final_text := _interpolate_text(raw_text)
	var display_name := ""
	var color_hex := "#ffffff"
	if speaker_id.is_empty():
		speaker_label.text = ""
	else:
		var char_info: Dictionary = manifest.get("characters", {}).get(speaker_id, {})
		display_name = _interpolate_text(_get_character_display_name(speaker_id))
		color_hex = str(char_info.get("color", "#ffffff"))
		speaker_label.text = "[b][color=%s]%s[/color][/b]" % [color_hex, display_name]
	_append_history(display_name, color_hex, final_text)
	dialogue_text.text = final_text
	if type_tween:
		type_tween.kill()
	if instant:
		dialogue_text.visible_ratio = 1.0
		is_typing = false
		return
	dialogue_text.visible_ratio = 0.0
	is_typing = true
	var speed: float = GlobalData.settings.get("typewriter_speed", 0.022)
	var duration := final_text.length() * speed
	type_tween = create_tween()
	type_tween.tween_property(dialogue_text, "visible_ratio", 1.0, max(duration, 0.05))
	type_tween.finished.connect(func(): is_typing = false)

func _append_history(speaker_name: String, color_hex: String, text: String) -> void:
	if not dialogue_history.is_empty():
		var last: Dictionary = dialogue_history.back()
		if last["speaker"] == speaker_name and last["text"] == text:
			return
	dialogue_history.append({"speaker": speaker_name, "color": color_hex, "text": text})
	if dialogue_history.size() > MAX_HISTORY_ENTRIES:
		dialogue_history.pop_front()

func _interpolate_text(text: String) -> String:
	var result := text
	for c_id in (manifest.get("characters", {}) as Dictionary).keys():
		result = result.replace("[%s.name]" % c_id, _get_character_display_name(c_id))
	for term_key in ["agencia_sigla", "agencia"]:
		var tr_val := GlobalData.tr_ui("terms", term_key)
		if not tr_val.begins_with("terms."):
			result = result.replace("[%s]" % term_key, tr_val)
	for key in variables.keys():
		result = result.replace("[%s]" % key, str(variables[key]))
	return result

func _change_background(asset_id: String, transition: String) -> void:
	_clear_stage_entities()
	current_bg_id = asset_id
	var bg_map: Dictionary = manifest.get("backgrounds", {})
	var cg_map: Dictionary = manifest.get("cgs", {})
	var tex: Texture2D = null
	if asset_id == "black":
		var img := Image.create(16, 16, false, Image.FORMAT_RGB8)
		img.fill(Color.BLACK)
		tex = ImageTexture.create_from_image(img)
	elif bg_map.has(asset_id):
		tex = load(bg_map[asset_id])
	elif cg_map.has(asset_id):
		tex = load(cg_map[asset_id])
		var cg_key := asset_id.trim_prefix("cg_").rstrip("0123456789")
		GlobalData.unlock_cg(cg_key)
	if tex == null:
		return
	var use_transitions: bool = GlobalData.settings.get("transitions_enabled", true) and not is_skipping
	if not transition.is_empty() and use_transitions:
		bg_front.texture = tex
		bg_front.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(bg_front, "modulate:a", 1.0, 0.45)
		tw.finished.connect(func():
			bg_back.texture = tex
			bg_front.modulate.a = 0.0
		)
	else:
		bg_front.texture = null
		bg_front.modulate.a = 0.0
		bg_back.texture = tex
		bg_back.visible = true

func _resolve_single_asset_path(asset_id: String) -> String:
	for section in ["assets", "overlays", "images", "backgrounds"]:
		var dict: Dictionary = manifest.get(section, {})
		if dict.has(asset_id):
			return str(dict[asset_id])
	return ""

func _show_character(char_id: String, attrs: Array, removed: Array, pos_name: String, transition: String) -> void:
	if char_id == "red_alarm_overlay":
		if not active_characters.has(char_id):
			active_characters[char_id] = _create_red_alarm_overlay()
		return
	var layered_defs: Dictionary = manifest.get("layered_characters", {})
	var anim_overlays: Dictionary = manifest.get("animated_overlays", {})
	var is_anim_overlay: bool = anim_overlays.has(char_id)
	var is_foreground_overlay: bool = (
		is_anim_overlay
		or (manifest.get("overlays", {}) as Dictionary).has(char_id)
		or char_id in FOREGROUND_OVERLAY_IDS
	)
	var is_fullscreen_fit: bool = is_foreground_overlay or char_id in FULLSCREEN_FIT_IDS
	var is_new_node := not active_characters.has(char_id)
	var sprite_node: LayeredCharacterSprite
	if not is_new_node:
		sprite_node = active_characters[char_id]
	else:
		sprite_node = LAYERED_CHAR_SCENE.instantiate()
		sprite_node.name = char_id
		sprite_node.z_index = (10 + active_characters.size()) if is_foreground_overlay else active_characters.size()
		character_layer.add_child(sprite_node)
		active_characters[char_id] = sprite_node
		if layered_defs.has(char_id):
			sprite_node.setup(layered_defs[char_id])
		elif is_anim_overlay:
			sprite_node.setup_animated_overlay(anim_overlays[char_id])
		else:
			var asset_path := _resolve_single_asset_path(char_id)
			if not asset_path.is_empty():
				var fit_zoom := 1.0 if is_fullscreen_fit else 0.85
				if is_fullscreen_fit:
					var tex: Texture2D = load(asset_path)
					if tex and tex.get_size().x > 0.0:
						var vp := get_viewport_rect().size
						fit_zoom = maxf(vp.x / tex.get_size().x, vp.y / tex.get_size().y)
				sprite_node.setup({
					"zoom": fit_zoom,
					"groups": {"base": {"default": "default", "items": {"default": asset_path}}},
					"overlays": {}
				})
			else:
				push_warning("Personagem ou overlay não encontrado no manifesto: " + char_id)
		if not transition.is_empty() and GlobalData.settings.get("transitions_enabled", true) and not is_skipping:
			sprite_node.modulate.a = 0.0
			create_tween().tween_property(sprite_node, "modulate:a", 1.0, 0.25)
	sprite_node.apply_attributes(attrs, removed)
	if is_new_node or not pos_name.is_empty():
		var target_pos := pos_name if not pos_name.is_empty() else "center"
		sprite_node.set_meta("vn_transform", target_pos)
		_apply_character_position(sprite_node, target_pos, is_foreground_overlay)

func _get_node_texture_height(node: Control) -> float:
	for child in node.get_children():
		if child is TextureRect and child.texture != null:
			return child.texture.get_size().y
	return 0.0

func _apply_character_position(node: Control, pos_name: String, is_overlay: bool = false) -> void:
	var viewport_size := get_viewport_rect().size
	var transforms: Dictionary = manifest.get("transforms", {})
	if transforms.has(pos_name):
		var t: Dictionary = transforms[pos_name]
		var xalign: float = t.get("xalign", 0.5)
		var yalign: float = t.get("yalign", 1.0)
		var yoffset: float = t.get("yoffset", 0.0)
		if t.has("zoom"):
			var z := float(t["zoom"])
			node.scale = Vector2(z, z)
		if t.has("xzoom"):
			node.scale.x = abs(node.scale.x) * float(t["xzoom"])
		if t.has("yzoom"):
			node.scale.y = abs(node.scale.y) * float(t["yzoom"])
		var tex_h : float = _get_node_texture_height(node) * abs(node.scale.y)
		var pos_y := viewport_size.y * yalign + tex_h * (1.0 - yalign) + yoffset
		node.position = Vector2(viewport_size.x * xalign, pos_y)
		return
	if is_overlay and pos_name == "center":
		node.position = Vector2(viewport_size.x * 0.5, viewport_size.y)
		return
	match pos_name:
		"left", "ladoEsquerdo":
			node.position = Vector2(viewport_size.x * 0.22, viewport_size.y)
		"right":
			node.position = Vector2(viewport_size.x * 0.78, viewport_size.y)
		_:
			node.position = Vector2(viewport_size.x * 0.5, viewport_size.y)

func _hide_character(char_id: String, transition: String) -> void:
	if not active_characters.has(char_id):
		return
	var node: LayeredCharacterSprite = active_characters[char_id]
	active_characters.erase(char_id)
	if not transition.is_empty() and GlobalData.settings.get("transitions_enabled", true) and not is_skipping:
		var tw := create_tween()
		tw.tween_property(node, "modulate:a", 0.0, 0.25)
		tw.finished.connect(node.queue_free)
	else:
		node.queue_free()

func _show_choices(options: Array) -> void:
	is_waiting_choice = true
	choices_container.visible = true
	for child in choices_container.get_children():
		child.queue_free()
	var first_btn: Button = null
	for opt in options:
		var opt_dict: Dictionary = opt
		var btn := Button.new()
		btn.text = _interpolate_text(str(opt_dict.get("text", "")))
		btn.focus_mode = Control.FOCUS_ALL
		btn.pressed.connect(func():
			choices_container.visible = false
			is_waiting_choice = false
			_inject_events_at_next(opt_dict.get("actions", []))
			advance()
		)
		choices_container.add_child(btn)
		if first_btn == null:
			first_btn = btn
	if first_btn:
		first_btn.call_deferred("grab_focus")

func _show_input_prompt(var_name: String, prompt_text: String) -> void:
	is_waiting_input = true
	pending_input_var = var_name
	input_prompt.text = prompt_text
	name_line_edit.text = ""
	input_panel.visible = true
	name_line_edit.grab_focus()

func _on_input_confirmed() -> void:
	if not is_waiting_input:
		return
	var typed := name_line_edit.text.strip_edges()
	if typed.is_empty():
		typed = str(variables.get("seuNome", "Leonardo"))
	variables[pending_input_var] = typed
	variables["seuNome"] = typed
	input_panel.visible = false
	is_waiting_input = false
	advance()

func _play_audio_event(ev: Dictionary) -> void:
	var track_key: String = ev.get("track", "")
	var audio_map: Dictionary = manifest.get("audio", {})
	var path: String = audio_map.get(track_key, "res://assets/" + track_key)
	if not ResourceLoader.exists(path):
		push_warning("Áudio não encontrado: " + path)
		return
	var raw_stream: AudioStream = load(path)
	var stream: AudioStream = raw_stream.duplicate()
	var channel: String = ev.get("channel", "sound")
	var should_loop: bool = ev.get("loop", false) or (channel == "music" and not ev.get("noloop", false))
	_set_stream_loop(stream, should_loop)
	var vol_linear: float = ev.get("volume", 1.0)
	var vol_db := linear_to_db(max(vol_linear, 0.001))
	var fadein: float = ev.get("fadein", 0.0)
	if channel == "music":
		current_music_id = track_key
		current_music_volume = vol_linear
		var next_player := music_b if active_music_player == music_a else music_a
		var old_player := active_music_player
		active_music_player = next_player
		next_player.stream = stream
		next_player.volume_db = -40.0 if fadein > 0.0 else vol_db
		next_player.play()
		if fadein > 0.0 and not is_skipping:
			var tw := create_tween().set_parallel(true)
			tw.tween_property(next_player, "volume_db", vol_db, fadein)
			if old_player.playing:
				tw.tween_property(old_player, "volume_db", -40.0, fadein)
				tw.chain().tween_callback(old_player.stop)
		else:
			next_player.volume_db = vol_db
			old_player.stop()
	else:
		if ev.get("loop", false):
			current_loop_sfx_id = track_key
			current_loop_sfx_volume = vol_linear
			loop_sfx_player.stream = stream
			loop_sfx_player.volume_db = vol_db
			loop_sfx_player.play()
		else:
			sfx_player.stream = stream
			sfx_player.volume_db = vol_db
			sfx_player.play()

func _stop_audio_event(channel: String, fadeout: float) -> void:
	if channel == "music":
		current_music_id = ""
		current_music_volume = 1.0
		if fadeout > 0.0 and active_music_player.playing and not is_skipping:
			var p := active_music_player
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -40.0, fadeout)
			tw.finished.connect(p.stop)
		else:
			active_music_player.stop()
	else:
		current_loop_sfx_id = ""
		current_loop_sfx_volume = 1.0
		sfx_player.stop()
		loop_sfx_player.stop()

func _show_center_text(text: String, transition: String) -> void:
	dialogue_box.visible = false
	center_text_label.text = "[center]%s[/center]" % _interpolate_text(text)
	center_text_label.visible = true
	if not transition.is_empty() and GlobalData.settings.get("transitions_enabled", true) and not is_skipping:
		center_text_label.modulate.a = 0.0
		create_tween().tween_property(center_text_label, "modulate:a", 1.0, 0.5)

func _play_screen_transition(effect: String) -> void:
	if not GlobalData.settings.get("transitions_enabled", true) or is_skipping:
		return
	var p := _parse_fade_params(effect)
	transition_rect.visible = true
	transition_rect.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	if p.x > 0.0:
		tw.tween_property(transition_rect, "color:a", 1.0, p.x)
	if p.y > 0.0:
		tw.tween_interval(p.y)
	if p.z > 0.0:
		tw.tween_property(transition_rect, "color:a", 0.0, p.z)
	await tw.finished
	transition_rect.visible = false

func _handle_camera_effect(effect: String) -> void:
	if effect == "earthquake_loop":
		current_camera_effect = "earthquake_loop"
		if not GlobalData.flashing_effects:
			return
		if earthquake_tween:
			earthquake_tween.kill()
		earthquake_tween = create_tween().set_loops()
		earthquake_tween.tween_property(camera, "offset", Vector2(-12, 8), 0.04)
		earthquake_tween.tween_property(camera, "offset", Vector2(15, -10), 0.04)
		earthquake_tween.tween_property(camera, "offset", Vector2(-8, -12), 0.04)
		earthquake_tween.tween_property(camera, "offset", Vector2(10, 14), 0.04)
	elif effect == "stop_earthquake":
		current_camera_effect = ""
		if earthquake_tween:
			earthquake_tween.kill()
		create_tween().tween_property(camera, "offset", Vector2.ZERO, 0.1)

func _evaluate_condition(cond: String) -> bool:
	var clean_cond := cond.replace("persistent.", "")
	if clean_cond == "flashing_effects":
		return GlobalData.flashing_effects
	if variables.has(clean_cond):
		return bool(variables[clean_cond])
	return true

func _execute_inline_expression(code: String) -> void:
	if "=" in code and not "==" in code:
		var parts := code.split("=", true, 1)
		var key := parts[0].strip_edges().replace("persistent.", "")
		var val_str := parts[1].strip_edges()
		if val_str == "True":
			variables[key] = true
		elif val_str == "False":
			variables[key] = false
		elif val_str.is_valid_int():
			variables[key] = int(val_str)

func create_state_snapshot() -> Dictionary:
	var chars_state := {}
	for c_id in active_characters.keys():
		var node: Node = active_characters[c_id]
		if node is LayeredCharacterSprite:
			var ctrl := node as Control
			chars_state[c_id] = {
				"attributes": node.get_state(),
				"transform": str(ctrl.get_meta("vn_transform", "center")),
				"position": {"x": ctrl.position.x, "y": ctrl.position.y},
				"scale": {"x": ctrl.scale.x, "y": ctrl.scale.y},
				"z_index": ctrl.z_index
			}
		else:
			chars_state[c_id] = {"procedural": true}
	return {
		"label": current_label,
		"index": current_index,
		"queue": event_queue.duplicate(true),
		"variables": variables.duplicate(true),
		"bg": current_bg_id,
		"music": current_music_id,
		"music_volume": current_music_volume,
		"loop_sfx": current_loop_sfx_id,
		"loop_sfx_volume": current_loop_sfx_volume,
		"camera_effect": current_camera_effect,
		"characters": chars_state,
		"history": dialogue_history.duplicate(true)
	}

func restore_state_snapshot(snap: Dictionary) -> void:
	set_skipping(false)
	is_paused = false
	is_waiting_choice = false
	is_waiting_input = false
	choices_container.visible = false
	input_panel.visible = false
	center_text_label.visible = false
	transition_rect.color = Color(0, 0, 0, 0)
	transition_rect.visible = false
	if get_viewport_rect().size == Vector2.ZERO:
		await get_tree().process_frame
	current_label = snap["label"]
	event_queue = (snap["queue"] as Array).duplicate(true)
	current_index = snap["index"]
	variables = (snap["variables"] as Dictionary).duplicate(true)
	if snap.has("history"):
		dialogue_history.assign(snap["history"])
	var saved_bg := str(snap.get("bg", ""))
	if not saved_bg.is_empty():
		_change_background(saved_bg, "")
	var target_music := str(snap.get("music", ""))
	var target_vol := float(snap.get("music_volume", 1.0))
	if target_music != current_music_id:
		if target_music.is_empty():
			_stop_audio_event("music", 0.2)
		else:
			_play_audio_event({
				"channel": "music",
				"track": target_music,
				"volume": target_vol,
				"fadein": 0.25,
				"loop": true
			})
	sfx_player.stop()
	var target_loop_sfx := str(snap.get("loop_sfx", ""))
	var target_loop_vol := float(snap.get("loop_sfx_volume", 1.0))
	if target_loop_sfx != current_loop_sfx_id:
		if target_loop_sfx.is_empty():
			_stop_audio_event("sound", 0.0)
		else:
			_play_audio_event({
				"channel": "sound",
				"track": target_loop_sfx,
				"volume": target_loop_vol,
				"loop": true
			})
	var target_cam := str(snap.get("camera_effect", ""))
	if target_cam != current_camera_effect:
		if target_cam == "earthquake_loop":
			_handle_camera_effect("earthquake_loop")
		else:
			_handle_camera_effect("stop_earthquake")
	for c_id in active_characters.keys():
		(active_characters[c_id] as Node).queue_free()
	active_characters.clear()
	var chars_state: Dictionary = snap.get("characters", {})
	for c_id in chars_state.keys():
		var c_data: Dictionary = chars_state[c_id]
		if c_data.get("procedural", false):
			_show_character(c_id, [], [], "center", "")
		else:
			var saved_transform := str(c_data.get("transform", "center"))
			_show_character(c_id, c_data.get("attributes", []), [], saved_transform, "")
			var ctrl := active_characters[c_id] as Control
			if c_data.has("position"):
				var pos_dict: Dictionary = c_data["position"]
				ctrl.position = Vector2(float(pos_dict["x"]), float(pos_dict["y"]))
			if c_data.has("scale"):
				var scale_dict: Dictionary = c_data["scale"]
				ctrl.scale = Vector2(float(scale_dict["x"]), float(scale_dict["y"]))
			if c_data.has("z_index"):
				ctrl.z_index = int(c_data["z_index"])
			ctrl.set_meta("vn_transform", saved_transform)
	_process_current_event()

func _record_rollback_snapshot() -> void:
	var snap := create_state_snapshot()
	if not rollback_stack.is_empty():
		var last: Dictionary = rollback_stack.back()
		if last["label"] == snap["label"] and last["index"] == snap["index"]:
			return
	rollback_stack.append(snap)
	if rollback_stack.size() > MAX_ROLLBACK_STEPS:
		rollback_stack.pop_front()

func _is_fade_effect(effect: String) -> bool:
	var low := effect.strip_edges().to_lower()
	return low == "fade" or low.begins_with("fade(")

func _parse_fade_params(effect: String) -> Vector3:
	var low := effect.strip_edges().to_lower()
	if low.begins_with("fade("):
		var nums := low.trim_prefix("fade(").trim_suffix(")").split(",")
		if nums.size() >= 3:
			return Vector3(float(nums[0]), float(nums[1]), float(nums[2]))
	return Vector3(0.4, 0.0, 0.4)

func _clear_stage_entities() -> void:
	for c_id in active_characters.keys():
		var node: Node = active_characters[c_id]
		if is_instance_valid(node):
			node.queue_free()
	active_characters.clear()

func rollback() -> void:
	if rollback_stack.size() <= 1:
		return
	rollback_stack.pop_back()
	var previous: Dictionary = rollback_stack.back()
	restore_state_snapshot(previous)
