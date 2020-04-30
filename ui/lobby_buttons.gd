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
	


func _on_start_pressed():
	var players = steam_controller.LOBBY_MEMBERS
	
	for player in players:
		var spawn_params = player
		network_manager.spawn_new_networked('player', spawn_pos, spawn_params)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
