extends Node

var sources: Array[Array] = [[],[]]
var caption_displays: Array[CaptionDisplay]

func push_caption(source: CaptionedAudioStreamPlayer, caption: Caption):
	if not AudioServer.is_bus_mute(AudioServer.get_bus_index(source.bus)):
		if is_listening(source.get_viewport()):
			var outputs:Array[CaptionDisplay]
			for display in caption_displays:
				if display.is_receiving_bus(source.bus): outputs.append(display)
			outputs.sort_custom(func(a:CaptionDisplay, b:CaptionDisplay) -> bool: return a.priority > b.priority)
			outputs[0].display_caption(caption)

func pull_caption(caption: Caption): for display in caption_displays: display.pull_caption(caption)

func is_listening(listener: Viewport):
	if not (listener.audio_listener_enable_2d or listener.audio_listener_enable_3d):
		return false
	else:
		if listener == get_viewport():
			return true
		else:
			return is_listening(listener.get_viewport())

func signup_display(new: CaptionDisplay):
	if not caption_displays.has(new):
		caption_displays.append(new)
	
func signoff_display(old: CaptionDisplay):
	caption_displays.erase(old)
