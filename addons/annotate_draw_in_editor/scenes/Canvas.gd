tool
extends CanvasLayer


func get_lines():
	return $Lines

func block_mouse():
	$Lines.mouse_filter = Control.MOUSE_FILTER_STOP


func unblock_mouse():
	$Lines.mouse_filter = Control.MOUSE_FILTER_IGNORE


func add_line(line: Line2D) -> void:
	$Lines.add_child(line)


func get_last_line() -> Line2D:
	var child_count = $Lines.get_child_count()
	print(child_count)
	if child_count == 0:
		return null

	return $Lines.get_child(child_count - 1) as Line2D
