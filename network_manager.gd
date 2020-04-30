extends Node

var is_host = false
var net_nodes = {}
var id_counter = 0

onready var steam_controller = $"/root/SteamController"

onready var spawnable = {
	'player': preload("res://characters/player/player.tscn"),
	'bullet': preload("res://weapons/ammo/bullet.tscn"),
}

func _ready():
	pass


func _physics_process(delta):
#	if is_host:
#		pass
#	else:
	_process_packet_update(steam_controller._read_P2P_Packet())


func _process_packet_update(data):
	if data != null and data.has('directive'):
		
		if data['directive'] == 'position':
			_do_position_directive(data)
			
		elif data['directive'] == 'spawn':
			print('spawning object')
			_do_spawn_directive(data)
			
		elif data['directive'] == 'game_started':
			print('received signal to start game')
			_do_start_directive(data)

func add_networked_node(node):
	net_nodes[node.net_id] = node

func send_spawn(type, transform, net_id, params):
	var d = {
		'directive': 'spawn',
		'type': type,
		'net_id': net_id,
		'transform': transform,
		'params': params
	}
	send_json(d, 2, 0)

func send_position(node):
	var d = {
		'directive': 'position',
		'net_id': node.net_id,
		'position': node.get_pos(),
		'rotation': node.get_rotation()
	}
	send_json(d, 1, 0)
	
func send_started(params={}):
	# sends a signal to players when the game starts
	var d = {
		'directive': 'game_started',
		'params': params,
	}
	send_json(d, 2, 0)
	
func _do_position_directive(data):
	if net_nodes.has(data['net_id']):
		net_nodes[data['net_id']].set_rotation(data['rotation'])
		net_nodes[data['net_id']].set_pos(data['position'])
	else:
		print('Warning: tried to move nonexistent net_id ' + str(data['net_id']))

func _do_spawn_directive(data):
	# spawn new object
	var new_player = spawnable[data['type']].instance()
	new_player.set_global_transform(data['transform'])
	new_player.net_id = data['net_id']
	new_player.spawn_params = data['params']
	get_tree().get_root().add_child(new_player)
	# push to networked objects
	add_networked_node(new_player)

func spawn_new_networked(type, transform, params={}):
	# spawn new object
	var new_player = spawnable[type].instance()
	new_player.set_global_transform(transform)
	new_player.net_id = get_new_id()
	new_player.spawn_params = params
	get_tree().get_root().add_child(new_player)
	var network_id = new_player.net_id
	# push to networked objects
	add_networked_node(new_player)
	# send spawn directive to clients
	send_spawn(type, transform, network_id, params)


func _do_start_directive(data):
	# do things on the cliend when the host presses start button
	$'/root/Main/MainMenu'.set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_new_id():
	id_counter = id_counter + 1
	return id_counter


func send_json(data, method, channel):
	var DATA = PoolByteArray()
	DATA.append(256)
	DATA.append_array(var2bytes(data))
	steam_controller._send_P2P_Packet(DATA, method, channel)
