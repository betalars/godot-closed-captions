@tool
class_name Cast extends Resource

@export var speakers: Array[Speaker] = []

var _saved_speakers: Array[Speaker]

var changed_since_last_save:bool = false:
	set(changed):
		changed_since_last_save = changed
		if changed: _saved_speakers = []
	get():
		## Checking if any changes may have occured.
		if changed_since_last_save: return true
		if _saved_speakers.size() != speakers.size(): return true
		for i in range(_saved_speakers.size()):
			if speakers[i] != _saved_speakers[i]:
				return true
		return false

func get_speaker_by_name(speaker_name: StringName) -> Speaker:
	for speaker in speakers:
		if speaker.name == speaker_name:
			return speaker
	var speaker := Speaker.new(speaker_name)
	speaker.first_change.connect(func (speaker:Speaker): speakers.append(speaker))
	return speaker

func load_speakers(speaker_array: Array[Speaker]):
	speakers = speaker_array
	_saved_speakers = speaker_array.duplicate()
	for speaker in speaker_array:
		speaker.changed.connect(func():changed_since_last_save = true)
		speaker.name_changed.connect(func():changed_since_last_save = true)
