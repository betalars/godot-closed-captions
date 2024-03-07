@tool
extends EditorPlugin

func _enter_tree():
    add_custom_type("SubtitledAudioStreamPlayer", "AudioStreamPlayer", preload("res://addons/subtitles/subtitled_autio_stream_player.gd"), preload("icon.svg"))

func _exit_tree():
    remove_custom_type("SubtitledAudioStreamPlayer")
