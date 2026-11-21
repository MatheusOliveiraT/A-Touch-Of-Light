extends Control
class_name LayeredCharacterSprite

var config: Dictionary = {}
var group_nodes: Dictionary = {}      
var overlay_nodes: Dictionary = {}    
var attr_to_group: Dictionary = {}    
var active_attributes: Array[String] = [] 

var _anim_textures: Array[Texture2D] = []
var _anim_fps := 6.0
var _anim_timer := 0.0
var _anim_index := 0
var _anim_rect: TextureRect = null

func setup(char_config: Dictionary) -> void:
	config = char_config
	scale = Vector2.ONE * config.get("zoom", 1.0)
	_clear_layers()
	var groups: Dictionary = config.get("groups", {})
	var overlays: Dictionary = config.get("overlays", {})
	var order: Array = config.get("layer_order", [])
	if order.is_empty():
		for g in groups.keys():
			order.append({"kind": "group", "name": g})
		for o in overlays.keys():
			order.append({"kind": "overlay", "name": o})
	for entry in order:
		var kind: String = entry["kind"]
		var layer_name: String = entry["name"]
		var tex_rect := _create_layer_node(layer_name)
		if kind == "group":
			group_nodes[layer_name] = tex_rect
			var grp_data: Dictionary = groups[layer_name]
			for attr_name in grp_data["items"].keys():
				attr_to_group[attr_name] = layer_name
			var def_attr = grp_data.get("default")
			if def_attr != null and grp_data["items"].has(def_attr):
				_assign_centered_texture(tex_rect, load(grp_data["items"][def_attr]))
				active_attributes.append(def_attr)
		elif kind == "overlay":
			overlay_nodes[layer_name] = tex_rect
			_assign_centered_texture(tex_rect, load(overlays[layer_name]))
			tex_rect.visible = false

func apply_attributes(attributes: Array, removed_attributes: Array = []) -> void:
	var groups: Dictionary = config.get("groups", {})
	for attr in attributes:
		if attr_to_group.has(attr):
			var grp_name: String = attr_to_group[attr]
			var tex_path: String = groups[grp_name]["items"][attr]
			_assign_centered_texture(group_nodes[grp_name], load(tex_path))
			_register_group_attribute(grp_name, attr)
		elif overlay_nodes.has(attr):
			overlay_nodes[attr].visible = true
			if not active_attributes.has(attr):
				active_attributes.append(attr)
	for rem in removed_attributes:
		if overlay_nodes.has(rem):
			overlay_nodes[rem].visible = false
			active_attributes.erase(rem)

func _assign_centered_texture(rect: TextureRect, tex: Texture2D) -> void:
	rect.texture = tex
	if tex:
		var sz := tex.get_size()
		rect.size = sz
		rect.position = Vector2(-sz.x * 0.5, -sz.y)

func _create_layer_node(node_name: String) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.stretch_mode = TextureRect.STRETCH_KEEP
	add_child(rect)
	return rect

func get_state() -> Array[String]:
	return active_attributes.duplicate()

func restore_state(saved_attributes: Array) -> void:
	for ov_name in overlay_nodes.keys():
		overlay_nodes[ov_name].visible = false
	active_attributes.clear()
	apply_attributes(saved_attributes)

func _register_group_attribute(grp_name: String, new_attr: String) -> void:
	var items: Dictionary = config["groups"][grp_name]["items"]
	for existing in active_attributes.duplicate():
		if items.has(existing):
			active_attributes.erase(existing)
	active_attributes.append(new_attr)

func _clear_layers() -> void:
	for child in get_children():
		child.queue_free()
	group_nodes.clear()
	overlay_nodes.clear()
	attr_to_group.clear()
	active_attributes.clear()
	_anim_textures.clear()
	_anim_rect = null

func setup_animated_overlay(anim_cfg: Dictionary) -> void:
	config = anim_cfg
	scale = Vector2.ONE * float(anim_cfg.get("zoom", 1.0))
	_clear_layers()
	_anim_textures.clear()
	for frame_path in anim_cfg.get("frames", []):
		var tex: Texture2D = load(str(frame_path))
		if tex:
			_anim_textures.append(tex)
	_anim_fps = float(anim_cfg.get("fps", 6.0))
	_anim_timer = 0.0
	_anim_index = 0
	if not _anim_textures.is_empty():
		_anim_rect = _create_layer_node("animated_frame")
		_assign_centered_texture(_anim_rect, _anim_textures[0])

func _process(delta: float) -> void:
	if _anim_textures.size() <= 1 or _anim_rect == null:
		return
	_anim_timer += delta
	var frame_dur: float = 1.0 / maxf(_anim_fps, 0.1)
	if _anim_timer >= frame_dur:
		_anim_timer = fmod(_anim_timer, frame_dur)
		_anim_index = (_anim_index + 1) % _anim_textures.size()
		_assign_centered_texture(_anim_rect, _anim_textures[_anim_index])
