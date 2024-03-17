@tool
extends CaptionedAudioStream
class_name MultiCaptionAudioStream

#TODO: create costum UI
## Currently active or edited caption.
@export var caption: Caption = Caption.new():
	set(cap):
		caption = cap
@export var current_caption_id: int = 0:
	set(id):
		if id  >= 0 and id <= captions.size() - 1: current_caption_id = id
		current_caption = captions[id]
@export var append_current_caption: bool = false:
	set(_none):
		#TODO: introduce some proper checking later!
		captions.append(caption)
		caption = Caption.new()
@export var syncronise_current_caption: bool = false:
	set(_none):
		caption.delay = audio_stream.get_length()
@export var captions: Array[Caption]:
	set(cap):
		captions = cap
		sort_captions()
		if captions.size() > current_caption_id + 1: current_caption_id = captions.size() - 1
		caption = captions[current_caption_id]

func get_caption_warnings() -> int:
	var out:int = 0
	
	# Bitwise combining all warnigns of all captions.
	for caption in captions: out |= caption.get_warnings()
	
	return out

## Sorts Caption by appearance
func sort_captions():
	caption.sort_custom(func sort(a:Caption, b:Caption) -> bool: return a.delay < b.delay)

## Automatically calculate duration of captions depending on delay of next caption and the length of the audio stream.
## Will not assign duration longer than 5 seconds.
func assign_durations():
	for i in range(captions.size()-1):
		if captions[i].duration == 0:
			captions[i]._duration = min(5, captions[i+1].delay - captions[i].delay)
	
	if captions[-1].duration == 0:
		captions[-1]._duration == min(5, get_length() - captions[-1].delay)

func get_length():
	audio_stream.get_length()
