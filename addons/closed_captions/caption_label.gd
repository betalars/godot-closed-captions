@tool
## Tool for generating a 
extends RichTextLabel
class_name CaptionLabel

## Defining extra positions mostly dedicated for captioning sound sources specific to games.
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
	## used, because override_position can't be null.
	UNSET
}

## Array of strings to use as indicators for each possible position.
var _left_pos_string:PackedStringArray = [
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

## Array of strings to use as indicators for each possible position.
var _right_pos_string:PackedStringArray = [
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

## Array of Strings to get the correct Color using bbcode.
var color_strings:PackedStringArray = [
	"white",
	"white",
	"yellow",
	"cyan",
	"green",
	"mediumpurple",
	"violet",
	"salmon",
	"dodgerblue"
]

## The caption being displayed by this label.
@export var caption: Caption:
	set(new_caption):
		if caption != null:
			caption.changed.disconnect(rebuild)
		caption = new_caption
		if caption != null:
			caption.changed.connect(rebuild)
			rebuild()
## Use this to decide if a label is supposed to span the whole screen or be tucked to a small box.
@export var is_compact: bool = false:
	set(compact):
		is_compact = compact
		rebuild()
## This is being set to true, if a caption of the same speaker is showing up repeatedly without conflicting colors.
@export var include_name: bool = true:
	set(include):
		include_name = include
		rebuild()
var _caption_text:String = ""
var _speaker_color:Caption.Colors = Caption.Colors.AUTOMATIC
var _caption_position:Positions = Positions.CENTER
var override_position:Positions = Positions.UNSET
var _is_off_screen:bool = false
var _extra_formatting: String = ""
var _prefix: String = ""

func _init(from_caption: Caption = Caption.new(), include_name: bool = false, compact:bool = is_compact, override_position:Positions = Positions.UNSET):
	self.caption = from_caption
	self.include_name = include_name
	self.override_position = override_position
	self.name = "CaptionLebel"
	self.theme = CaptionTheme.captions_theme
	self.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func _ready():
	rebuild()

func rebuild():
	if caption == null:
		text = "[ ... ]"
		return
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
	_extra_formatting = caption.extra_formatting
	# as this technically casts to a different type and requires some logic, it cannot be doen with a set method.
	set_pos(caption.position)
	bbcode_enabled = true
	fit_content = true
	
	if include_name or (caption.force_name_display and not caption.speaker_name == ""): _prefix = caption.speaker_name
	
	if is_compact:
		_set_compact_text()
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	else:
		_set_wide_text()
		
		match caption.position:
			caption.Positions.OFF_SCREEN_LEFT, caption.Positions.LEFT:
				size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			caption.Positions.OFF_SCREEN_RIGHT, caption.Positions.RIGHT:
				size_flags_horizontal = Control.SIZE_SHRINK_END
			_:
				size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	custom_minimum_size.x = min(CaptionTheme.maximum_label_width, get_theme_default_font().get_multiline_string_size(text).x+10)

## Converting the Position based off the enum declared in caption to the bigger Position standard declared in this class. Will use position in override_position instead, if it was set.
func set_pos(pos = Caption.Positions):
	if override_position != null:
		_caption_position = override_position
	match pos:
		Caption.Positions.OFF_SCREEN_LEFT:
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
		Caption.Positions.BEHIND:
			_caption_position = Positions.BEHIND
			_is_off_screen = true

## Generating a bbcode string and putting it as the label text for the compact rendering option.
func _set_compact_text():
	var left:String = _left_pos_string[_caption_position]
	var right:String = _right_pos_string[_caption_position]
	
	if _is_off_screen or _caption_position == Positions.BEHIND:
		left += left
		right += right
	text = ("[center] %s [color=%s][%s %s]%s %s [/color]%s [/center]" % \
				[left, color_strings[_speaker_color], _prefix, _extra_formatting,\
				" \n" if (_prefix+_extra_formatting).length() > 12  or _caption_text.contains("\n") else ":",\
				 _caption_text, right])\
				.replace("[ ]: ", "").replace("[ ] \n ", "").replace("[ ", "[").replace(" ]", "]").replace("  ", " ")

## Generating a bbcode string and putting it as the label text for the wide rendering option.
func _set_wide_text():
	var left:String = _left_pos_string[_caption_position]
	var right:String = _right_pos_string[_caption_position]
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
	text = ("[%s] %s [color=%s][%s %s]%s %s [/color]%s [/%s]" % \
				[alignment, left, color_strings[_speaker_color], _prefix, _extra_formatting, \
				" \n" if (_prefix+_extra_formatting).length() > 12 or _caption_text.contains("\n") else ":", \
				_caption_text, right, alignment])\
				.replace("[ ]: ", "").replace("[ ] \n ", "").replace("[ ", "[").replace(" ]", "]").replace("  ", " ")
