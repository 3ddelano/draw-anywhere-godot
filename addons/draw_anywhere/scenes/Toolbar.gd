tool
extends PanelContainer

signal draw_button_pressed(is_now_active)
signal clear_button_pressed()

# Called when the user changes size slider value
signal draw_size_changed(new_size) # new_size: int

# Called when the user changes the color in the color picker
signal color_picker_changed(new_color) # new_size: int

signal stop_draw()
signal pos_changed(new_pos)

var drag_start_position = null

enum ToolbarButtonStates {
	Normal,
	Active,
	Disabled
}

onready var draw_button = $MC/VB/HB/DrawButton
onready var clear_button = $MC/VB/HB/ClearButton
onready var color_picker_button = $MC/VB/HB/ColorPickerButton
onready var draw_size_slider = $MC/VB/HB/DrawSize
onready var draw_size_label = $MC/VB/HB/DrawSizeLabel

onready var help_button = $MC/VB/Top/HelpButton
onready var help_popup = $HelpPopup

func _ready() -> void:
	# Connect button signals
	draw_button.connect("pressed", self, "_on_draw_button_pressed")
	clear_button.connect("pressed", self, "_on_clear_button_pressed")
	color_picker_button.connect("color_changed", self, "_on_color_picker_changed")

	# Connect size slider
	draw_size_slider.connect("value_changed", self, "_on_draw_size_value_changed")
	draw_size_label.text = str(draw_size_slider.value)

	# Connect gui inputs
	draw_button.connect("gui_input", self, "_on_gui_input")
	clear_button.connect("gui_input", self, "_on_gui_input")
	color_picker_button.connect("gui_input", self, "_on_gui_input")
	draw_size_slider.connect("gui_input", self, "_on_gui_input")

	# Help button
	help_button.connect("pressed", self, "show_help")


func _on_draw_button_pressed() -> void:
	if draw_button.state == ToolbarButtonStates.Active:
		# It was active, so make it normal
		draw_button.set_state(ToolbarButtonStates.Normal)
		emit_signal("draw_button_pressed", false)
	else:
		draw_button.set_state(ToolbarButtonStates.Active)
		clear_button.set_state(ToolbarButtonStates.Normal)
		emit_signal("draw_button_pressed", true)


func _on_clear_button_pressed() -> void:
	#clear_button.set_state(ToolbarButtonStates.Active)
	draw_button.set_state(ToolbarButtonStates.Normal)
	emit_signal("clear_button_pressed")


func _on_color_picker_changed(new_color: Color) -> void:
	emit_signal("color_picker_changed", new_color)


func _on_draw_size_value_changed(new_size) -> void:
	draw_size_label.text = str(new_size)
	emit_signal("draw_size_changed", new_size)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		emit_signal("stop_draw")

		if event.pressed:
			drag_start_position = get_global_mouse_position() - rect_global_position
		else:
			drag_start_position = null

		accept_event()


	# Dragging the toolbar
	if event is InputEventMouseMotion and drag_start_position:
		rect_global_position = get_global_mouse_position() - drag_start_position
		emit_signal("pos_changed", rect_global_position)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		emit_signal("stop_draw")


func make_draw_button_normal():
	draw_button.set_state(ToolbarButtonStates.Normal)


func make_draw_button_active():
	draw_button.set_state(ToolbarButtonStates.Active)


func show_help():
	help_popup.popup_centered()


func hide_color_picker_popup():
	color_picker_button.get_popup().hide()
