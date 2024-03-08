@tool
extends SubtitleStream
class_name StaticSubtitleStream

@export var subtitle: Subtitle:
    set(sub):
        subtitle = sub
        current_subtitle = subtitle

func are_subtitles_valid() -> bool:
    return is_instance_valid(subtitle) and subtitle.is_valid()

