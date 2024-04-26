## Caption for internal use in caption server.
extends RichTextLabel
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

@export var caption: Caption
@export var is_compact: bool = false
@export var include_name: bool = false
var caption_text:String = ""
var speaker_color:Caption.Colors = Caption.Colors.AUTOMATIC
var caption_position:Positions = Positions.CENTER
var is_off_screen:bool = false
var extra_formatting: String = ""
var prefix: String = ""

func _init(from_caption: Caption, include_name: bool = false, compact:bool = is_compact):
	self.caption = from_caption
	self.include_name = include_name

func _ready():
	rebuild()

func rebuild():
	if caption.speaker_name == "":
		caption_text = "[%s]" % caption.text
	else: 
		match caption.speaker_format:
			caption.Formatting.NEUTRAL:
				caption_text = caption.text
			caption.Formatting.OUT_OF_VISION:
				caption_text = "'%s'" % caption.text
			caption.Formatting.QUOTE_OR_ROBOT:
				caption_text = "\"%s\"" % caption.text
	speaker_color = caption.speaker_color
	extra_formatting = caption.extra_formatting
	bbcode_enabled = true
	fit_content = true
	if include_name: prefix = caption.speaker_name
	
	if is_compact:
		_set_compact_text()
	else:
		_set_wide_text()

func _set_compact_text():
	var left:String = left_pos_string[caption_position]
	var right:String = right_pos_string[caption_position]
	
	if is_off_screen or caption_position == Positions.BEHIND:
		left += left
		right += right
	text = ("%s [color=%s][%s %s]: %s [/color]%s" % [left, color_strings[speaker_color], prefix, extra_formatting, caption_text, right]).replace("[ ]: ", "").replace("[ ", "[").replace(" ]", "]")

func _set_wide_text() -> PackedStringArray:
	var left_indicator:String = left_pos_string[caption_position]
	var right_indicator:String = right_pos_string[caption_position]
	var alignment:String
	
	if position in [Positions.LEFT, Positions.TOP_LEFT, Positions.BOTTOM_LEFT]:
		alignment = "left"
	elif position in [Positions.RIGHT, Positions.TOP_RIGHT, Positions.BOTTOM_RIGHT]:
		alignment = "right"
	else:
		alignment = "center"
	
	if caption_position == Positions.LEFT or caption_position == Positions.RIGHT and not is_off_screen:
		left_indicator = " "
		right_indicator = " "
	
	if caption_position == Positions.BEHIND:
		left_indicator += left_indicator
		right_indicator += right_indicator
	return [left_indicator, ("[%s] [color=%s] [%s %s]: %s [/color] [/%s]" % [alignment, color_strings[speaker_color], prefix, extra_formatting, caption_text, alignment]).replace("[ ]: ", "").replace("[ ", "[").replace(" ]", "]"), right_indicator]
