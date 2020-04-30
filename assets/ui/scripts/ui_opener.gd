extends Node

func _input(event):
	if Input.is_action_just_pressed("in_game_menu"):
		if get_parent().visible == true:
			get_parent().set_visible(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			get_parent().set_visible(true)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
