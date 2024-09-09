@tool
extends Node

var plugin:EditorPlugin
var global_cast:Cast = Cast.new()

func _ready() -> void:
	loead_cast()

func save_cast():
	if global_cast.changed_since_last_save:
		var file = FileAccess.open(ProjectSettings.get_setting(CaptionPlugin.global_cast_save_path), FileAccess.WRITE)
		file.store_var(global_cast.speakers)

func loead_cast():
	
	var file:= FileAccess.open(ProjectSettings.get_setting(CaptionPlugin.global_cast_save_path), FileAccess.READ)
	
	if not file == null:
		var readout = file.get_var(true)
		
		if readout is Array[Speaker]:
			global_cast.load_speakers(file.get_var(true))
		else:
			push_error("File found at `%s` could not be loaded as `Array[Speaker]`" % CaptionPlugin.global_cast_save_path)
