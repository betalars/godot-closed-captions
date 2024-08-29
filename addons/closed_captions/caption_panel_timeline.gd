extends VBoxContainer

var minute_size:float = 64
var caption_stacks: Array[Array]

@export_range(0.1, 2) var current_time_scale = 1:
	set(time_scale):
		if time_scale >= 0 and time_scale <= 1:
			current_time_scale = time_scale
		elif time_scale <= 2:
			current_time_scale = time_scale**2
		
		if is_node_ready():
			minute_size = total_pixels/current_time_scale
@onready var total_pixels:int = size.x

@export var time_begin: float
@export var time_end: float
@export var time_cursor: float
@export var multi_caption_stream: MultiCaptionAudioStream:
	set(new):
		if multi_caption_stream!= null:
			multi_caption_stream.caption_changed.disconnect(populate)
		multi_caption_stream = new
		if multi_caption_stream!= null:
			multi_caption_stream.caption_changed.connect(populate)
			populate()
@onready var time_labels: HBoxContainer = $TimeLabels
@onready var time_selector: HSlider = $TimeSelector
@onready var button_timelines: VBoxContainer = $Buttons


signal caption_reached(captin: Caption)
signal caption_selected(captin: Caption)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_readable_time(mins: float) -> String:
	if mins > 1:
		return mins * 60 as String
	else:
		return "%d:%d" % [floor(mins), floor(fmod(mins, 1) * 60)]

func populate() -> void:
	if is_node_ready():
		generate_stack()
	
		print(caption_stacks)
		
		for child in button_timelines.get_children():
			button_timelines.remove_child(child)
		
		for stack: Array[Caption] in caption_stacks:
			var time = time_begin
			var row = HBoxContainer.new()
			button_timelines.add_child(row)
			
			for i in range(stack.size()):
				row.add_child(CaptionPanelTimelineButton.new(stack[i], minute_size, time_end if i == stack.size()-1 else stack[i+1].delay))
				if stack[i].duration != 0:
					if i < stack.size()-2:
						if stack[i].duration + stack[i].delay > stack[i+1].delay:
							var spacer = VSeparator.new()
							spacer.custom_minimum_size.x = (min(stack[i+1].delay, time_end) - stack[i].duration - stack[i].delay) * minute_size
							row.add_child(spacer)

func generate_stack() -> void:
	caption_stacks = [[]]
	
	print(multi_caption_stream._captions_array)
	
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
