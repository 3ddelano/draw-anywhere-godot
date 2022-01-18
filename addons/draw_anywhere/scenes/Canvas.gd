tool
extends CanvasLayer

var lines
var toolbar
var pencil

func _ready() -> void:
	lines = $Lines
	toolbar = $Toolbar
	pencil = $Pencil
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
	if value:
		lines.show_modal(true)


func show_pencil(plugin):
	pencil.rect_size = Vector2(plugin.draw_settings.size, plugin.draw_settings.size)
	pencil.self_modulate = plugin.draw_settings.color
	pencil.visible = true
	pencil.set_process(true)

func hide_pencil():
	pencil.visible = false
	pencil.set_process(false)
