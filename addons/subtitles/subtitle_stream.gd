@tool
extends Resource
class_name SubtitleStream

var current_subtitle:Subtitle:
    set(new_subtitle):
        current_subtitle = new_subtitle
@export var stream: AudioStream:
    set(new_stream):
        stream = new_stream
        print("Emitted")
        emit_changed()

func are_subtitles_valid() -> bool:
    return current_subtitle.is_valid()
    
