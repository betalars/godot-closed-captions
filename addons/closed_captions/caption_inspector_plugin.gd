@tool
class_name CaptionInspectorPlugin
extends EditorInspectorPlugin
#var CaptionEditor = preload("res://addons/closed_captions/caption_inspector_editor.gd")

func _can_handle(object):
	if object is CaptionedAudioStreamPlayer or object is CaptionedAudioStreamPlayer3D or object is CaptionedAudioStreamPlayer2D:
		PluginReference.plugin.display_caption_panel_for(object)
	else:
		if object is Node:
			if not object.name.contains("Editor"):
				PluginReference.plugin.hide_caption_panel()
	return false
