tool
extends TextureButton

enum States {
	Normal,
	Active,
	Disabled
}

export (Texture) var icon: Texture setget set_icon

export (States) var state = States.Normal setget set_state

func set_icon(p_icon: Texture) -> void:
	icon = p_icon

	texture_normal = icon
	texture_pressed = icon
	texture_hover = icon
	texture_disabled = icon
	texture_focused = icon

func set_state(p_state: int) -> void:
	state = p_state

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


