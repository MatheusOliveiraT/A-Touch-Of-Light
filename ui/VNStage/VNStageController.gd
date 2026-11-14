extends Control
class_name VNStageController

signal returned_to_main_menu
signal chapter_finished(label_name: String)

const LAYERED_CHAR_SCENE := preload("res://personagens/layeredCharacter.tscn")
const MAX_ROLLBACK_STEPS := 60

@export var manifest_path := "res://data/res_manifest.json"
@export var script_files: Array[String] = [
	"res://data/res_script.vn",
	"res://data/res_prologo.vn",
	"res://data/res_cap1.vn"
]
@export var typewriter_speed := 0.022

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
var current_music_id := ""
var active_music_player: AudioStreamPlayer

var is_typing := false
var is_waiting_choice := false
var is_waiting_input := false
var is_paused := false
var pending_input_var := ""
var type_tween: Tween
var earthquake_tween: Tween
var rollback_stack: Array[Dictionary] = []

func _ready() -> void:
	active_music_player = music_a
	confirm_button.pressed.connect(_on_input_confirmed)
	name_line_edit.text_submitted.connect(func(_t): _on_input_confirmed())
	_load_manifest()
	_load_all_scripts()
	jump_to_label("start")

func _unhandled_input(event: InputEvent) -> void:
	if is_waiting_choice or is_waiting_input or is_paused:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact") or (
		event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	):
		get_viewport().set_input_as_handled()
		advance()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		get_viewport().set_input_as_handled()
		rollback()

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
	for path in script_files:
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
		return {"type": "show_text", "text": txt, "transition": parts[1].strip_edges() if parts.size() > 1 else null}
	if line.begins_with("scene "):
		var parts := line.substr(6).strip_edges().split(" with ", false, 1)
		return {"type": "scene", "asset": parts[0].strip_edges(), "transition": parts[1].strip_edges() if parts.size() > 1 else null}
	if line.begins_with("show "):
		var rest := line.substr(5).strip_edges()
		var tr: Variant = null
		var pos := "center"
		if " with " in rest:
			var p := rest.split(" with ", false, 1)
			rest = p[0].strip_edges()
			tr = p[1].strip_edges()
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
		return {"type": "show", "character": tokens[0], "attributes": attrs, "removed_attributes": rems, "position": pos, "transition": tr}
	if line.begins_with("hide "):
		var parts := line.substr(5).strip_edges().split(" with ", false, 1)
		return {"type": "hide", "character": parts[0].strip_edges(), "transition": parts[1].strip_edges() if parts.size() > 1 else null}
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
		return {"type": "pause", "duration": float(parts[1]) if parts.size() > 1 else null}
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
	event_queue = labels[label_name].duplicate(true)
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
			"dialogue":
				_record_rollback_snapshot()
				_show_dialogue(ev.get("speaker", ""), ev.get("text", ""))
				return
			"narration":
				_record_rollback_snapshot()
				_show_dialogue("", ev.get("text", ""))
				return
			"menu":
				_record_rollback_snapshot()
				_show_choices(ev.get("options", []))
				return
			"input":
				_show_input_prompt(ev.get("var", "povnome"), ev.get("prompt", "Digite:"))
				return
			"scene":
				_change_background(ev.get("asset", ""), ev.get("transition"))
			"show":
				_show_character(
					ev.get("character", ""),
					ev.get("attributes", []),
					ev.get("removed_attributes", []),
					ev.get("position", "center"),
					ev.get("transition")
				)
			"hide":
				_hide_character(ev.get("character", ""), ev.get("transition"))
			"show_text":
				_show_center_text(ev.get("text", ""), ev.get("transition"))
			"transition":
				await _play_screen_transition(ev.get("effect", "fade"))
			"pause":
				var dur = ev.get("duration")
				if dur != null and dur > 0.0:
					is_paused = true
					await get_tree().create_timer(dur).timeout
					is_paused = false
				else:
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
				emit_signal("returned_to_main_menu")
				return
		current_index += 1
	emit_signal("chapter_finished", current_label)
func _inject_events_at_next(actions: Array) -> void:
	for i in range(actions.size()):
		event_queue.insert(current_index + 1 + i, actions[i].duplicate(true))

