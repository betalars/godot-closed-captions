@tool
extends Resource
class_name CaptionedAudioStream

var current_caption:Caption:
	set(new_caption):
		current_caption = new_caption
@export var stream: AudioStream:
	set(new_stream):
		stream = new_stream
		print("Emitted")
		emit_changed()

func get_caption_warnings() -> int:
	return current_caption.get_warnings()
	
func has_neutral_positioning() -> bool:
	return current_caption.has_neutral_positioning()
