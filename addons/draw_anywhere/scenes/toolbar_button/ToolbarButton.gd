@tool
extends TextureButton

enum States {
	Normal,
	Active,
	Disabled
}

@export var icon: Texture:
	set(value):
		icon = value

		texture_normal = icon
		texture_pressed = icon
		texture_hover = icon
		texture_disabled = icon
		texture_focused = icon

@export var state: States = States.Normal:
	set(value):
		state = value

		if state == States.Active:
			$Active.visible = true
		else:
			$Active.visible = false

		if state == States.Disabled:
			modulate = Color("#111")
		else:
			modulate = Color("#eee")

		if state in [States.Normal, States.Active]:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		else:
			mouse_default_cursor_shape = Control.CURSOR_ARROW

func set_icon(p_icon: Texture) -> void:
	icon = p_icon

func set_state(p_state: int) -> void:
	state = p_state

func _gui_input(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
