extends Node
# I would really like to move this code into the main plugin script, but for some reason that does not work.

var _text_scaling:String = "accessibility/closed_captions/text_scaling"
var _background_color:String = "accessibility/closed_captions/background_colour"

var captions_theme:Theme = preload("res://addons/closed_captions/captions.theme")

func _ready():
	ProjectSettings.settings_changed.connect(_on_project_settings_update)

func _on_project_settings_update():
	captions_theme.default_base_scale = ProjectSettings.get_setting(_text_scaling)
	## TODO: Add Color and Font Handling.
