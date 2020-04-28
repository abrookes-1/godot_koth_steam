extends Node


onready var select_sound_player = $SelectSound
var count = 0

func _on_tab_selected(tab_indx):
	# check that the sound has played at least twice. the first two are caused by game startup, not the user
	if count > 1:
		select_sound_player.play()
	else:
		count += 1
