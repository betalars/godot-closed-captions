# Small Utility to generate clickable previews of captions in buttom panel.
extends Button
class_name CaptionPanelTimelineButton

var caption: Caption:
	set(new):
		if caption != null: caption.changed.disconnect(rebuild)
		caption = new
		if caption != null:
			caption.changed.connect(rebuild)
		rebuild()
var timescale: float
var max_time: float
var color_override: Caption.Colors
var stylebox: StyleBoxFlat = StyleBoxFlat.new()

func _init(caption: Caption, timescale: float, max_time: float, color_override: Caption.Colors = Caption.Colors.AUTOMATIC):
	timescale = timescale
	max_time = max_time
	color_override = color_override
	caption = caption
	
	stylebox.set_corner_radius_all(4)
	stylebox.border_blend = true
	stylebox.border_color = Color.LIGHT_SLATE_GRAY

func rebuild():
	# this component cannot set its own color automatically
	assert(not (caption.speaker_color == Caption.Colors.AUTOMATIC and color_override == Caption.Colors.AUTOMATIC))
	
	if color_override == Caption.Colors.AUTOMATIC:
		color_override = caption.speaker_color
	
	match color_override:
		Caption.Colors.WHITE:	stylebox.bg_color = Color.WHITE
		Caption.Colors.YELLOW:	stylebox.bg_color = Color.YELLOW
		Caption.Colors.CYAN:	stylebox.bg_color = Color.CYAN
		Caption.Colors.GREEN:	stylebox.bg_color = Color.GREEN
		Caption.Colors.PURPLE:	stylebox.bg_color = Color.MEDIUM_PURPLE
		Caption.Colors.VIOLET:	stylebox.bg_color = Color.VIOLET
		Caption.Colors.SALMON:	stylebox.bg_color = Color.SALMON
		Caption.Colors.BLUE:	stylebox.bg_color = Color.DODGER_BLUE
	
	add_theme_stylebox_override("normal", stylebox)
	
	if caption.duration == -1 or caption.duration + caption.delay > max_time:
		stylebox.border_width_right = 8
		stylebox.corner_radius_bottom_right = 0
		stylebox.corner_radius_bottom_left = 0
	else:
		stylebox.border_width_right = 0
		stylebox.corner_radius_bottom_right = 4
		stylebox.corner_radius_bottom_left = 4
		
	custom_minimum_size.x = (max(caption.duration + caption.delay, max_time) - caption.delay) * timescale
