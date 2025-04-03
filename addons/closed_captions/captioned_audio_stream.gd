@tool
extends Resource
class_name CaptionedAudioStream

enum ConfigurationWarnings {
	MISSING,
	EMPTY,
	TOO_LONG,
	MISSING_SPEAKER,
	SET_POSITION,
	ROOT_RESOURCE
}

@export var audio_stream: AudioStream:
	set(new_stream):
		audio_stream = new_stream
		audio_stream_replaced.emit(new_stream)

## Configure the maximum time captions with an automatic duration will be displayed.
@export var max_automatic_duration: float = 5.0

signal captions_changed(changed_caption: Caption)
signal audio_stream_replaced(new_stream: AudioStream)

## Returns the currently displaying caption at the given position. Returns null if no caption is displaying.
func get_displaying_caption(at_time: float) -> Caption:
	return null

## Returns the next Caption to be displayed after a given position. Will return null from a position that is equal to or larger to the highest delay.
func get_queued_caption(at_time: float) -> Caption:
	return null

## Returns the delay from a given position to the next Caption. Will return -1 if no captions are left.
func get_delay(from_position: float, include_current: bool = false) -> float:
	return -1

## Calculates Configuration Warnings that will displayed by an AudioStreamPlayer.
func get_caption_warnings() -> int:
	return ConfigurationWarnings.ROOT_RESOURCE

## Returns true if all Captions in the Stream have neutral positions.
func has_neutral_positioning() -> bool:
	return true
