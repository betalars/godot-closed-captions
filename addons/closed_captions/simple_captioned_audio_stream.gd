class_name SimpleCaptionedAudioStream extends CaptionedAudioStream

var caption: Caption = Caption.new():
	set(new):
		if caption != null:
			caption.changed.disconnect(captions_changed.emit)
		caption = new
		caption.changed.connect(captions_changed.emit)

## Returns the currently displaying caption at the given position. Returns null if no caption is displaying.
func get_displaying_caption(at_time: float) -> Caption:
	if caption.duration > 0:
		return caption if at_time >= caption.delay and caption.delay + caption.duration else null
	else:
		return caption if at_time >= caption.delay and min(audio_stream.get_length(), caption.delay + max_automatic_duration) else null

## Returns the next Caption to be displayed after a given position. Will return null from a position that is equal to or larger to the highest delay.
func get_queued_caption(at_time: float) -> Caption:
	return caption if at_time < caption.delay else null

## Returns the delay from a given position to the next Caption. Will return -1 if no captions are left.
func get_delay(from_time: float, include_current: bool = false) -> float:
	if include_current:
		if caption.duration > 0:
			return caption.delay - from_time if caption.delay + caption.duration > from_time else -1
		else:
			return caption.delay - from_time if min(audio_stream.get_length(), caption.delay + max_automatic_duration) > from_time else -1
	else:
		return caption.delay - from_time if caption.delay > from_time else -1

## Calculates Configuration Warnings that will displayed by an AudioStreamPlayer.
func get_caption_warnings() -> int:
	return caption.get_warnings()

## Returns true if all Captions in the Stream have neutral positions.
func has_neutral_positioning() -> bool:
	return caption.position == Caption.Positions.CENTER
