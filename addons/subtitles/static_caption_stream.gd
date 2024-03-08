@tool
extends CaptionStream
class_name StaticCaptionStream

@export var caption: Caption:
    set(sub):
        caption = sub
        current_caption = caption

func are_captions_valid() -> bool:
    return is_instance_valid(caption) and caption.is_valid()

