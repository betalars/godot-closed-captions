@tool
extends Node
# I would really like to move this code into the main plugin script, but for some reason that does not work.

enum scaling_type {
	## Detects the correct setting depending on environment variables.
	DETECT,
	## Setting for Desktop Applications. Size is based around the DPI of the Display. When window is really small, it falls back to the BBC Minimum of 8% window heigt.
	DESKTOP,
	## Setting assumes a far-away screen and mostly scales with resolution. Screens with bigger resolutions have slighlty smaller captions relative to screen size.
	CONSOLE,
	## Setting for Mobile Applications. Works similar to desktop, but assumes device is closer to the user so Text will be smaller in real-world scale.
	MOBILE,
	## Setting for Web apps, that are assumed to sometimes run in very small windows.
	BBC
}

var scaling_behaviour:scaling_type = scaling_type.DESKTOP:
	set(new):
		scaling_behaviour = new
		# Setting Editor Scaling to largest possible default.
		if !OS.has_feature("editor"):
			_scaling_behaviour = scaling_type.BBC
			if not new == scaling_behaviour:
				push_warning("meep")
		else:
			if new == scaling_type.DETECT:
				match OS.get_name():
					"Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
						_scaling_behaviour = scaling_type.DESKTOP
					"Android", "iOS":
						_scaling_behaviour = scaling_type.MOBILE
					"Web":
						if OS.has_feature("mobile"):
							_scaling_behaviour = scaling_type.MOBILE
						else:
							_scaling_behaviour = scaling_type.DESKTOP
					_:
						_scaling_behaviour = scaling_type.CONSOLE
		
var _scaling_behaviour:scaling_type = scaling_type.DESKTOP:
	set(new):
		_scaling_behaviour = new
		_on_app_resized()

var captions_theme:Theme = preload("res://addons/closed_captions/captions.theme")

func _enter_tree():
	ProjectSettings.settings_changed.connect(_on_project_settings_update)
	if ProjectSettings.has_setting("settings_initialised"):
		get_tree().root.get_viewport().size_changed.connect(_on_app_resized)
		_on_project_settings_update()

func _exit_tree():
	ProjectSettings.settings_changed.disconnect(_on_project_settings_update)

func _on_app_resized():
	var vis_rect:Rect2 = get_tree().root.get_viewport().get_visible_rect() if !OS.has_feature("editor") else Rect2(0, 0, ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_width"))
	
	var dpi: int = DisplayServer.screen_get_dpi()
	
	match _scaling_behaviour:
		scaling_type.BBC:
			## The official BBC reccomendation. 8% screen height on landscape content and 4.5% screen height on portrait content.
			if vis_rect.size.y < vis_rect.size.x:
				captions_theme.default_font_size = 0.08 * vis_rect.size.y
			else:
				captions_theme.default_font_size = 0.045 * vis_rect.size.y
		
		scaling_type.CONSOLE:
			## Close to official BBC reccomendation, but a bit smaller and larger screens will have slightly reduced relative text size.
			captions_theme.default_font_size = min(80 + (vis_rect.size.y - 1080) * 40/1080, 0.08 * vis_rect.size.y)
		
		scaling_type.DESKTOP:
			## Basing the Scaling off of Display DPI, but falling back to the BBC guidance as a minimum for when app is run in a small window.
			if vis_rect.size.y < vis_rect.size.x:
				captions_theme.default_font_size = min( dpi/2.5, 0.08 * vis_rect.size.y)
			else:
				captions_theme.default_font_size = min( dpi/3, 0.045 * vis_rect.size.y)
		scaling_type.MOBILE:
			## Basing resolution based off of total real world screen height. The bigger the Screen IRL, the less space closed caption takes up of the relative screen size.
			if vis_rect.size.y < vis_rect.size.x:
				captions_theme.default_font_size = max(vis_rect.size.y / dpi - 2, 0) * dpi/6 + dpi/4
			else:
				captions_theme.default_font_size = max(vis_rect.size.y / dpi - 2, 0) * dpi/8 + dpi/6

func _on_project_settings_update():
	if ProjectSettings.has_setting("settings_initialised"):
		var font_name:StringName = ProjectSettings.get_setting(CaptionPlugin.use_custom_font_path)
		
		if captions_theme.default_font is SystemFont:
			# Making sure Sans-Serif is always a failover in case font name does not resolve.
			captions_theme.default_font.font_names.insert(0, "sans-serif")
			if font_name != "font name":
				captions_theme.default_font.font_names.insert(0, font_name)
		else:
			push_warning("costum font configuration found, ignoring name set in Project Settings.")
		
		captions_theme.default_base_scale = ProjectSettings.get_setting(CaptionPlugin.text_scaling_path)
		var background: StyleBox = StyleBoxFlat.new()
		var bg_color: Color = ProjectSettings.get_setting(CaptionPlugin.background_color_path)
		if bg_color.a < 0.7:
			bg_color.a = 0.7
			push_warning("Transparency below 70% is not supported.")
		if bg_color.v > 0.6:
			bg_color.v = 0.6
			push_warning("Backgound Color must be WGCA complient. Setting was set too bright.")
		if bg_color.s > 0.7:
			bg_color.v = 0.6
			push_warning("High saturation of colour would cause some speaker names to blend into the background.")
		if !bg_color == ProjectSettings.get_setting(CaptionPlugin.background_color_path):
			push_warning("Background Color Settings have been adjusted.")
		background.bg_color = ProjectSettings.get_setting(CaptionPlugin.background_color_path)
		captions_theme.set_stylebox("normal", "RichTextLabel", background)
		
		## Updating the font size.
		_on_app_resized()
