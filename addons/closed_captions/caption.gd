@tool
extends Resource
class_name Caption

enum Positions {
    BEHIND,
    OFF_SCEEN,
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

enum Formatting{
    VOICE,
    OUT_OF_VISION,
    QUOTE_OR_ROBOT,
}

## The Text of the Caption.
@export_multiline var text:String = "":
    set(new_text):
        if new_text == null: text = ""
        else: text = new_text
@export_group("Speaker (leave empty for Sounds)")
## Name of the Speaker. Leave empty for Sound Effects. Will be displayed when the speaker speaks first.
@export var speaker_name:String = "":
    set(name):
        speaker_name = name
## The Speaker Color. Speakers should have consistent colors.
@export var speaker_color:Colors = Colors.AUTOMATIC:
    set(new_color):
        speaker_color = new_color
## Position of the Speaker relative to the Screen.
@export var position:Positions = Positions.CENTER:
    set(new_position):
        position = new_position
## Choose extra formatting.
@export var format:Formatting = Formatting.VOICE:
    set(frmt):
        format = frmt
## Use this for extra description, such as "over the radio"
@export var extra_formatting: String = "":
    set(extra):
        extra_formatting = extra
@export_group("Timing")
## Delay between sound starting and caption popping up.
@export var delay:float = 0:
    set(del):
        delay = del
## Duration of the Caption. Choose 0 for continuous. Captions longer than 10 seconds are not reccomended.
@export_range(0,10) var duration:float:
    set(new_duration):
        duration = new_duration


func is_valid():
    return ( text != "" and text.split(" ").size() < 15 )

func has_neutral_positioning() -> bool:
    return position == Positions.CENTER
