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
	BEHIND,
	UNSET
}

var left_pos_string:PackedStringArray = [
	"^", # Top
	"<", # Left
	"^", # Top Left
	"v", # Bottom Left
	" ", # Center
	" ", # Right
	" ", # Top Right
	" ", # Bottom Right
	"v", # Bottom
	"<"  # Behind
]

var right_pos_string:PackedStringArray = [
	"^", # Top
	" ", # Left
	" ", # Top Left
	" ", # Bottom Left
	" ", # Center
	">", # Right
	"^", # Top Right
	"v", # Bottom Right
	"v", # Bottom
	">"  # Behind
]

var color_strings:PackedStringArray = [
	"white",
	"white",
	"yellow",
	"cyan",
	"green",
]

var _caption_text:String = ""
var _speaker_color:Caption.Colors = Caption.Colors.AUTOMATIC
var _caption_position:Positions = Positions.CENTER
var override_position:Positions = Positions.UNSET
var _is_off_screen:bool = false
var extra_formatting: String = ""
var prefix: String = ""

func _init(from_caption: Caption = Caption.new(), include_name: bool = false, compact:bool = is_compact, override_position:Positions = Positions.UNSET):
	self.caption = from_caption
	self.include_name = include_name
	self.override_position = override_position

func _ready():
	rebuild()

func rebuild():
	if caption.speaker_name == "":
		_caption_text = "[%s]" % caption.text
	else: 
		match caption.speaker_format:
			caption.Formatting.NEUTRAL:
				_caption_text = caption.text
			caption.Formatting.OUT_OF_VISION:
				_caption_text = "'%s'" % caption.text
			caption.Formatting.QUOTE_OR_ROBOT:
				_caption_text = "\"%s\"" % caption.text
	_speaker_color = caption.speaker_color
	extra_formatting = caption.extra_formatting
	# as this technically casts to a different type and requires some logic, it cannot be doen with a set method.
	set_pos(caption.position)
	bbcode_enabled = true
	fit_content = true
	if include_name: prefix = caption.speaker_name
	
	if is_compact:
		_set_compact_text()
	else:
		_set_wide_text()

func set_pos(pos = Caption.Positions):
	if override_position != null:
		_caption_position = override_position
	match pos:
		Caption.Positions.BEHIND:
			_caption_position = Positions.BEHIND
			_is_off_screen = false
		Caption.Positions.OFF_SCREN_LEFT:
			_caption_position = Positions.LEFT
			_is_off_screen = true
		Caption.Positions.LEFT:
			_caption_position = Positions.LEFT
			_is_off_screen = false
		Caption.Positions.CENTER:
			_caption_position = Positions.CENTER
			_is_off_screen = false
		Caption.Positions.RIGHT:
			_caption_position = Positions.RIGHT
			_is_off_screen = false
		Caption.Positions.OFF_SCREEN_RIGHT:
			_caption_position = Positions.RIGHT
			_is_off_screen = true

func _set_compact_text():
	
	var left:String = left_pos_string[_caption_position]
	var right:String = right_pos_string[_caption_position]
	
	if _is_off_screen or _caption_position == Positions.BEHIND:
		left += left
		right += right
	text = ("[center] %s [color=%s][%s %s]: %s [/color]%s [center]" % [left, color_strings[_speaker_color], prefix, extra_formatting, _caption_text, right]).replace("[ ]: ", "").replace("[ ", "[").replace(" ]", "]")

func _set_wide_text():
	var left:String = left_pos_string[_caption_position]
	var right:String = right_pos_string[_caption_position]
	var alignment:String
	
	if _caption_position in [Positions.LEFT, Positions.TOP_LEFT, Positions.BOTTOM_LEFT]:
		alignment = "left"
	elif _caption_position in [Positions.RIGHT, Positions.TOP_RIGHT, Positions.BOTTOM_RIGHT]:
		alignment = "right"
	else:
		alignment = "center"
	
	if (_caption_position == Positions.LEFT or _caption_position == Positions.RIGHT) and not _is_off_screen:
		left = " "
		right = " "
	
	if _caption_position == Positions.BEHIND:
		left += left
		right += right
	text = ("[%s] %s [color=%s] [%s %s]: %s [/color] %s [/%s]" % [alignment, left, color_strings[_speaker_color], prefix, extra_formatting, _caption_text, right, alignment]).replace("[ ]: ", "").replace("[ ", "[").replace(" ]", "]")
