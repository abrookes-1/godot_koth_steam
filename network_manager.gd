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
#	if is_host:
#		pass
#	else:
	_process_server_updates()
		

func _process_client_updates():
	# get updates from all clients
	pass

func _process_server_updates():
	# get updates from server
	var data = steam_controller._read_P2P_Packet()
	if data != null and data.has('directive'):
		print('checking directive' + str(data['directive']))
		if data['directive'] == 'position':
			do_position_directive(data)
		elif data['directive'] == 'spawn':
			print("spawning object")
			do_spawn_directive(data)

func add_networked_node(node):
	net_nodes[node.net_id] = node

func send_spawn(type, position, net_id, params):
	var DATA = PoolByteArray()
	var d = {
		'directive': 'spawn',
		'type': type,
		'net_id': net_id,
		'position': position,
		'params': params
	}
	DATA.append(256)
	DATA.append_array(var2bytes(d))
	steam_controller._send_P2P_Packet(DATA, 2, 0)
	print(d)

func send_position(node):
	var DATA = PoolByteArray()
	var d = {
		'directive': 'position',
		'net_id': node.net_id,
		'position': node.translation,
		'rotation': node.get_rotation()
	}
	DATA.append(256)
	DATA.append_array(var2bytes(d))
	steam_controller._send_P2P_Packet(DATA, 1, 0)
	
func do_position_directive(data):
	if net_nodes.has(data['net_id']):
		net_nodes[data['net_id']].set_pos(data['position'])
		net_nodes[data['net_id']].set_rotation(data['rotation'])
	else:
		print('Warning: tried to move nonexistent net_id ' + str(data['net_id']))

func do_spawn_directive(data):
	# spawn new object
	var new_player = spawnable[data['type']].instance()
	new_player.set_pos(data['position'])
	new_player.net_id = data['net_id']
	new_player.spawn_params = data['params']
	get_tree().get_root().add_child(new_player)
	# push to networked objects
	add_networked_node(new_player)

func spawn_new_networked(type, position, params={}):
	# spawn new object
	var new_player = spawnable[type].instance()
	new_player.set_pos(position)
	new_player.net_id = get_new_id()
	new_player.spawn_params = params
	get_tree().get_root().add_child(new_player)
	var network_id = new_player.net_id
	# push to networked objects
	add_networked_node(new_player)
	# send spawn directive to clients
	send_spawn(type, position, network_id, params)
	
func get_new_id():
	id_counter = id_counter + 1
	return id_counter