func _show_dialogue(speaker_id: String, raw_text: String) -> void:
	dialogue_box.visible = true
	center_text_label.visible = false
	if speaker_id.is_empty():
		speaker_label.text = ""
		speaker_label.visible = false
	else:
		speaker_label.visible = true
		var char_info: Dictionary = manifest.get("characters", {}).get(speaker_id, {})
		var display_name: String = char_info.get("name", speaker_id)
		var color_hex: String = char_info.get("color", "#ffffff")
		speaker_label.text = "[b][color=%s]%s[/color][/b]" % [color_hex, _interpolate_text(display_name)]
	var final_text := _interpolate_text(raw_text)
	dialogue_text.text = final_text
	dialogue_text.visible_ratio = 0.0
	is_typing = true
	var duration := final_text.length() * typewriter_speed
	if type_tween:
		type_tween.kill()
	type_tween = create_tween()
	type_tween.tween_property(dialogue_text, "visible_ratio", 1.0, max(duration, 0.05))
	type_tween.finished.connect(func(): is_typing = false)

func _interpolate_text(text: String) -> String:
	var result := text
	for c_id in manifest.get("characters", {}).keys():
		var c_name: String = manifest["characters"][c_id].get("name", "")
		result = result.replace("[%s.name]" % c_id, c_name)
	for key in variables.keys():
		result = result.replace("[%s]" % key, str(variables[key]))
	return result

func _change_background(asset_id: String, transition) -> void:
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
		var cg_flag := asset_id.trim_prefix("cg_").rstrip("0123456789")
		if variables.has(cg_flag):
			variables[cg_flag] = true
	if tex == null:
		return
	if transition != null:
		bg_front.texture = tex
		bg_front.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(bg_front, "modulate:a", 1.0, 0.45)
		tw.finished.connect(func():
			bg_back.texture = tex
			bg_front.modulate.a = 0.0
		)
	else:
		bg_back.texture = tex

func _show_character(char_id: String, attrs: Array, removed: Array, pos_name: String, transition) -> void:
	var layered_defs: Dictionary = manifest.get("layered_characters", {})
	var sprite_node: LayeredCharacterSprite
	if active_characters.has(char_id):
		sprite_node = active_characters[char_id]
	else:
		sprite_node = LAYERED_CHAR_SCENE.instantiate()
		sprite_node.name = char_id
		character_layer.add_child(sprite_node)
		active_characters[char_id] = sprite_node
		if layered_defs.has(char_id):
			sprite_node.setup(layered_defs[char_id])
		elif manifest.get("assets", {}).has(char_id):
			sprite_node.setup({
				"zoom": 0.85,
				"groups": {"base": {"default": "default", "items": {"default": manifest["assets"][char_id]}}},
				"overlays": {}
			})
		if transition != null:
			sprite_node.modulate.a = 0.0
			create_tween().tween_property(sprite_node, "modulate:a", 1.0, 0.25)
	sprite_node.apply_attributes(attrs, removed)
	_apply_character_position(sprite_node, pos_name)

func _hide_character(char_id: String, transition) -> void:
	if not active_characters.has(char_id):
		return
	var node: LayeredCharacterSprite = active_characters[char_id]
	active_characters.erase(char_id)
	if transition != null:
		var tw := create_tween()
		tw.tween_property(node, "modulate:a", 0.0, 0.25)
		tw.finished.connect(node.queue_free)
	else:
		node.queue_free()

func _apply_character_position(node: Control, pos_name: String) -> void:
	var viewport_size := get_viewport_rect().size
	var transforms: Dictionary = manifest.get("transforms", {})
	if transforms.has(pos_name):
		var t: Dictionary = transforms[pos_name]
		var xalign: float = t.get("xalign", 0.5)
		var yoffset: float = t.get("yoffset", 0.0)
		node.position = Vector2(viewport_size.x * xalign, viewport_size.y + yoffset)
		if t.has("xzoom"):
			node.scale.x = abs(node.scale.x) * t["xzoom"]
		if t.has("yzoom"):
			node.scale.y = abs(node.scale.y) * t["yzoom"]
		return
	match pos_name:
		"left", "ladoEsquerdo":
			node.position = Vector2(viewport_size.x * 0.22, viewport_size.y)
		"right":
			node.position = Vector2(viewport_size.x * 0.78, viewport_size.y)
		_:
			node.position = Vector2(viewport_size.x * 0.5, viewport_size.y)

