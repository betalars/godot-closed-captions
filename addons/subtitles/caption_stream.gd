@tool
extends Resource
class_name CaptionStream

var current_caption:Caption:
    set(new_caption):
        current_caption = new_caption
@export var stream: AudioStream:
    set(new_stream):
        stream = new_stream
        print("Emitted")
        emit_changed()

func are_captions_valid() -> bool:
    return current_caption.is_valid()
    
