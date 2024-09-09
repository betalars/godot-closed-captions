@tool
class_name CaptionPanelTimeline extends VBoxContainer

var minute_size:float:
	set(no):
		assert(false)
	get():
		if is_node_ready():
			return (total_pixels/time_scale)/60
		else:
			return 42
var caption_stacks: Array[Array]

@export_range(0.1, 2) var time_scale:float = 1:
	set(value):
		if value == null: return
		
		if value >= 0 and value <= 1:
			time_scale = value
		elif time_scale <= 2:
			time_scale = value**2
		populate()

@onready var total_pixels:int = get_viewport().get_visible_rect().size.x-128

@export var time_begin: float
@export var time_end: float:
	set(no):
		assert(false)
	get():
		return time_begin + (time_scale * 60)
@export var time_cursor: float
@export var multi_caption_stream: MultiCaptionAudioStream:
	set(new):
		if multi_caption_stream!= null:
			multi_caption_stream.captions_changed.disconnect(populate)
		multi_caption_stream = new
		if multi_caption_stream!= null:
			multi_caption_stream.captions_changed.connect(populate)
			populate()
@onready var time_labels: HBoxContainer = $TimeLabels
@onready var time_selector: HSlider = $TimeSelector
@onready var button_timelines: VBoxContainer = $Buttons


signal caption_reached(captin: Caption)
signal caption_selected(captin: Caption)

func select_time_scale(value:float) -> void:
	time_scale = value

func get_readable_time(mins: float) -> String:
	if mins > 1:
		return mins * 60 as String
	else:
		return "%d:%d" % [floor(mins), floor(fmod(mins, 1) * 60)]

func fill_timeline():
	var seperator:VSeparator
	var label
	
	for i in range(2):
		if get_child(i) is VSeparator:
			seperator = get_child(i)
		else:
			label = get_child(i)

	for child in get_children():
		remove_child(child)

func populate() -> void:
	if is_node_ready():
		generate_stack()
		
		for child in button_timelines.get_children():
			button_timelines.remove_child(child)
		
		for stack: Array[Caption] in caption_stacks:
			var time = time_begin
			var row = HBoxContainer.new()
			button_timelines.add_child(row)
			
			for i in range(stack.size()):
				if stack[i].delay > time_end: break
				var captionButton:= CaptionPanelButton.new(stack[i], minute_size, min(time_end, minute_size*0.1) if i == stack.size()-1 else stack[i+1].delay)
				captionButton.pressed.connect(multi_caption_stream.set.bind("caption", captionButton.caption))
				row.add_child(captionButton)
				if stack[i].duration != 0:
					if i < stack.size()-2:
						if stack[i].duration + stack[i].delay > stack[i+1].delay:
							var spacer = VSeparator.new()
							spacer.custom_minimum_size.x = (min(stack[i+1].delay, time_end) - stack[i].duration - stack[i].delay) * minute_size
							row.add_child(spacer)
		
		time_selector.min_value = time_begin
		time_selector.max_value = time_end

func generate_stack() -> void:
	caption_stacks = [[]]
	
	var depth = 0
	var last_end = -1
	for caption in multi_caption_stream._captions_array:
		if last_end > caption.delay:
			depth += 1
			if depth > caption_stacks.size()-1:
				caption_stacks.resize(depth+1)
		else:
			depth = 0
		caption_stacks[depth].append(caption)
		if caption.delay + caption.duration > last_end:
			last_end = caption.delay + caption.duration
