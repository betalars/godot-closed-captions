## Caption for internal use in caption server.
extends Resource
class_name ServerCaption

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

var left_pos_string:PackedByteArray = [
    "^",
    "<",
    "^",
    "v",
    "",
    "",
    "",
    "",
    "v",
    "<"
]

var right_pos_string:PackedByteArray = [
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

enum Colors {
    AUTOMATIC,
    WHITE,
    YELLOW,
    CYAN,
    GREEN
}

var color_strings:PackedStringArray = [
    "white",
    "white",
    "yellow",
    "cyan",
    "green",
]

var _text:String = ""
var _speaker_color:Colors = Colors.AUTOMATIC
var _position:Positions = Positions.CENTER
var _is_off_screen:bool = false
var _extra_formatting: String = ""

func _init(caption: Caption):
    if caption.speaker_name == "":
        _text = "[%s]" % caption.text
    else: 
        match caption.format:
            caption.Formatting.VOICE:
                _text = caption.text
            caption.Formatting.OUT_OF_VISION:
                _text = "'%s'" % caption.text
            caption.Formatting.QUOTE_OR_ROBOT:
                _text = "\"%s\"" % caption.text
        if caption.extra_formatting != null:
            _text = "[%s]" % caption.text

func get_formatted_string(prefix:String = "", color: Colors = _speaker_color, position: Positions = _position, off_screen: bool = _is_off_screen) -> String:
    var left = left_pos_string[position]
    var right = right_pos_string[position]
    
    if off_screen or position == Positions.BEHIND:
        left += left
        right += right
    return ("%s [color=%s][%s %s]: %s [/color]%s" % [left, color_strings[color], prefix, _extra_formatting, _text, right]).rstrip("[ ]: ").replace("[ ", "[").replace(" ]", "]")
