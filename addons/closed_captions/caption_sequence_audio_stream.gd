@tool
extends CaptionedAudioStream
class_name CaptionSequenceAudioStream

## Array of all Captopns. Not meant to be manipulated directly. May not immediately update when you edit captions.
@export var _caption_array: Array[Caption] = []:
	set(new):
		_caption_array = new
		for caption in _caption_array:
			caption.changed.connect(_on_caption_changed.bind(caption))
		sort_captions()


func _validate_property(property: Dictionary) -> void:
	if property.name == "_caption_array":
		property.usage |= PROPERTY_USAGE_READ_ONLY


## Returns the currently displaying caption at the given time. Returns null if no caption is displaying.
func get_displaying_caption(at_time: float) -> Caption:
	if at_time < 0 or at_time > _caption_array[-1].delay + _caption_array[-1].duration:
		return null
	else:
		for i in _caption_array.size()-1:
			if _caption_array[i].duration > 0:
				if _caption_array[i].delay <= at_time and _caption_array[i].delay + _caption_array[i].duration >= at_time:
					return _caption_array[i]
			else:
				if i+1 < _caption_array.size():
					if _caption_array[i].delay <= at_time and min(_caption_array[i].delay + max_automatic_duration, _caption_array[i+1]) > at_time:
						return _caption_array[i]
				else:
					if _caption_array[i].delay <= at_time and _caption_array[i].delay + max_automatic_duration >= at_time:
						return _caption_array[i]
	return null


## Returns the next Caption to be displayed after a given time. Will return null from a time that is equal to or larger to the highest delay.
func get_queued_caption(at_time: float) -> Caption:
	if at_time <= 0:
		return _caption_array[0]
	else:
		for caption in _caption_array:
			if caption.delay > at_time:
				return caption
	return null


## Returns the delay from a given time to the next Caption. Will return -1 if no captions are left. Can return a negative delay if a caption is displaying at time and include_current is set.
func get_delay(from_time: float, include_current: bool = false) -> float:
	if (from_time > _caption_array[-1].delay and not include_current) or _caption_array[-1].delay + _caption_array[-1]._duration > from_time and include_current:
		return -1
	var current_caption = get_displaying_caption(from_time)
	if include_current and current_caption != null:
		return current_caption.delay - from_time
	else:
		return get_queued_caption(from_time).delay - from_time


## Calculates Configuration Warnings that will displayed by an AudioStreamPlayer.
func get_caption_warnings() -> int:
	var out:int = 0
	# Bitwise combining all warnigns of all captions.
	for caption in _caption_array: out |= caption.get_warnings()
	
	return out if _caption_array != [] else ConfigurationWarnings.MISSING


## Returns true if all Captions in the Stream have neutral positions.
func has_neutral_positioning() -> bool:
	for caption in _caption_array:
		if caption.position != Caption.Positions.CENTER: return false
	return true


## Sorts Caption by appearance
func sort_captions():
	_caption_array.sort_custom(func(a:Caption, b:Caption) -> bool: return a.delay < b.delay)


func get_length():
	audio_stream.get_length()


## Returns id of the caption queuing at given time. Returns -1 if no caption is queuing.
func get_queued_caption_id(at_time: float) -> int:
	return _caption_array.find(get_queued_caption(at_time))


func append_caption(new_caption: Caption):
	new_caption.changed.connect(_on_caption_changed.bind(new_caption))
	_caption_array.append(new_caption)
	_on_caption_changed(new_caption)


func erase_caption(old_caption: Caption):
	old_caption.changed.disconnect(_on_caption_changed)
	_caption_array.erase(old_caption)
	_on_caption_changed(old_caption)


func erase_caption_at(id: int):
	var old_caption: Caption = _caption_array.pop_at(id)
	old_caption.changed.disconnect(_on_caption_changed)
	_on_caption_changed(old_caption)


func _on_caption_changed(changed_caption: Caption):
	sort_captions()
	captions_changed.emit(changed_caption)
