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
	# load scene
	
	# spawn player
	var new_player = player_base.instance()
	new_player.set_pos(spawn_pos)
	get_tree().get_root().add_child(new_player)
	# push to networked objects
	network_manager.add_networked_node(new_player)

func _on_join_pressed():
	pass
