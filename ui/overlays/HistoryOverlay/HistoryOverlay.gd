extends Control
class_name HistoryOverlay

@onready var scroll_container: ScrollContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var history_vbox: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/HistoryVBox

var stage_controller: VNStageController = null
var menu_shell: GameMenuShell = null

func _ready() -> void:
	_populate_history()

func configure(_tab_id: String, stage_ref: VNStageController, shell: GameMenuShell) -> void:
	stage_controller = stage_ref
	menu_shell = shell
	if is_node_ready():
		_populate_history()

func _populate_history() -> void:
	for child in history_vbox.get_children():
		child.queue_free()
	if not is_instance_valid(stage_controller):
		return
	for entry in stage_controller.dialogue_history:
		var speaker: String = str(entry.get("speaker", ""))
		var color_hex: String = str(entry.get("color", "#ffffff"))
		var text: String = str(entry.get("text", ""))
		var item_vbox := VBoxContainer.new()
		item_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if not speaker.is_empty():
			var speaker_lbl := RichTextLabel.new()
			speaker_lbl.bbcode_enabled = true
			speaker_lbl.fit_content = true
			speaker_lbl.scroll_active = false
			speaker_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			speaker_lbl.text = "[b][color=%s]%s[/color][/b]" % [color_hex, speaker]
			item_vbox.add_child(speaker_lbl)
		var body_lbl := RichTextLabel.new()
		body_lbl.bbcode_enabled = true
		body_lbl.fit_content = true
		body_lbl.scroll_active = false
		body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		body_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body_lbl.text = text if not speaker.is_empty() else "[i]%s[/i]" % text
		item_vbox.add_child(body_lbl)
		history_vbox.add_child(item_vbox)
	_scroll_to_bottom.call_deferred()
	
func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	var v_bar := scroll_container.get_v_scroll_bar()
	if v_bar:
		scroll_container.scroll_vertical = int(v_bar.max_value)
