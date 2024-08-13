@tool
extends MarginContainer
class_name CaptionDisplay

var _display: VBoxContainer = VBoxContainer.new()

var speakers: Array[Array] = [["", 0],["", 0],["", 0],["", 0]]

## Shows the Captions being displayed. Keep in mind: those are the resources the CaptionLabels are being generated from, not the actual Labels.
@export var displaying: Array[Caption] = []:
	set(display):
		displaying = display
		_update_displayed_labels()
var _displayed_captions: Array[CaptionLabel] = []
## Select the audio busses this Label is listening to.
@export_flags_2d_physics var source_bus: int = 255

## Captions will only be displayed on onw caption display. Set a higher priority to choose this label over another that may display the same caption.
@export_range(0, 100) var priority: float = 10

@export_range(0, 100) var side_margin:int = 50:
	set(margin):
		side_margin = margin
		add_theme_constant_override("margin_left", side_margin)
		add_theme_constant_override("margin_right", side_margin)

@export_range(0, 100) var top_bottom_margin:int = 25:
	set(margin):
		top_bottom_margin = margin
		add_theme_constant_override("margin_top", top_bottom_margin)
		add_theme_constant_override("margin_bottom", top_bottom_margin)

# Determine, if this label is rendered compatcly
@export var is_compact: bool = false:
	set(small):
		is_compact = small
		for caption in _display.get_children():
			caption.is_compact = small

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	# get_viewport_rect in editor mode returns the editor viewport, therefore we need this workaround:
	var screen_size = Rect2(Vector2(), Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")))
	if not get_rect().is_equal_approx(screen_size) and not is_compact:
		warnings.append("This node is intended to be used covering the entire screen when is compact is false.")
	if get_child_count() != 0: warnings.append("Do not attatch children to Captions Container.")
	return warnings

func _ready():
	add_child(_display, false, Node.INTERNAL_MODE_BACK)
	_display.alignment = BoxContainer.ALIGNMENT_END
	
	CaptionServer.signup_display(self)

func _exit_tree():
	CaptionServer.signoff_display(self)

## Displays a caption for its duration.
func display_caption(caption: Caption):
	displaying.append(caption)
	_update_displayed_labels()
	# Using a deferred call to return without a delay.
	# Also using the internal duration of the caption, because this is where the auto generated length is stored.
	pull_caption.call_deferred(caption, caption._duration)

## Pulls a caption from the display, awaiting an optional display.
func pull_caption(caption: Caption, delay:float = 0):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	displaying.erase(caption)
	_update_displayed_labels()

## Checks if it is receiving Captions from a Bus by the bus name.
func is_receiving_bus(bus: StringName):
	return (source_bus & 2 ** AudioServer.get_bus_index(bus)) > 0

## Checks if the speaker of a caption has spoken recently and, if another speaker has used the same color since. Used to determine, if speaker name must be displayed or not.
func _is_speaker_name_recent(caption:Caption) -> bool:
	var ret:bool = false
	if speakers[caption.speaker_color][0] == caption.speaker_name:
		ret = Time.get_unix_time_from_system() - speakers[caption.speaker_color][1] < 60
	speakers[caption.speaker_color][0] = caption.speaker_name if (!caption.speaker_name == "") else "sfx"
	speakers[caption.speaker_color][1] = Time.get_unix_time_from_system()
	return ret

## Removes the Label belonging to a caption from children of _display.
func _remove_caption(caption:Caption) -> void:
	for child:CaptionLabel in _display.get_children():
		if child.caption == caption:
			_display.remove_child(child)

## Finds the label for a given caption amongst the children of _display.
func _find_caption_label(caption:Caption) -> CaptionLabel:
	for child:CaptionLabel in _display.get_children():
		if child.caption == caption:
			return child
	return null

## Finds the index for a given caption amongst the children of _display.
func _find_caption_label_id(caption:Caption) -> int:
	var cap: CaptionLabel = _find_caption_label(caption)
	if cap == null: return -1
	return _display.get_children().find(cap)

## Rearranges children of _display to reflect the order of displaying
func _update_displayed_labels():
	var current_display: Array[Caption] = []
	for label:CaptionLabel in _display.get_children(true):
		current_display.append(label.caption)
	for caption in displaying:
		if not current_display.has(caption):
			_display.add_child(CaptionLabel.new(caption, !_is_speaker_name_recent(caption), is_compact))
	for caption in current_display:
		if not displaying.has(caption):
			_remove_caption(caption)
	for i in range(displaying.size()):
		_display.move_child(_find_caption_label(displaying[i]), i)
