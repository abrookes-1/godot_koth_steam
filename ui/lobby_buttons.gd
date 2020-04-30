extends Control

#var spawn_pos = Vector3(0,10,0)
onready var spawn_transform = $'/root/Main/SpawnPoint'.transform

onready var steam_controller = $"/root/SteamController"
onready var network_manager = $"/root/NetworkManager"

onready var player_base = preload("res://characters/player/player.tscn")
onready var player_label = preload("res://ui/menus/player_name_label.tscn")
onready var in_lobby_menu = $'InLobbyMenu'
onready var main_options = $'MainOptions'
onready var player_list = in_lobby_menu.get_node("VBoxContainer/MarginContainer/PlayersList")

func _ready():
	Steam.connect('lobby_chat_update', self, '_on_lobby_update')
	Steam.connect('lobby_joined', self, '_on_lobby_update')
	#in_lobby_menu.connect('visibility_changed', self, '_on_lobby_update')

func _on_lobby_update(lobbyID, changedID, makingChangeID, chatState):
	_update_lobby_list()

func _update_lobby_list():
	# clear all children
	for i in range(0, player_list.get_child_count()):
		player_list.get_child(i).queue_free()
	# add player labels
	for player in steam_controller.LOBBY_MEMBERS:
		var label = Label.new()
		label.set_text(player['steam_name'])
		player_list.add_child(label)

func _on_create_pressed():
	# create steam lobby
	steam_controller._create_Lobby()
	main_options.set_visible(false)
	in_lobby_menu.set_visible(true)


func _on_start_pressed():
	var players = steam_controller.LOBBY_MEMBERS
	
	for player in players:
		var spawn_params = player
		network_manager.spawn_new_networked('player', spawn_transform, spawn_params)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	in_lobby_menu.set_visible(false)

