## Caption for internal use in caption server.
extends Resource
class_name CaptionLabel

enum Positions {
	TOP,
	LEFT,
	TOP_LEFT,
	BOTTOM_LEFT,
	CENTER,
	RIGHT,
	TOP_RIGHT,
	BOTTOM_RIGHT,
	BOTTOM,
	BEHIND
}

var left_pos_string:PackedStringArray = [
	"^",
	"<",
	"^",
	"v",
	" ",
	" ",
	" ",
	" ",
	"v",
	"<"
]

var right_pos_string:PackedStringArray = [
	"^",
	" ",
	" ",
	" ",
	" ",
	">",
	"^",
	"v",
	"v",
	">"
]

var color_strings:PackedStringArray = [
	"white",
	"white",
	"yellow",
	"cyan",
	"green",
]

var _text:String = ""
var _speaker_color:Caption.Colors = Caption.Colors.AUTOMATIC
var _position:Positions = Positions.CENTER
var _is_off_screen:bool = false
var _extra_formatting: String = ""

func _init(caption: Caption):
	if caption.speaker_name == "":
		_text = "[%s]" % caption.text
	else: 
		match caption.speaker_format:
			caption.Formatting.NEUTRAL:
				_text = caption.text
			caption.Formatting.OUT_OF_VISION:
				_text = "'%s'" % caption.text
			caption.Formatting.QUOTE_OR_ROBOT:
				_text = "\"%s\"" % caption.text
	_speaker_color = caption.speaker_color
	_extra_formatting = caption.extra_formatting

func get_compact_formatted_string(prefix:String = "", color: Caption.Colors = _speaker_color, position: Positions = _position, off_screen: bool = _is_off_screen) -> String:
	var left:String = left_pos_string[position]
	var right:String = right_pos_string[position]
	
	if off_screen or position == Positions.BEHIND:
		left += left
		right += right
	return ("%s [color=%s][%s %s]: %s [/color]%s" % [left, color_strings[color], prefix, _extra_formatting, _text, right]).replace("[ ]: ", "").replace("[ ", "[").replace(" ]", "]")

func get_wide_formatted_string_arr(prefix:String = "", color: Caption.Colors = _speaker_color, position: Positions = _position, off_screen: bool = _is_off_screen) -> PackedStringArray:
	var left_indicator:String = left_pos_string[position]
	var right_indicator:String = right_pos_string[position]
	var alignment:String
	
	if position in [Positions.LEFT, Positions.TOP_LEFT, Positions.BOTTOM_LEFT]:
		alignment = "left"
	elif position in [Positions.RIGHT, Positions.TOP_RIGHT, Positions.BOTTOM_RIGHT]:
		alignment = "right"
	else:
		alignment = "center"
	
	if position == Positions.LEFT or position == Positions.RIGHT and not off_screen:
		left_indicator = " "
		right_indicator = " "
	
	if position == Positions.BEHIND:
		left_indicator += left_indicator
		right_indicator += right_indicator
	return [left_indicator, ("[%s] [color=%s] [%s %s]: %s [/color] [/%s]" % [alignment, color_strings[color], prefix, _extra_formatting, _text, alignment]).replace("[ ]: ", "").replace("[ ", "[").replace(" ]", "]"), right_indicator]
