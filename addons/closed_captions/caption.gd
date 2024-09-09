@tool
extends Resource
class_name Caption

enum Positions {
	OFF_SCREEN_LEFT,
	LEFT,
	CENTER,
	RIGHT,
	OFF_SCREEN_RIGHT,
	BEHIND
}

enum Colors {
	## Color picked by speaker appearance. This setting will result in unreliable speaker colors and is not reccomended.
	AUTOMATIC,
	## Frist speaker.
	WHITE,
	## Second speaker.
	YELLOW,
	## Third speaker.
	CYAN,
	## Fourth speaker.
	GREEN,
	## Extra Colors:
	PURPLE,
	VIOLET,
	SALMON,
	BLUE,
}

enum ConfigurationWarnings {
	EMPTY,
	TOO_LONG,
	MISSING_SPEAKER,
	SET_POSITION
}

enum Formatting{
	## For Characters on screen or within the same scene
	NEUTRAL,
	## Use this for outside-the-scene characters on the telephhone for instance.
	OUT_OF_VISION,
	## Use this for robotic voices, artificial voices (including TV or Radio hosts) or quotes.
	QUOTE_OR_ROBOT,
}

## The Text of the Caption.
@export_multiline var text:String = "":
	set(new_text):
		if new_text == null:
			text = ""
		else:
			text = new_text
		changed.emit()
## Position of the Sound source relative to the Screen. Leave on center with 3D or 2D Player.
@export var position:Positions = Positions.CENTER:
	set(new_position):
		position = new_position
		changed.emit()
@export_group("Speaker")
## Name of the Speaker. Leave empty for Sound Effects. Will be displayed when the speaker speaks first.
@export_placeholder("Blank for SFX") var speaker_name:String = "":
	set(name):
		if name.begins_with("$"):
			if special_speaker != null and special_speaker.name != name:
				special_speaker = PluginReference.global_cast.get_speaker_by_name(name)
		else:
			special_speaker = null
		if speaker_name == "" or name == "":
			speaker_name = name
			property_list_changed.emit()
		else:
			speaker_name = name
		changed.emit()
## This shows a special speaker if referenced. Use "$Godette" Format for Speaker Name to reference a speaker. Requires Cast Override or Global Cast to be configured.
@export var special_speaker: Speaker:
	set(speaker):
		if speaker == null and speaker_name != "":
			special_speaker == PluginReference.global_cast.get_speaker_by_name(speaker_name)
		special_speaker = speaker
		changed.emit()
## The Speaker Color. Speakers should have consistent colors.
@export var speaker_color:Colors = Colors.AUTOMATIC:
	set(new_color):
		speaker_color = new_color
		changed.emit()
## Choose extra formatting.
@export var speaker_format:Formatting = Formatting.NEUTRAL:
	set(frmt):
		speaker_format = frmt
		changed.emit()
## Use this for extra description, such as "over the radio"
@export var extra_formatting: String = "":
	set(extra):
		extra_formatting = extra
		changed.emit()
@export var force_name_display: bool = false:
	set(force):
		force_name_display = force
		changed.emit()
@export_group("Timing")
## Delay between sound starting and caption popping up.
@export var delay:float = 0:
	set(del):
		delay = del
## Duration of the Caption. Choose 0 for continuous. Captions longer than 10 seconds are not reccomended.
@export_range(0,10) var duration:float:
	set(new_duration):
		if new_duration >= 0:
			duration = new_duration
		else:
			push_warning("Cannot set duration of Caption to negative value. Use 0 for automatic duration.")
		_duration = duration
		
		changed.emit()

func _validate_property(property: Dictionary) -> void:
	if ["speaker_color", "speaker_format", "force_name_display"].has(property.name) and speaker_name == "":
		property.usage |= PROPERTY_USAGE_READ_ONLY

func _init(initial_time_offset = 0) -> void:
	delay = initial_time_offset

var previous: Caption

## Hidden duration field for storing automatically generated durations (they do not effect the manually configured duration)
var _duration:float = duration

## Checks if caption is empty or too long.
func get_warnings() -> int:
	var is_empty:int = int(text != "")
	var is_long:int = int(text.split(" ").size() < 15) << ConfigurationWarnings.TOO_LONG
	var is_missing: int = int(speaker_name == "" and (speaker_color != Colors.AUTOMATIC or speaker_format != Formatting.NEUTRAL or extra_formatting != "")) << ConfigurationWarnings.MISSING_SPEAKER
	var is_positioned: int = int(position != Positions.CENTER) << ConfigurationWarnings.SET_POSITION
	
	return is_empty & is_long  & is_missing & is_positioned

func _to_string() -> String:
	if speaker_name == "":
		return ("<Caption [%s]>" % [text])
	else:
		return ("<Caption [%s]: %s>" % [speaker_name, text])