func _show_choices(options: Array) -> void:
	is_waiting_choice = true
	choices_container.visible = true
	for child in choices_container.get_children():
		child.queue_free()
	for opt in options:
		var btn := Button.new()
		btn.text = _interpolate_text(opt.get("text", ""))
		btn.pressed.connect(func():
			choices_container.visible = false
			is_waiting_choice = false
			_inject_events_at_next(opt.get("actions", []))
			advance()
		)
		choices_container.add_child(btn)

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
	var stream: AudioStream = load(path)
	var channel: String = ev.get("channel", "sound")
	var vol_linear: float = ev.get("volume", 1.0)
	var vol_db := linear_to_db(max(vol_linear, 0.001))
	var fadein: float = ev.get("fadein", 0.0)
	if channel == "music":
		current_music_id = track_key
		var next_player := music_b if active_music_player == music_a else music_a
		var old_player := active_music_player
		active_music_player = next_player
		next_player.stream = stream
		next_player.volume_db = -40.0 if fadein > 0.0 else vol_db
		next_player.play()
		if fadein > 0.0:
			var tw := create_tween().set_parallel(true)
			tw.tween_property(next_player, "volume_db", vol_db, fadein)
			if old_player.playing:
				tw.tween_property(old_player, "volume_db", -40.0, fadein)
				tw.chain().tween_callback(old_player.stop)
		else:
			old_player.stop()
	else:
		if ev.get("loop", false):
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
		if fadeout > 0.0 and active_music_player.playing:
			var p := active_music_player
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -40.0, fadeout)
			tw.finished.connect(p.stop)
		else:
			active_music_player.stop()
	else:
		sfx_player.stop()
		loop_sfx_player.stop()

func _show_center_text(text: String, transition) -> void:
	dialogue_box.visible = false
	center_text_label.text = "[center]%s[/center]" % _interpolate_text(text)
	center_text_label.visible = true
	if transition != null:
		center_text_label.modulate.a = 0.0
		create_tween().tween_property(center_text_label, "modulate:a", 1.0, 0.5)

func _play_screen_transition(effect: String) -> void:
	var fade_in_time := 0.4
	var fade_out_time := 0.4
	if effect.begins_with("Fade("):
		var nums := effect.trim_prefix("Fade(").trim_suffix(")").split(",")
		if nums.size() >= 3:
			fade_in_time = float(nums[0])
			fade_out_time = float(nums[2])
	transition_rect.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	if fade_in_time > 0.0:
		tw.tween_property(transition_rect, "color:a", 1.0, fade_in_time)
	if fade_out_time > 0.0:
		tw.tween_property(transition_rect, "color:a", 0.0, fade_out_time)
	await tw.finished

func _handle_camera_effect(effect: String) -> void:
	if effect == "earthquake_loop":
		if earthquake_tween:
			earthquake_tween.kill()
		earthquake_tween = create_tween().set_loops()
		earthquake_tween.tween_property(camera, "offset", Vector2(-12, 8), 0.04)
		earthquake_tween.tween_property(camera, "offset", Vector2(15, -10), 0.04)
		earthquake_tween.tween_property(camera, "offset", Vector2(-8, -12), 0.04)
		earthquake_tween.tween_property(camera, "offset", Vector2(10, 14), 0.04)
	elif effect == "stop_earthquake":
		if earthquake_tween:
			earthquake_tween.kill()
		create_tween().tween_property(camera, "offset", Vector2.ZERO, 0.1)

func _evaluate_condition(cond: String) -> bool:
	var clean_cond := cond.replace("persistent.", "")
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
		var node: LayeredCharacterSprite = active_characters[c_id]
		chars_state[c_id] = {
			"attributes": node.get_state(),
			"position": node.position
		}
	return {
		"label": current_label,
		"index": current_index,
		"queue": event_queue.duplicate(true),
		"variables": variables.duplicate(true),
		"bg": current_bg_id,
		"music": current_music_id,
		"characters": chars_state
	}

func restore_state_snapshot(snap: Dictionary) -> void:
	current_label = snap["label"]
	event_queue = snap["queue"].duplicate(true)
	current_index = snap["index"]
	variables = snap["variables"].duplicate(true)
	if snap["bg"] != current_bg_id:
		_change_background(snap["bg"], null)
	for c_id in active_characters.keys():
		active_characters[c_id].queue_free()
	active_characters.clear()
	var chars_state: Dictionary = snap.get("characters", {})
	for c_id in chars_state.keys():
		_show_character(c_id, chars_state[c_id]["attributes"], [], "center", null)
		active_characters[c_id].position = chars_state[c_id]["position"]
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

func rollback() -> void:
	if rollback_stack.size() <= 1:
		return
	rollback_stack.pop_back()
	var previous: Dictionary = rollback_stack.back()
	restore_state_snapshot(previous)
