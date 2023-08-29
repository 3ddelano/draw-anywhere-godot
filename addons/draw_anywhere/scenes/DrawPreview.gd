@tool
extends Panel

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position() - size / 2
