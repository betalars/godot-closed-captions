@tool
extends Resource
class_name Caption

enum Positions {
	BEHIND,
	OFF_SCREN_LEFT,
	LEFT,
	CENTER,
	RIGHT,
	OFF_SCREEN_RIGHT
}

enum Colors {
	## Color is picke based on speaker occurance.
	AUTOMATIC,
	## Frist speaker.
	WHITE,
	## Second speaker.
	YELLOW,
	## Third speaker.
	CYAN,
	## Fourth speaker.
	GREEN
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
		if new_text == null: text = ""
		else: text = new_text
		changed.emit()
## Position of the Sound source relative to the Screen. Leave on center with 3D or 2D Player.
@export var position:Positions = Positions.CENTER:
	set(new_position):
		position = new_position
		changed.emit()
@export_group("Speaker (leave empty for Sounds)")
## Name of the Speaker. Leave empty for Sound Effects. Will be displayed when the speaker speaks first.
@export var speaker_name:String = "":
	set(name):
		speaker_name = name
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

## Hidden duration field for storing automatically generated durations (they do not effect the manually configured duration)
var _duration:float = duration

## Checks if caption is empty or too long.
func get_warnings() -> int:
	var is_empty:int = int(text != "")
	var is_long:int = int(text.split(" ").size() < 15) << ConfigurationWarnings.TOO_LONG
	var is_missing: int = int(speaker_name == "" and (speaker_color != Colors.AUTOMATIC or speaker_format != Formatting.NEUTRAL or extra_formatting != "")) << ConfigurationWarnings.MISSING_SPEAKER
	var is_positioned: int = int(position != Positions.CENTER) << ConfigurationWarnings.SET_POSITION
	
	return is_empty & is_long  & is_missing & is_positioned
