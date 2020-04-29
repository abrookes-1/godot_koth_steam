extends Control

var spawn_pos = Vector3(0,10,0)

onready var steam_controller = $"/root/SteamController"
onready var network_manager = $"/root/NetworkManager"

onready var player_base = preload("res://characters/player/player.tscn")

func _ready():
	pass
	
func _on_create_pressed():
	# create steam lobby
	steam_controller._create_Lobby()
	
	network_manager.spawn_new_networked('player', Vector3(0,10,0))

func _on_join_pressed():
	pass
