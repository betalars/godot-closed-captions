@tool
extends Control
class_name CaptionsPanel

@export var multi_caption_stream: MultiCaptionAudioStream:
	set(stream):
		if stream != null:
			if multi_caption_stream != null:
				multi_caption_stream.current_caption_set.disconnect(display_caption)
			multi_caption_stream = stream
			multi_caption_stream.current_caption_set.connect(display_caption)
			multi_caption_stream.caption_changed.connect(display_caption)
			current_caption = multi_caption_stream.caption
			if is_node_ready():
				label.caption = current_caption

@export var force_update:bool = false:
	set(nix):
		update_timeline()

@onready var label: CaptionLabel = $Layout/CaptionLabel
@onready var time_scale: float = $TimeScale.value
@onready var timeline: VBoxContainer = $Layout/Timeline
@onready var waveform: TextureRect = $Layout/Timeline/Waveform
@onready var caption_input: TextEdit = $Layout/HBoxContainer3/CaptionInput
@onready var position_group: ButtonGroup = $Layout/HBoxContainer3/Speaker_properties/Position/center.button_group
@onready var color_group: ButtonGroup = $Layout/HBoxContainer3/Speaker_properties/Color/white.button_group
@onready var name_input: TextEdit = $Layout/HBoxContainer3/Speaker_properties/HSplitContainer/NameInput
@onready var name_picker: OptionButton = $Layout/HBoxContainer3/Speaker_properties/HSplitContainer/NamePicker
@onready var extra_input: TextEdit = $Layout/HBoxContainer3/Speaker_properties/extra_input

@onready var nav_last: Button = $Layout/Navigation/Last
@onready var nav_delete: Button = $Layout/Navigation/DeleteCurrent
@onready var nav_play: Button = $Layout/Navigation/Play
@onready var nav_add: Button = $Layout/Navigation/Add
@onready var nav_next: Button = $Layout/Navigation/Next

@onready var time_scale:float = 0:
	set(value):
		time_scale_selector.value = time_scale
	get():
		return time_scale_selector.value

var current_time: float = 0:
	set(value):
		current_time = value
		if is_node_ready():
			time_selector.value = current_time
	get():
		if is_node_ready():
			return time_selector.value
		else:
			return 0

@onready var audio_player: Object:
	set(player):
		assert(player is CaptionedAudioStreamPlayer or player is CaptionedAudioStreamPlayer2D or player is AudioStreamPlayer)
		audio_player = player
		multi_caption_stream = audio_player.captioned_stream

var current_caption:Caption

var speaker_colors: Array[int] = []
var current_speaker_id = -1
var lock_signals

func _ready():
	##FIXME for some reason, this is not allowed
	#time_scale_selector.value_changed.connect(timeline.select_time_scale)
	time_selector.value_changed.connect(multi_caption_stream.seek_closest)
	time_scale_selector.editable = false
	
	name_input.text_set.connect(confirm_speaker_name)
	name_input.text_changed.connect(update_speaker_name)
	
	extra_input.text_changed.connect(update_extra_formatting)
	
	position_group.pressed.connect(update_speaker_position)
	color_group.pressed.connect(update_speaker_color)
	
	nav_delete.pressed.connect(delete_current)
	nav_add.pressed.connect(add_new)
	
	display_caption(current_caption)
	
	timeline.multi_caption_stream = multi_caption_stream

func set_time_scale(value:float):
	time_scale = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_timeline():
	EditorInterface.get_resource_previewer().queue_edited_resource_preview(audio_player.audio_stream, self, "update_waveform", null)

func update_waveform(texture:Texture2D):
	print("got_called")
	waveform.texture = texture

func update_speaker_name():
	if not lock_signals:
		current_caption.speaker_name = name_input.text

func update_extra_formatting():
	if not lock_signals:
		current_caption.extra_formatting = extra_input.text

func confirm_speaker_name():
	if current_speaker_id == -1:
		current_speaker_id = speaker_colors.size()
		speaker_colors.append(current_caption.speaker_color)
		name_picker.add_item(current_caption.speaker_name)
	else:
		speaker_colors[current_speaker_id] = current_caption.speaker_color
		name_picker.set_item_text(current_speaker_id, current_caption.speaker_name)

func update_speaker_color(color_pick: Button):
	if not lock_signals:
		match color_pick.name:
			"auto":
				current_caption.speaker_color = Caption.Colors.AUTOMATIC
			"white":
				current_caption.speaker_color = Caption.Colors.WHITE
			"yellow":
				current_caption.speaker_color = Caption.Colors.YELLOW
			"cyan":
				current_caption.speaker_color = Caption.Colors.CYAN
			"green":
				current_caption.speaker_color = Caption.Colors.GREEN
			"purple":
				current_caption.speaker_color = Caption.Colors.PURPLE
			"violet":
				current_caption.speaker_color = Caption.Colors.VIOLET
			"salmon":
				current_caption.speaker_color = Caption.Colors.SALMON
			"blue":
				current_caption.speaker_color = Caption.Colors.BLUE
		
func update_speaker_position(position_input: Button):
	if not lock_signals:
		current_caption.position = position_input.get_parent().get_children().find(position_input)

func update_caption_text():
	if not lock_signals:
		current_caption.text = caption_input.text

func display_caption(caption: Caption = Caption.new()):
	if caption == null: caption = Caption.new()
	lock_signals = true
	
	var color_button_name
	match caption.speaker_color:
		Caption.Colors.AUTOMATIC:
			color_button_name = "auto"
		Caption.Colors.WHITE:
			color_button_name = "white"
		Caption.Colors.YELLOW:
			color_button_name = "yellow"
		Caption.Colors.CYAN:
			color_button_name = "cyan"
		Caption.Colors.GREEN:
			color_button_name = "green"
		Caption.Colors.PURPLE:
			color_button_name = "purple"
		Caption.Colors.VIOLET:
			color_button_name = "violet"
		Caption.Colors.SALMON:
			color_button_name = "salmon"
		Caption.Colors.BLUE:
			color_button_name = "blue"
	for button:Button in color_group.get_buttons():
		if button.name == color_button_name:
			button.button_pressed = true
			break
	
	current_speaker_id = -1
	
	if not caption.speaker_name == "":
		for i in range(speaker_colors.size()):
			if caption.speaker_name == name_picker.get_item_text(i):
				current_speaker_id = i
				break
		
		if current_speaker_id == -1: confirm_speaker_name()
		
		name_picker.select(current_speaker_id)
	else:
		name_input.text = ""
	
	(position_group.get_pressed_button().get_parent().get_child(caption.position) as Button).button_pressed = true
	
	name_input.text = caption.speaker_name
	caption_input.text = caption.text
	extra_input.text = caption.extra_formatting
	
	lock_signals = false

func delete_current():
	multi_caption_stream.erase_caption(current_caption)
	
func add_new():
	multi_caption_stream.append_caption(Caption.new())
