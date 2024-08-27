@tool
extends CaptionedAudioStream
class_name MultiCaptionAudioStream


## Currently active or edited caption. Setting this null will erase it!
@export var caption: Caption = Caption.new():
	set(cap):
		if cap != caption:
			current_caption_set.emit(cap)
		caption = cap
		if cap == null:
			erase_caption(caption)
		elif not _captions_array.has(cap):
			append_caption(caption)
## ID of the current caption, naming convention chosen to create more intuitive Inspector UI.
@export var select_caption: int = 0:
	set(id):
		select_caption = id if id >= 0 else _captions_array.size() + id
		# This will raise acreate a new element, but only when max array index is missed by one.
		if select_caption == _captions_array.size():
			append_caption(Caption.new())
		if not _captions_array == []: caption = _captions_array[select_caption]

## Array of all Captopns. Not meant to be manipulated directly. May not immediately update when you edit captions.
@export var _captions_array: Array[Caption]:
	set(cap):
		_captions_array = cap
		sort_captions()
		if _captions_array.size() > select_caption + 1: select_caption = _captions_array.size() - 1
		caption = _captions_array[select_caption]

var finished = false

func _validate_property(property: Dictionary) -> void:
	if property.name == "_captions_array":
		property.usage |= PROPERTY_USAGE_READ_ONLY

func get_caption_warnings() -> int:
	var out:int = 0
	
	# Bitwise combining all warnigns of all captions.
	for caption in _captions_array: out |= caption.get_warnings()
	
	return out

## Sorts Caption by appearance
func sort_captions():
	_captions_array.sort_custom(func(a:Caption, b:Caption) -> bool: return a.delay < b.delay)

## Automatically calculate duration of captions depending on delay of next caption and the length of the audio stream.
## Will not assign duration longer than 5 seconds. Will always leave a small gap.
func assign_durations():
	for i in range(_captions_array.size()-1):
		if _captions_array[i].duration == 0:
			_captions_array[i]._duration = min(5, _captions_array[i+1].delay - _captions_array[i].delay + 0.05)
			_captions_array[i+1].previous = _captions_array[i]
	
	if _captions_array[-1].duration == 0:
		_captions_array[-1]._duration = 5

func get_length():
	audio_stream.get_length()

func next():
	if select_caption < _captions_array.size() - 1:
		select_caption += 1
		finished = false
	else:
		finished = true

func get_id_by_offset_time(time: float) -> int:
	return _captions_array.find(get_caption_by_offset_time(time))
	
func get_caption_by_offset_time(time: float) -> Caption:
	if time <= 0:
		return _captions_array[0]
	else:
		for caption in _captions_array:
			if caption.delay + caption._duration > time:
				return caption
	return null
	
func append_caption(new_caption: Caption):
	new_caption.changed.connect(func f(): _on_caption_changed(new_caption))
	_captions_array.append(new_caption)
	_on_caption_changed(new_caption)

func erase_caption(old_caption: Caption):
	old_caption.changed.disconnect(_on_caption_changed)
	_captions_array.erase(old_caption)
	_on_caption_changed(old_caption)
	
func _on_caption_changed(changed_caption: Caption):
	sort_captions()
	assign_durations()
	caption_changed.emit(changed_caption)
