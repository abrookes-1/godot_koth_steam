extends Node

onready var viewport = get_viewport()

func _ready():
	viewport.connect("size_changed", self, "_on_size_changed")
	_on_size_changed()

func _on_size_changed():
	var current_size = OS.get_window_size()

	get_parent().rect_size = current_size

