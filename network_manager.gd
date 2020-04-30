extends Node

var is_host = false
var net_nodes = {}
var id_counter = 0

onready var steam_controller = $"/root/SteamController"

onready var spawnable = {
	'player': preload("res://characters/player/player.tscn")
}

func _ready():
	pass


func _physics_process(delta):
	if is_host:
		#_process_client_updates()
		#_send_updates()
		pass
	else:
		_process_server_updates()
		

func _process_client_updates():
	# get updates from all clients
	pass

func _process_server_updates():
	# get updates from server
	var data = steam_controller._read_P2P_Packet()
	if data and data.get('directive'):
		if data['directive'] == 'position':
			do_position_directive(data)
		elif data['directive'] == 'spawn':
			do_spawn_directive(data)

func add_networked_node(node):
	net_nodes[node.net_id] = node

func send_spawn(type, position, net_id):
	var DATA = PoolByteArray()
	var d = {
		'directive': 'spawn',
		'type': type,
		'net_id': net_id,
		'position': position,
	}
	DATA.append(256)
	DATA.append_array(var2bytes(d))
	steam_controller._send_P2P_Packet(DATA, 2, 0)

func send_position(node):
	var DATA = PoolByteArray()
	var d = {
		'directive': 'position',
		'net_id': node.net_id,
		'position': node.translation,
	}
	DATA.append(256)
	DATA.append_array(var2bytes(d))
	steam_controller._send_P2P_Packet(DATA, 2, 0)
	
func do_position_directive(data):
	pass

func do_spawn_directive(data):
	print("spawning object")
	# spawn new object
	var new_player = spawnable[data['type']].instance()
	new_player.set_pos(data['position'])
	new_player.net_id = data['net_id']
	get_tree().get_root().add_child(new_player)
	# push to networked objects
	add_networked_node(new_player)

func spawn_new_networked(type, position):
	# spawn new object
	var new_player = spawnable[type].instance()
	new_player.set_pos(position)
	new_player.net_id = get_new_id()
	get_tree().get_root().add_child(new_player)
	# push to networked objects
	add_networked_node(new_player)
	# send spawn directive to clients
	send_spawn(type, position, new_player.net_id)
	
func get_new_id():
	id_counter += 1
	return id_counter
