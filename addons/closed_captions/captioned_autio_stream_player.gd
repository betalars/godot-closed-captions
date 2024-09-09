@tool
extends AudioStreamPlayer
class_name CaptionedAudioStreamPlayer

@export var captioned_stream:CaptionedAudioStream:
	set(sub_stream):
		if not sub_stream == null:
			stream = sub_stream.audio_stream
			sub_stream.changed.connect(func f(): _on_resource_changed())
		else:
			stream == null
		captioned_stream = sub_stream

func _set(property: StringName, value: Variant) -> bool:
	if property == "stream":
		if value != null and not captioned_stream.audio_stream == value:
			captioned_stream.audio_stream = value
	return false

func _ready():
	if autoplay:
		_play()

func _process(delta):
	if playing:
		if captioned_stream is MultiCaptionAudioStream:
			if not captioned_stream.finished:
				if super.get_playback_position() > captioned_stream.caption.delay:
					CaptionServer.push_caption(self, captioned_stream.caption)
					captioned_stream.next()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if captioned_stream == null: return warnings
	# Add any classes derived from CaptionedAudioStream here if this warning pops up ironiousely.
	if not (captioned_stream is SimpleCaptionAudioStream or captioned_stream is MultiCaptionAudioStream): warnings.append("CaptionedAudioStream is an abstract class not designed to be used on it's own.")
	if captioned_stream.audio_stream != stream: warnings.append("Set Stream in \"Captioned Stream\", not in AudioPlayer.")
	var caption_warnings:int = captioned_stream.get_caption_warnings()
	if bool(caption_warnings & 2**Caption.ConfigurationWarnings.EMPTY): warnings.append("Some Captions are empty.")
	if bool(caption_warnings & 2**Caption.ConfigurationWarnings.TOO_LONG): warnings.append("Some captions are too longer, than 15 words.")
	if bool(caption_warnings & 2**Caption.ConfigurationWarnings.MISSING_SPEAKER): warnings.append("Some captions have spoken text formatting but no spaker name.")
	return warnings

func play(from_position: float = 0.0):
	super.play(from_position)
	self._play(from_position)

func _play(from_position: float = 0.0):
	if captioned_stream is MultiCaptionAudioStream:
		captioned_stream.sort_captions()
		captioned_stream.assign_durations()
		captioned_stream.select_caption = captioned_stream.get_id_by_offset_time(from_position)
	
	if captioned_stream.caption.delay - from_position > 0:
		await get_tree().create_timer(captioned_stream.current_caption.delay - from_position).timeout
	CaptionServer.push_caption(self, captioned_stream.current_caption)
	
	if captioned_stream is MultiCaptionAudioStream:
		captioned_stream.select_caption += 1

func _on_resource_changed():
	stream = captioned_stream.audio_stream
