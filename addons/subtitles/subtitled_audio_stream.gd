extends AudioStream
class_name SubtitledAudioStream

var is_stream_static
@export var stream: AudioStream:
    set(new_stream):
        if new_stream is SubtitledAudioStream:
            push_error("Can't add a subtitled stream to itself.")
            return
        
        is_stream_static = new_stream is AudioStreamWAV or new_stream is AudioStreamMP3 or new_stream is AudioStreamOggVorbis
        
        stream = new_stream

var _current_audio_stream_playback:AudioStreamPlayback
        
func _get_beat_count() -> int:
    if is_stream_static: return stream.beat_count
    else: return 0
    
func _get_bpm() -> float:
    if is_stream_static: return stream.bpm
    else: return 0

func _get_length() -> float:
    if is_stream_static: return stream._get_length()
    else: return 0
    
func _get_stream_name() -> String:
    return stream.resource_name
    
func _instantiate_playback() -> AudioStreamPlayback:
    return stream.instantiate_playback()
    
func _is_monophonic() -> bool:
    return stream.is_monophonic()
    
func get_length() -> float:
    if is_stream_static: return stream._get_length()
    else: return 0
    
func instantiate_playback() -> AudioStreamPlayback:
    return stream.instantiate_playback()

func is_monophonic() -> bool:
    return stream.is_monophonic()
