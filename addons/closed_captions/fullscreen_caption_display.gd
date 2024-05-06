@tool
extends MarginContainer
class_name CaptionDisplay

var _display: VBoxContainer = VBoxContainer.new()

var speakers: Array[Array] = [["", 0],["", 0],["", 0],["", 0]]

@export var displaying: Array[Caption] = []:
	set(display):
		for caption in display:
			if not displaying.has(caption):
				_display.add_child(CaptionLabel.new(caption, !_is_speaker_name_recemt(caption), false))
		for caption in displaying:
			if not display.has(caption):
				_remove_caption(caption)
		displaying = display
		_order_captions()
var _displayed_captions: Array[CaptionLabel] = []
@export_flags_2d_physics var source_bus: int = 2
@export_range(0, 100) var priority: float = 10

@export_range(0, 100) var side_margin:int = 50:
	set(margin):
		side_margin = margin
		add_theme_constant_override("margin_left", side_margin)
		add_theme_constant_override("margin_right", side_margin)

@export_range(0, 100) var bottom_margin:int = 25:
	set(margin):
		bottom_margin = margin
		add_theme_constant_override("margin_bottom", bottom_margin)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	# get_viewport_rect in editor mode returns the editor viewport, therefore we need this workaround:
	var screen_size = Rect2(Vector2(), Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")))
	if not get_rect().is_equal_approx(screen_size):
		warnings.append("This node is intended to be used covering the entire screen. Use Compact Captions Container for small captions.")
	if get_child_count() != 0: warnings.append("Do not attatch children to Captions Container.")
	return warnings

func _ready():
	add_child(_display, false, Node.INTERNAL_MODE_BACK)
	_display.alignment = BoxContainer.ALIGNMENT_END
	
	CaptionServer.signup_display(self)

func _exit_tree():
	CaptionServer.signoff_display(self)

func display_caption(caption: Caption, previous: Caption = null):
	pass

func pull_caption(caption: Caption):
	if displaying.has(caption):
		displaying.erase(caption)

func is_receiving_bus(bus: StringName):
	return (source_bus & 2 ** AudioServer.get_bus_index(bus)) > 0

func _is_speaker_name_recemt(caption:Caption) -> bool:
	var ret:bool = false
	if speakers[caption.speaker_color][0] == caption.speaker_name:
		ret = Time.get_unix_time_from_system() - speakers[caption.speaker_color][1] < 60
	speakers[caption.speaker_color][0] = caption.speaker_name
	speakers[caption.speaker_color][1] = Time.get_unix_time_from_system()
	return ret

func _remove_caption(caption:Caption) -> void:
	for child:CaptionLabel in _display.get_children():
		if child.caption == caption:
			_display.remove_child(child)

func _find_caption_label(caption:Caption) -> CaptionLabel:
	for child:CaptionLabel in _display.get_children():
		if child.caption == caption:
			return child
	return null

func _find_caption_label_id(caption:Caption) -> int:
	var cap: CaptionLabel = _find_caption_label(caption)
	if cap == null: return -1
	return _display.get_children().find(cap)

func _order_captions() -> void:
	for i in range(displaying.size()):
		_display.move_child(_find_caption_label(displaying[i]), i)
