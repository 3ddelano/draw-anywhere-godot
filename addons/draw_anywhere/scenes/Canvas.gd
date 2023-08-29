@tool
extends CanvasLayer

var lines: Control
var toolbar
var draw_preview: Panel

func _ready() -> void:
	lines = $Lines
	toolbar = $Toolbar
	draw_preview = $DrawPreview
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
	lines.top_level = value


func show_draw_preview(plugin):
	draw_preview.size = Vector2(plugin.draw_settings.size, plugin.draw_settings.size)
	draw_preview.self_modulate = plugin.draw_settings.color
	draw_preview.visible = true
	draw_preview.set_process(true)

func update_drag_preview_size(plugin):
	draw_preview.size = Vector2(plugin.draw_settings.size, plugin.draw_settings.size)


func hide_draw_preview():
	draw_preview.visible = false
	draw_preview.set_process(false)
