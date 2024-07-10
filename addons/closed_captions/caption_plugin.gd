@tool
extends EditorPlugin
class_name  CaptionPlugin

# Cosmetic: declaring values of property names as variables to improve readability
var _allow_sound_stacking:String = "accessibility/closed_captions/allow_sound_stacking"
var _use_custom_font:String = "accessibility/closed_captions/use_custom_font"
var _text_scaling:String = "accessibility/closed_captions/text_scaling"
var _background_color:String = "accessibility/closed_captions/background_colour"
var _audibility_threshhold: String = "accessibility/closed_captions/sensitivity_threashold"
var _display_continuous_sounds: String = "accessibility/closed_captions/display_continous_sounds"
var _update_sound_directions: String = "accessibility/closed_captions/update_sound_directions"

func _enable_plugin():
	_initialise_project_settings()
	
func _enter_tree():
	_initialise_project_settings()
	add_autoload_singleton("CaptionServer", "res://addons/closed_captions/caption_server.gd")
	add_autoload_singleton("CaptionTheme", "res://addons/closed_captions/theme.gd")
	add_custom_type("Caption", "Resource", preload("res://addons/closed_captions/caption.gd"), preload("icons/Caption.svg"))
	add_custom_type("CaptionedAudioStream", "Resource", preload("res://addons/closed_captions/captioned_audio_stream.gd"), preload("icons/CaptionedAudioStream.svg"))
	add_custom_type("MultiCaptionAudioStream", "CaptionedAudioStream", preload("res://addons/closed_captions/multi_caption_audio_stream.gd"), preload("icons/MultiCaptionAudioStream.svg"))
	add_custom_type("CaptionedAudioStreamPlayer", "AudioStreamPlayer", preload("res://addons/closed_captions/captioned_autio_stream_player.gd"), preload("icons/CaptionedAudioStreamPlayer.svg"))
	add_custom_type("CaptionLabel", "RichTextLabel", preload("res://addons/closed_captions/caption_label.gd"), preload("icons/CaptionLabel.svg"))
	add_custom_type("CaptionDisplay", "VBoxContainer", preload("res://addons/closed_captions/caption_display.gd"), preload("icons/CaptionDisplay.svg"))

func _exit_tree():
	remove_custom_type("CaptionedAudioStreamPlayer")
	remove_autoload_singleton("CaptionTheme")
	remove_autoload_singleton("CaptionServer")

func _disable_plugin():
	ProjectSettings.set_setting(_allow_sound_stacking, null)
	ProjectSettings.set_setting(_use_custom_font, null)
	ProjectSettings.set_setting(_text_scaling, null)
	ProjectSettings.set_setting(_background_color, null)
	ProjectSettings.set_setting(_audibility_threshhold, null)
	ProjectSettings.set_setting(_display_continuous_sounds, null)
	ProjectSettings.set_setting(_update_sound_directions, null)
	
	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)

func _initialise_project_settings():
	if !ProjectSettings.has_setting(_allow_sound_stacking):
		ProjectSettings.set_setting(_allow_sound_stacking, true)
		ProjectSettings.add_property_info({
			"name": _allow_sound_stacking,
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			# At the moment, this will not be rendered by godot editor, see https://github.com/godotengine/godot-proposals/discussions/8224
			"doc": "Disable to make sure only one sound is captioned at a time."
		})
		ProjectSettings.set_initial_value(_allow_sound_stacking, false)
	
	if !ProjectSettings.has_setting(_use_custom_font):
		ProjectSettings.set_setting(_use_custom_font, "")
		ProjectSettings.add_property_info({
			"name": _use_custom_font,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"doc": "Set the name of a custom font. Needs to be installed on user device. Alternatively, you can set the font directly by modifying captions.theme."
		})
		ProjectSettings.set_initial_value(_allow_sound_stacking, false)
	
	if !ProjectSettings.has_setting(_text_scaling):
		ProjectSettings.set_setting(_text_scaling, 1)
		ProjectSettings.add_property_info({
			"name": _text_scaling,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.5,5,0.1",
			"doc": "Define custom scaling."
		})
		ProjectSettings.set_initial_value(_text_scaling, 1)
	
	if !ProjectSettings.has_setting(_background_color):
		ProjectSettings.set_setting(_background_color, Color.BLACK)
		ProjectSettings.add_property_info({
			"name": _background_color,
			"type": TYPE_COLOR,
			"hint": PROPERTY_HINT_NONE,
		"description": "Sets the Background color of Caption Boxes. Will ignore non-WGCA complient settings."
		})
		ProjectSettings.set_initial_value(_background_color, Color.BLACK)
	
	if !ProjectSettings.has_setting(_audibility_threshhold):	
		ProjectSettings.set_setting(_audibility_threshhold, true)
		ProjectSettings.add_property_info({
			"name": _audibility_threshhold,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.1,5,0.1",
			"doc": "Define custom scaling."
		})
		ProjectSettings.set_initial_value(_audibility_threshhold, 1)
	
	if !ProjectSettings.has_setting(_display_continuous_sounds):
		ProjectSettings.set_setting(_display_continuous_sounds, 1)
		ProjectSettings.add_property_info({
			"name": _display_continuous_sounds,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "once, when_becoming_audible, always"
		})
		ProjectSettings.set_initial_value(_display_continuous_sounds, 1)
	
	if !ProjectSettings.has_setting(_update_sound_directions):
		ProjectSettings.set_setting(_update_sound_directions, 1)
		ProjectSettings.add_property_info({
			"name": _update_sound_directions,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "never, at_intervals, always"
		})
		ProjectSettings.set_initial_value(_update_sound_directions, 1)
		
	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)
	
