tool
extends HBoxContainer

signal draw_button_pressed()
signal clear_button_pressed()

# Called when the user changes size slider value
signal draw_size_changed(new_size) # new_size: int

# Called when the user changes the color in the color picker
signal color_picker_changed(new_color) # new_size: int


enum ToolbarButtonStates {
	Normal,
	Active,
	Disabled
}

func _ready() -> void:
	# Connect button signals
	$DrawButton.connect("pressed", self, "_on_draw_button_pressed")
	$ClearButton.connect("pressed", self, "_on_clear_button_pressed")
	$ColorPickerButton.connect("color_changed", self, "_on_color_picker_changed")

	# Connect size slider
	$DrawSize.connect("value_changed", self, "_on_draw_size_value_changed")
	$DrawSizeLabel.text = str($DrawSize.value)


func _on_draw_button_pressed() -> void:
	$DrawButton.set_state(ToolbarButtonStates.Active)
	$ClearButton.set_state(ToolbarButtonStates.Normal)
	emit_signal("draw_button_pressed")


func _on_clear_button_pressed() -> void:
	$ClearButton.set_state(ToolbarButtonStates.Active)
	$DrawButton.set_state(ToolbarButtonStates.Normal)
	emit_signal("clear_button_pressed")


func _on_color_picker_changed(new_color: Color) -> void:
	emit_signal("color_picker_changed", new_color)


func _on_draw_size_value_changed(new_size) -> void:
	$DrawSizeLabel.text = str(new_size)
	emit_signal("draw_size_changed", new_size)
