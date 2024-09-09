@tool
class_name Speaker extends Resource

signal first_change(speaker: Speaker)
signal name_changed(new_name: StringName)

@export var name: StringName = "":
	set(new_name):
		name = new_name
		name_changed.emit(new_name)
@export var preferred_colour: Caption.Colors = 0:
	set(coloor_id):
		preferred_colour = coloor_id
		changed.emit
@export var theme = Theme:
	set(new_theme):
		theme = new_theme
		changed.emit

@export_group("Theme Override")

@export_subgroup("Colors")
@export var override_font_color: bool = false
@export var font_color: Color = Color.BLACK:
	set(color):
		font_color = color
		if not color == Color.BLACK: override_font_color = true
		changed.emit
@export var override_font_shadow: bool = false
@export var font_shadow: Color = Color.BLACK:
	set(color):
		font_shadow = color
		if not color == Color.BLACK: override_font_shadow = true
		changed.emit
@export var override_font_outline: bool = false
@export var font_outline: Color = Color.BLACK:
	set(color):
		font_outline = color
		if not color == Color.BLACK: override_font_outline = true
		changed.emit
@export_subgroup("Constants")
@export var override_line_spacing: bool = false:
	set(override):
		override_line_spacing = override
		changed.emit
@export var line_spacing: int = 0:
	set(number):
		line_spacing = number
		if number != 0: override_line_spacing = true
		changed.emit
@export var override_shadow_offset_x: bool = false
@export var shadow_offset_x: int = 0:
	set(number):
		shadow_offset_x = number
		if number != 0: override_shadow_offset_x = true
		changed.emit
@export var override_shadow_offset_y: bool = false
@export var shadow_offset_y: int = 0:
	set(number):
		shadow_offset_y = number
		if number != 0: override_shadow_offset_y = true
		changed.emit
@export var override_outline_size: bool = false
@export var outline_size: int = 0:
	set(number):
		outline_size = number
		if number != 0: override_outline_size = true
		changed.emit
@export var override_shadow_size: bool = false
@export var shadow_size: int = 0:
	set(number):
		shadow_size = number
		if number != 0: override_shadow_size = true
		changed.emit

@export_subgroup("Fonts")
@export var normal_font: Font:
	set(font):
		normal_font = font
		changed.emit()
@export var italics_font: Font:
	set(font):
		italics_font = font
		changed.emit()
@export_subgroup("Font Sizes")
@export var override_font_size: bool = false
@export var font_size: int = 0:
	set(number):
		font_size = number
		if number != 0: override_font_size = true
		changed.emit
@export var override_italic_font_size: bool = false
@export var italic_font_size: int = 0:
	set(number):
		italic_font_size = number
		if number != 0: override_italic_font_size = true
		changed.emit
@export_subgroup("Styles")
@export var normal: StyleBox:
	set(style):
		normal = style
		changed.emit()

func _init(name = ""):
	self.name = name
	changed.connect(_on_first_change)

func apply_overrides_to(label: RichTextLabel):
	if theme != null:
		label.theme = theme
	if override_font_color:
		label.add_theme_color_override("default_color", font_color)
	if override_font_shadow:
		label.add_theme_color_override("font_shadow_color", font_shadow)
	if override_font_outline:
		label.add_theme_color_override("font_outline_color", font_outline)
	if override_line_spacing:
		label.add_theme_constant_override("line_separation", line_spacing)
	if override_shadow_offset_x:
		label.add_theme_constant_override("shadow_offset_x", shadow_offset_x)
	if override_shadow_offset_y:
		label.add_theme_constant_override("shadow_offset_y", shadow_offset_y)
	if override_outline_size:
		label.add_theme_constant_override("outline_size", outline_size)
	if override_shadow_size:
		label.add_theme_constant_override("shadow_outline_size", shadow_size)
	if override_font_size:
		label.add_theme_font_size_override("normal_font_size", shadow_size)
	if override_italic_font_size:
		label.add_theme_font_size_override("italics_font_size", shadow_size)
	if normal_font != null:
		label.add_theme_font_override("normal_font", normal_font)
	if italics_font != null:
		label.add_theme_font_override("italics_font", normal_font)
	if normal != null:
		label.add_theme_stylebox_override("normal", normal)

func preview_overrides_on(button: CaptionPanelButton):
	if theme != null:
		button.stylebox = theme.get_stylebox("normal", "RichTextLabel")
	if override_font_color:
		button.add_theme_color_override("font_color", font_color)
	if normal != null:
		button.add_theme_stylebox_override("normal", normal)

func _on_first_change():
	changed.disconnect(_on_first_change)
	first_change.emit(self)
