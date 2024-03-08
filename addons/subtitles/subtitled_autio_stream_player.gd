@tool
extends AudioStreamPlayer
class_name SubtitledAudioStreamPlayer

@export var subtitled_stream:StaticSubtitleStream:
    set(sub_stream):
        if not sub_stream == null:
            stream = sub_stream.stream
            sub_stream.changed.connect(func f(): _on_resource_changed())
        else:
            stream == null
        subtitled_stream = sub_stream

func _get_configuration_warnings() -> PackedStringArray:
    var warnings:PackedStringArray = []
    if subtitled_stream == null: return warnings
    if subtitled_stream.stream != stream: warnings.append("Stream mismatch. Set Stream in \"Subtitled Stream\", not in AudioPlayer.")
    elif stream == null: warnings.append("Audio Stream is not yet configured.")
    if not subtitled_stream.are_subtitles_valid(): warnings.append("Some Subtitles are not valid. They may be empty or too long.")
    return warnings

func play(from_position: float = 0.0):
    print("playing")
    super.play(from_position)

func set_playing(playing:bool):
    print("yeet")

func _on_resource_changed():
    print("called")
    stream = subtitled_stream.stream
