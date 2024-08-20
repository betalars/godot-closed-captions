@tool
extends Node
class_name Relay

var plugin:EditorPlugin

func _init(plug):
	plugin = plug
	PluginReference.plugin = plugin

func settings_initialised():
	CaptionTheme.setting_initialized = true
