@tool
class_name CaptionInspectorPlugin
extends EditorInspectorPlugin
#var CaptionEditor = preload("res://addons/closed_captions/caption_inspector_editor.gd")

var just_called:bool = false

func _can_handle(object):
	if object is CaptionedAudioStreamPlayer or object is CaptionedAudioStreamPlayer3D or object is CaptionedAudioStreamPlayer2D:
		PluginReference.plugin.display_caption_panel_for(object)
		just_called = true
	else:
		if just_called:
			just_called = false
		else:
			PluginReference.plugin.hide_caption_panel()
	return false
