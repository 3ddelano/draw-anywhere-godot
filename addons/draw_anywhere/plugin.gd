# Draw Anywhere - Godot plugin
# Author: Delano (3ddelano) Lourenco
# https://github.com/3ddelano
# For license: See LICENSE.md


tool
extends EditorPlugin

const SP_KEY_SHIFT = (1 << 25)
const SP_KEY_ALT = (1 << 26)
const SP_KEY_META = (1 << 27)
const SP_KEY_CTRL = (1 << 28)

# -----------Change these to your preferred keys-----------
# Global Shortcuts - Works anywhere
var KEY_DRAW_MODE_TOGGLE = SP_KEY_CTRL | KEY_QUOTELEFT # Ctrl + `
var KEY_TOOLBAR_TOGGLE = SP_KEY_CTRL | KEY_F1 # Ctrl + F1

# Draw mode Shortcuts: These shortcuts will work only when draw mode is active
var KEY_CLEAR_ALL = KEY_C # C key
var KEY_CLEAR_LAST = KEY_Z # Z key
var KEY_RESET_POSITION = KEY_R # R key
# --------------------------------------------------------


const SETTINGS_PATH = "user://draw_anywhere.config"
# Whether the draw mode is active
var is_active = false
var should_draw = false
var canvas: CanvasLayer
var toolbar: Control
var current_line = null

var plugin_settings = {}
var default_plugin_settings = {
	"toolbar_pos": null
}
var draw_settings = {
	"size": 1,
	"min_size": 1,
	"max_size": 16,
	"color": Color("#eee"),
	"antialised": true,
	"begin_cap_mode": Line2D.LINE_CAP_ROUND,
	"end_cap_mode": Line2D.LINE_CAP_ROUND,
	"joint_mode": Line2D.LINE_JOINT_ROUND
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
	# Global shortcuts
	if event is InputEventKey and event.pressed:
		var key = event.get_scancode_with_modifiers()
		match key:
			KEY_DRAW_MODE_TOGGLE:
				# Toggle draw mode was pressed
				set_active(not is_active)
				get_tree().set_input_as_handled()
			KEY_TOOLBAR_TOGGLE:
				# Toggle the toolbar's visibility
				toolbar.visible = not toolbar.visible
				get_tree().set_input_as_handled()


	if not is_active:
		return

	# The following inputs only work when draw mode is active
	# Draw mode shortcuts
	if ((event is InputEventMouseButton and event.button_index == BUTTON_RIGHT) or \
	(event is InputEventKey and event.scancode == KEY_ESCAPE)) and event.pressed:
		# Right mouse button was pressed, so deactivate the draw mode
		set_active(false)
		get_tree().set_input_as_handled()

	if event is InputEventKey and event.pressed:
		var key = event.get_scancode_with_modifiers()
		match key:
			KEY_CLEAR_ALL:
				# Clear all the lines
				_on_clear_button_pressed(false)
				get_tree().set_input_as_handled()

			KEY_CLEAR_LAST:
				# Clear the last line
				var lines = canvas.get_lines()
				var line_count = lines.get_child_count()
				if line_count > 0:
					var last_line = lines.get_child(line_count - 1)
					last_line.queue_free()
				get_tree().set_input_as_handled()

			KEY_RESET_POSITION:
				# Reset the position of the toolbar
				var centered_pos = toolbar.get_viewport_rect().size / 2 - toolbar.rect_size / 2
				toolbar._set_global_position(centered_pos)
				plugin_settings.toolbar_pos = centered_pos
				get_tree().set_input_as_handled()


	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# LMB was pressed, so start the drawing
			should_draw = true
			add_new_line()
			if current_line and is_instance_valid(current_line):
				current_line.add_point(event.position)
				current_line.add_point(event.position + Vector2(0, 1))
		elif should_draw:
			should_draw = false
		get_tree().set_input_as_handled()

	if event is InputEventMouseMotion and should_draw:
		# Add points to the line
		if current_line and is_instance_valid(current_line):
			current_line.add_point(event.position)
		get_tree().set_input_as_handled()

	# Handle scrolling to change size
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			_set_draw_size(draw_settings.size + 1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			_set_draw_size(draw_settings.size - 1)


func _set_draw_size(p_size):
	draw_settings.size = clamp(p_size, draw_settings.min_size, draw_settings.max_size)
	canvas.update_drag_preview_size(self)


func _on_draw_button_pressed(is_now_active):
	# Draw button on the toolbar was pressed
	set_active(is_now_active)


func _on_clear_button_pressed(also_deactivate = true):
	# Clear button on the toolbar was pressed
	if also_deactivate:
		# Also deactivate draw mode
		set_active(false)

	for line in canvas.get_lines().get_children():
		line.queue_free()


func _on_draw_size_changed(new_size) -> void:
	# Draw size slider value was changed
	draw_settings.size = new_size


func _on_color_picker_changed(new_color) -> void:
	# Draw color picker value was changed
	draw_settings.color = new_color


func set_active(value: bool) -> void:
	if is_active == value:
		return

	is_active = value

	if is_active:
		# Draw mode was activated
		toolbar.visible = false
		toolbar.make_draw_button_active()
		toolbar.hide_color_picker_popup()
		canvas.set_lines_as_toplevel(true)
		canvas.block_mouse()
		canvas.get_active_label().visible = true
		canvas.show_draw_preview(self)
	else:
		# Draw mode was deactivated
		current_line = null
		should_draw = false

		toolbar.visible = true
		toolbar.make_draw_button_normal()
		canvas.set_lines_as_toplevel(false)
		canvas.unblock_mouse()
		canvas.get_active_label().visible = false
		canvas.hide_draw_preview()


func add_new_line():
	# Make a new line as our current line
	current_line = Line2D.new()
	current_line.width = draw_settings.size
	current_line.default_color = draw_settings.color
	# Additional properties
	current_line.antialiased = draw_settings.antialised
	current_line.begin_cap_mode = draw_settings.begin_cap_mode
	current_line.end_cap_mode = draw_settings.end_cap_mode
	current_line.joint_mode = draw_settings.joint_mode

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
