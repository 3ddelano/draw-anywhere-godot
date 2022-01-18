# Annotate - Draw in Editor
# Author: Delano (3ddelano) Lourenco
# https://github.com/3ddelano


tool
extends EditorPlugin

# Change these to your preferred keys
var KEY_DRAW_MODE_TOGGLE = 268435552 # Ctrl + `
var KEY_CLEAR_ALL = KEY_C
var KEY_CLEAR_LAST = KEY_Z
var KEY_RESET_POSITION = KEY_R


# -----------------------------------


# Whether the draw mode is active
const SETTINGS_PATH = "user://draw_anywhere.config"
var is_active = false
var canvas: CanvasLayer
var toolbar: Control
var should_draw = false
var current_line = null

var plugin_settings = {}
var default_plugin_settings = {
	"toolbar_pos": null
}
var draw_settings = {
	"size": 1,
	"color": Color("#eee"),
	"antialised": true
}


func _enter_tree() -> void:
	# Instance and add the canvas
	canvas = preload("res://addons/draw_anywhere/scenes/Canvas.tscn").instance()
	var base_control: Control = get_editor_interface().get_base_control()
	base_control.add_child(canvas)

	# Get the toolbar and connect some signals
	toolbar = canvas.get_toolbar()
	var base_theme: Theme = base_control.get_theme()
	toolbar.theme = base_theme

	toolbar.connect("draw_button_pressed", self, "_on_draw_button_pressed")
	toolbar.connect("clear_button_pressed", self, "_on_clear_button_pressed")
	toolbar.connect("draw_size_changed", self, "_on_draw_size_changed")
	toolbar.connect("color_picker_changed", self, "_on_color_picker_changed")
	toolbar.connect("stop_draw", self, "_on_toolbar_stop_draw")
	toolbar.connect("pos_changed", self, "_on_toolbar_pos_changed")

	load_settings()

	if plugin_settings.toolbar_pos:
		yield(get_tree(), "idle_frame")
		toolbar._set_global_position(plugin_settings.toolbar_pos)


func _exit_tree() -> void:
	save_settings()
	# Cleanup the canvas by deleting
	if is_instance_valid(canvas):
		canvas.queue_free()


func _input(event: InputEvent) -> void:
	if is_active:
		# Only when draw mode is active should these shortcuts work

		if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_RIGHT:
			# Right mouse button was pressed, so deactivate the draw mode
			set_active(false)
			get_tree().set_input_as_handled()

		if event is InputEventKey and event.pressed:
			if event.scancode == KEY_CLEAR_ALL:
				# C key was pressed, so clear the lines
				_on_clear_button_pressed(false)
				get_tree().set_input_as_handled()

			if event.scancode == KEY_CLEAR_LAST:
				# Z key was pressed, so clear last line
				var lines = canvas.get_lines()
				var line_count = lines.get_child_count()
				if line_count > 0:
					var last_line = lines.get_child(line_count - 1)
					last_line.queue_free()
				get_tree().set_input_as_handled()

			if event.scancode == KEY_RESET_POSITION:
				var centered_pos = toolbar.get_viewport_rect().size / 2 - toolbar.rect_size / 2
				toolbar._set_global_position(centered_pos)
				plugin_settings.toolbar_pos = centered_pos
				get_tree().set_input_as_handled()


	if event is InputEventKey and event.pressed and event.get_scancode_with_modifiers() == KEY_DRAW_MODE_TOGGLE:

		# Toggle draw mode was pressed
		set_active(not is_active)
		get_tree().set_input_as_handled()
		event = event as InputEventKey

	if not is_active:
		return

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# LMB was pressed, so start the drawing
			should_draw = true
			add_new_line()
		elif should_draw:
			should_draw = false
		get_tree().set_input_as_handled()

	if event is InputEventMouseMotion and should_draw:
		# When mouse is moving and should_draw is true, so add points to the line
		if current_line and is_instance_valid(current_line):
			current_line.add_point(event.position)
		get_tree().set_input_as_handled()


func _on_draw_button_pressed(is_now_active):
	# Draw button on the toolbar was pressed
	set_active(is_now_active)


func _on_clear_button_pressed(also_deactivate = true):
	if also_deactivate:
		set_active(false)
	for line in canvas.get_lines().get_children():
		line.queue_free()


func _on_draw_size_changed(new_size) -> void:
	draw_settings.size = new_size


func _on_color_picker_changed(new_color) -> void:
	draw_settings.color = new_color


func set_active(value: bool) -> void:
	if is_active == value:
		return

	is_active = value

	if is_active:
		toolbar.make_draw_button_active()
		canvas.set_lines_as_toplevel(true)
		canvas.block_mouse()
		toolbar.hide_color_picker_popup()
		canvas.get_active_label().visible = true
	else:
		current_line = null
		should_draw = false

		canvas.set_lines_as_toplevel(false)
		canvas.unblock_mouse()
		toolbar.make_draw_button_normal()
		canvas.get_active_label().visible = false


func add_new_line():
	# Make a new line as our current line
	current_line = Line2D.new()
	current_line.width = draw_settings.size
	current_line.antialiased = draw_settings.antialised
	current_line.default_color = draw_settings.color

	canvas.get_lines().add_child(current_line)


func _on_toolbar_stop_draw():
	set_active(false)


func _on_toolbar_pos_changed(new_pos):
	plugin_settings.toolbar_pos = new_pos


func save_settings():
	var settings_to_save = {}

	# Save only the non-default value settings
	for key in plugin_settings.keys():
		if plugin_settings[key] != default_plugin_settings[key]:
			settings_to_save[key] = plugin_settings[key]

	if settings_to_save.empty():
		# Nothing to save
		return

	var file = File.new()
	file.open(SETTINGS_PATH, File.WRITE)
	file.store_string(var2str(settings_to_save))
	file.close()

func load_settings():
	var file = File.new()
	var err = file.open(SETTINGS_PATH, File.READ)
	if err != OK:
		# Error opening saved settings
		plugin_settings = default_plugin_settings.duplicate(true)
		return


	var content = file.get_as_text()
	file.close()
	plugin_settings = str2var(content)
