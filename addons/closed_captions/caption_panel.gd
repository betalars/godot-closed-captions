@tool
extends MarginContainer
class_name CaptionsPanel

@export var multi_caption_stream: MultiCaptionAudioStream:
	set(stream):
		if stream != null:
			if multi_caption_stream != null:
				multi_caption_stream.captions_changed.disconnect(update_caption_list)
				multi_caption_stream.caption_set.disconnect(current_caption_changed)
			multi_caption_stream = stream
			multi_caption_stream.select_caption = 0
			if multi_caption_stream != null:
				multi_caption_stream.captions_changed.connect(update_caption_list)
				multi_caption_stream.caption_set.connect(current_caption_changed)
				current_caption = multi_caption_stream.caption
				speaker_colors = {}
				for caption in multi_caption_stream._captions_array:
					confirm_speaker_name(caption)
				if is_node_ready():
					#TODO: remove current caption from this entirely?
					label.caption = current_caption
					update_caption_list()

@export var force_update:bool = false:
	set(nix):
		update_timeline()

@onready var label: CaptionLabel = $Layout/CaptionLabel
@onready var time_selector: HSlider = $Layout/Timeline/TimeSelector
@onready var time_scale_selector: HSlider = $Layout/Navigation/TimeScale
@onready var timeline: CaptionPanelTimeline = $Layout/Timeline
@onready var waveform: TextureRect = $Layout/Timeline/Waveform
@onready var caption_input: TextEdit = $Layout/HBoxContainer3/CaptionInput
@onready var position_group: ButtonGroup = $Layout/HBoxContainer3/Speaker_properties/Position/center.button_group
@onready var color_group: ButtonGroup = $Layout/HBoxContainer3/Speaker_properties/Color/white.button_group
@onready var name_input: TextEdit = $Layout/HBoxContainer3/Speaker_properties/HSplitContainer/NameInput
@onready var name_picker: OptionButton = $Layout/HBoxContainer3/Speaker_properties/HSplitContainer/NamePicker
@onready var extra_input: TextEdit = $Layout/HBoxContainer3/Speaker_properties/extra_input
@onready var caption_list: VBoxContainer = $Layout/HBoxContainer3/Scroll/CaptionList

@onready var nav_last: TextureButton = $Layout/Navigation/Last
@onready var nav_delete: TextureButton = $Layout/Navigation/DeleteCurrent
@onready var nav_play: TextureButton = $Layout/Navigation/Play
@onready var nav_add: TextureButton = $Layout/Navigation/Add
@onready var nav_next: TextureButton = $Layout/Navigation/Next

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
		assert(player is CaptionedAudioStreamPlayer or player is CaptionedAudioStreamPlayer2D or player is AudioStreamPlayer or player == null)
		if not player == null:
			audio_player = player
			multi_caption_stream = audio_player.captioned_stream

var current_caption:Caption:
	set(caption):
		if current_caption != null:
			current_caption.changed.disconnect(update_caption_display)
		current_caption = caption
		if current_caption != null:
			current_caption.changed.connect(update_caption_display)
		#if not audio_player.playing:
			current_time = caption.delay
		update_caption_display()

var speaker_colors: Dictionary = {}
var current_speaker_id = -1
var lock_signals
	

func _ready():
	##FIXME for some reason, this is not allowed
	#time_scale_selector.value_changed.connect(timeline.select_time_scale)
	time_selector.value_changed.connect(multi_caption_stream.seek_closest)
	time_scale_selector.editable = false
	
	name_input.text_set.connect(confirm_speaker_name)
	name_input.text_changed.connect(update_speaker_name)
	name_picker.item_selected.connect(name_picked)
	
	extra_input.text_changed.connect(update_extra_formatting)
	
	position_group.pressed.connect(update_speaker_position)
	color_group.pressed.connect(update_speaker_color)
	
	# Connect navigation button signals
	nav_delete.pressed.connect(delete_current)
	nav_add.pressed.connect(add_new)
	nav_play.toggled.connect(toggle_play)
	nav_last.pressed.connect(last)
	nav_next.pressed.connect(next)
	
	update_caption_display()
	update_caption_list()
	
	timeline.multi_caption_stream = multi_caption_stream
	
	if audio_player == null:
		audio_player = CaptionedAudioStreamPlayer.new()
		
	#audio_player.new_caption_started.connect(current_caption_changed)
	audio_player.captioned_stream = multi_caption_stream

func _process(delta: float) -> void:
	return
	if audio_player.playing:
		current_time = audio_player.get_playback_position()

func update_timeline():
	EditorInterface.get_resource_previewer().queue_edited_resource_preview(audio_player.audio_stream, self, "update_waveform", null)

func update_waveform(texture:Texture2D):
	waveform.texture = texture

func update_speaker_name():
	if not lock_signals:
		current_caption.speaker_name = name_input.text

func update_extra_formatting():
	if not lock_signals:
		current_caption.extra_formatting = extra_input.text

func confirm_speaker_name(caption:Caption = current_caption):
	speaker_colors[caption.speaker_name] = caption.speaker_color
	update_name_picker()

func update_name_picker():
	if is_inside_tree():
		name_picker.clear()
		for speaker_name in speaker_colors.keys():
			name_picker.add_item(speaker_name)
		

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

func update_caption_list(_ignore = null):
	for child in caption_list.get_children():
		child.free()
		
	for caption in multi_caption_stream._captions_array: 
		var button:= CaptionPanelButton.new(caption)
		caption_list.add_child(button)
		button.pressed.connect(multi_caption_stream.set.bind("caption", caption))

func current_caption_changed(caption: Caption):
	print("updating current caption")
	current_caption = caption

func update_caption_display():
	if is_node_ready() and current_caption != null:
		lock_signals = true

		var color_button_name
		match current_caption.speaker_color:
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
			button.disabled = current_caption.speaker_name == ""
		
		
		
		if not current_caption.speaker_name == "":
			name_picker.select(speaker_colors.keys().find(current_caption.speaker_color))
		else:
			name_input.text = ""
			name_picker.select(-1)
		
		(position_group.get_pressed_button().get_parent().get_child(current_caption.position) as Button).button_pressed = true
		
		name_input.text = current_caption.speaker_name
		caption_input.text = current_caption.text
		extra_input.text = current_caption.extra_formatting
		extra_input.editable = current_caption.speaker_name != ""
		
		lock_signals = false
		
		label.caption = current_caption

func name_picked(id):
	current_caption.speaker_color = speaker_colors[speaker_colors.keys()[id]]
	current_caption.speaker_name = speaker_colors.keys()[id]
	update_caption_display()

func toggle_play(pressed: bool):
	if pressed:
		#FIXME: implement better handling for audioplayer.play, seek and so on ...
		audio_player.play()
	else:
		audio_player.playing = false

func delete_current():
	multi_caption_stream.caption = null
	
func add_new():	
	multi_caption_stream.append_caption(Caption.new(current_time))

func last():
	if not multi_caption_stream.caption == multi_caption_stream._captions_array[0]:
		multi_caption_stream.select_caption -= 1

func next():
	if not multi_caption_stream.caption == multi_caption_stream._captions_array[-1]:
		multi_caption_stream.select_caption += 1
