@tool
extends AudioStreamPlayer
class_name CaptionedAudioStreamPlayer

@export var captioned_stream:CaptionedAudioStream:
    set(sub_stream):
        if not sub_stream == null:
            stream = sub_stream.stream
            sub_stream.changed.connect(func f(): _on_resource_changed())
        else:
            stream == null
        captioned_stream = sub_stream

func _get_configuration_warnings() -> PackedStringArray:
    var warnings:PackedStringArray = []
    if captioned_stream == null: return warnings
    # Add any classes derived from CaptionedAudioStream here if this warning pops up ironiousely.
    if not (captioned_stream is SingleCaptionAudioStream): warnings.append("CaptionedAudioStream is an abstract class not designed to be used on it's onw.")
    if captioned_stream.stream != stream: warnings.append("Stream mismatch. Set Stream in \"Captioned Stream\", not in AudioPlayer.")
    elif stream == null: warnings.append("Audio Stream is not yet configured.")
    if captioned_stream.has_neutral_positioning(): warnings.append("All Captions are use center position. This may be unintentional.")
    if not captioned_stream.are_captions_valid(): warnings.append("Some Captions are not valid. They may be empty or too long.")
    return warnings

func play(from_position: float = 0.0):
    super.play(from_position)

func _on_resource_changed():
    stream = captioned_stream.stream
