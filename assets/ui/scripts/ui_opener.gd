extends Node

func _input(event):
	if Input.is_action_just_pressed("in_game_menu"):
		get_parent().visible = !get_parent().visible
