extends Node

var sources: Array[Array] = [[],[]]
var captions: Array[ServerCaption]

func push_caption(source: CaptionedAudioStreamPlayer, caption: Caption):
	if not AudioServer.is_bus_mute(AudioServer.get_bus_index(source.bus)):
		if is_listening(source.get_viewport()):
			var server_caption:ServerCaption = ServerCaption.new(caption)
			captions.append(server_caption)
			await get_tree().create_timer(caption._duration-0.05).timeout
			captions.erase(server_caption)

func is_listening(listener: Viewport):
	if not (listener.audio_listener_enable_2d or listener.audio_listener_enable_3d):
		return false
	else:
		if listener == get_viewport():
			return true
		else:
			return is_listening(listener.get_viewport())
