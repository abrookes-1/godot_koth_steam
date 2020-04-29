extends Node

var is_host = false
var net_nodes = []

onready var steam_controller = $"/root/SteamController"



func _ready():
	pass


func _physics_process(delta):
	if is_host:
		print("host")
		#_process_client_updates()
		#_send_updates()
		pass
	else:
		_process_server_updates()
		print("member")
		

func _process_client_updates():
	# get updates from all clients
	pass

func _process_server_updates():
	# get updates from server
	var p = steam_controller._read_P2P_Packet()
	if p:
		print(p)


func net_node_spawn(Node):
	pass

func net_node_update(Node):
	pass

func initialize_client():
	pass

func add_networked_node(node):
	net_nodes.append(node)

func send_state(node):
	var DATA = PoolByteArray()
	DATA.append(256)
	DATA.append_array(var2bytes({"title":"This is a test packet", "player_id":SteamController.STEAM_ID, "player_hp":"5", "player_coord":"56,40"}))
	steam_controller._send_P2P_Packet(DATA, 2, 0)
	

