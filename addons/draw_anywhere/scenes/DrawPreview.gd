tool
extends Panel

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	rect_global_position = get_global_mouse_position() - rect_size / 2
