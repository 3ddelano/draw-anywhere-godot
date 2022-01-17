# Annotate - Draw in Editor
# Author: Delano (3ddelano) Lourenco
# https://github.com/3ddelano


tool
extends EditorPlugin


var is_active = false
var should_draw = false

var canvas: CanvasLayer
var toolbar: Control
var current_line: Line2D

var draw_settings = {
	"size": 1,
	"color": Color("#eee"),
	"antialised": true
}


func _enter_tree() -> void:
	# Add the global signals as an autolaod

	canvas = preload("res://addons/annotate_draw_in_editor/scenes/Canvas.tscn").instance()
	toolbar = preload("res://addons/annotate_draw_in_editor/scenes/Toolbar.tscn").instance()

	var base_control: Control = get_editor_interface().get_base_control()
	base_control.add_child(canvas)
	add_control_to_bottom_panel(toolbar, "Draw")

	toolbar.connect("draw_button_pressed", self, "_on_draw_button_pressed")
	toolbar.connect("clear_button_pressed", self, "_on_clear_button_pressed")
	toolbar.connect("draw_size_changed", self, "_on_draw_size_changed")
	toolbar.connect("color_picker_changed", self, "_on_color_picker_changed")


func _exit_tree() -> void:
	if is_instance_valid(canvas):
		canvas.queue_free()
	if is_instance_valid(toolbar):
		remove_control_from_bottom_panel(toolbar)
		toolbar.queue_free()


func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_RIGHT:
		if is_active:
			get_tree().set_input_as_handled()
			set_active(false)

	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_QUOTELEFT:
			# Hotkey was pressed
			get_tree().set_input_as_handled()
			set_active(not is_active)


	if not is_active:
		return


	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			canvas.get_lines().grab_focus()
			print("draw started")
			should_draw = true

			var undoredo := get_undo_redo()
			undoredo.create_action("Add new line")
			add_new_line()
			undoredo.add_do_method(self, "add_new_line")
			undoredo.add_undo_method(self, "undo_add_new_line")
			undoredo.commit_action()
		elif should_draw:
			print("draw ended")
			should_draw = false


	if event is InputEventMouseMotion and should_draw:
		get_tree().set_input_as_handled()
		current_line.add_point(event.position)


func add_new_line():
	# Make a new line as our current line
	current_line = Line2D.new()
	current_line.width = draw_settings.size
	current_line.antialiased = draw_settings.antialised
	current_line.default_color = draw_settings.color

	if is_instance_valid(canvas):
		canvas.add_line(current_line)


func undo_add_new_line():
	var last_line = canvas.get_last_line()
	if last_line == null:
		return

	last_line.queue_free()


func _on_draw_button_pressed():
	set_active(true)


func _on_clear_button_pressed():
	set_active(false)
	for line in canvas.get_lines().get_children():
		line.queue_free()


func _on_draw_size_changed(new_size) -> void:
	print("changed")
	draw_settings.size = new_size


func _on_color_picker_changed(new_color) -> void:
	print("color changed")
	draw_settings.color = new_color


func set_active(value: bool) -> void:
	is_active = value

	if is_active:
		print("Turned on")
		canvas.block_mouse()
		make_bottom_panel_item_visible(toolbar)
	else:
		print("Turned off")
		current_line = null
		should_draw = false
		canvas.unblock_mouse()
