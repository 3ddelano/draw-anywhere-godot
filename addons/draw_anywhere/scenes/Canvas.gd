tool
extends CanvasLayer

var lines
var toolbar

func _ready() -> void:
	lines = $Lines
	toolbar = $Toolbar
	$ActiveLabel.visible = false


func get_lines():
	return lines


func get_toolbar():
	return toolbar


func get_active_label():
	return $ActiveLabel


func block_mouse():
	lines.mouse_filter = Control.MOUSE_FILTER_STOP


func unblock_mouse():
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_lines_as_toplevel(value: bool):
	lines.set_as_toplevel(value)
	toolbar.set_as_toplevel(value)
	if value:
		lines.show_modal(true)
		#toolbar.show_modal(true)

