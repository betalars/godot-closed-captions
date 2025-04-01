@tool
extends Resource
class_name SimpleCaptionedAudioStream

@export var caption:Caption:
	set(new_caption):
		if caption != null:
			caption.changed.disconnect(captions_changed.emit)
		caption = new_caption
		# calls a special handle if this is one of its child classes. This is as close as I could get to overlaying a set function.
		if self is MultiCaptionAudioStream:
			handle_caption_set(caption)
		if caption != null:
			caption.changed.connect(captions_changed.emit)
		caption_set.emit(caption)
		emit_changed()
@export var audio_stream: AudioStream:
	set(new_stream):
		audio_stream = new_stream
		audio_stream_replaced.emit(new_stream)

signal caption_set(caption:Caption)
signal captions_changed(changed_caption: Caption)
signal audio_stream_replaced(new_stream: AudioStream)

func get_caption_warnings() -> int:
	return caption.get_warnings() if caption != null else Caption.ConfigurationWarnings.MISSING
	
func has_neutral_positioning() -> bool:
	return caption.has_neutral_positioning()

# See comment in set(new_caption)
func handle_caption_set(caption: Caption):
	assert(false)
