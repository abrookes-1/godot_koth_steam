extends Spatial


func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func _process(delta):
#	if (Input.is_action_just_pressed("ui_cancel")):
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#		get_tree().quit()
#	if (Input.is_action_just_pressed("esc_menu")):
#		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#		else:
#			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
