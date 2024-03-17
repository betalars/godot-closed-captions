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

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	if captioned_stream == null: return warnings
	# Add any classes derived from CaptionedAudioStream here if this warning pops up ironiousely.
	if not (captioned_stream is SingleCaptionAudioStream): warnings.append("CaptionedAudioStream is an abstract class not designed to be used on it's own.")
	if captioned_stream.audio_stream != stream: warnings.append("Stream mismatch. Set Stream in \"Captioned Stream\", not in AudioPlayer.")
	elif stream == null: warnings.append("Audio Stream is not yet configured.")
	var caption_warnings:int = captioned_stream.get_caption_warnings()
	if bool(caption_warnings & 2**Caption.ConfigurationWarnings.EMPTY): warnings.append("Some Captions are empty.")
	if bool(caption_warnings & 2**Caption.ConfigurationWarnings.TOO_LONG): warnings.append("Some captions are too longer, than 15 words.")
	if bool(caption_warnings & 2**Caption.ConfigurationWarnings.MISSING_SPEAKER): warnings.append("Some captions have spoken text formatting but no spaker name.")
	return warnings

func play(from_position: float = 0.0):
	super.play(from_position)

func _on_resource_changed():
	stream = captioned_stream.audio_stream
