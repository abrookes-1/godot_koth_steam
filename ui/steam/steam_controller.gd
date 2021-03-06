extends Node

# Steam variables
var OWNED = false
var ONLINE = false
var STEAM_ID
var STEAM_USERNAME = ""
var STEAM_LOBBY_ID = 0
var LOBBY_MEMBERS = []
var DATA
var LOBBY_INVITE_ARG = false
var packets_read = 0
var packets_sent = 0
var MEMBERS

onready var network_manager = $"/root/NetworkManager"

func _ready():
	# connect buttons
	#var create_lobby_button = $"../MainMenu/EdgeScreenPadding/TabContainer/Game/GraphicsList/Host/Host"
	#create_lobby_button.connect("pressed", self, "_create_Lobby")
	print("connected-------")
	
	Steam.connect("lobby_created", self, "_on_Lobby_Created")
	Steam.connect("lobby_match_list", self, "_on_Lobby_Match_List")
	Steam.connect("lobby_joined", self, "_on_Lobby_Joined")
	Steam.connect("lobby_chat_update", self, "_on_Lobby_Chat_Update")
	Steam.connect("lobby_message", self, "_on_Lobby_Message")
	Steam.connect("lobby_data_update", self, "_on_Lobby_Data_Update")
	Steam.connect("lobby_invite", self, "_on_Lobby_Invite")
	Steam.connect("join_requested", self, "_on_Lobby_Join_Requested")
	Steam.connect("p2p_session_request", self, "_on_P2P_Session_Request")
	Steam.connect("p2p_session_connect_fail", self, "_on_P2P_Session_Connect_Fail")
	#Check for command line arguments
	_check_Command_Line()

	var INIT = Steam.steamInit()
	print("Did Steam initialize?: "+str(INIT))
	
	if INIT['status'] != 1:
		print("Failed to initialize Steam. "+str(INIT['verbal'])+" Shutting down...")
		get_tree().quit()
	
	ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	OWNED = Steam.isSubscribed()

func _process(delta):
		#_read_P2P_Packet()
	Steam.run_callbacks()

func _on_Host_pressed():
	#creates a lobby when you press the host button
	_create_Lobby()

func _check_Command_Line():
	var ARGUMENTS = OS.get_cmdline_args()

	# There are arguments to process
	if ARGUMENTS.size() > 0:

		# Loop through them and get the useful ones
		for ARGUMENT in ARGUMENTS:
			print("Command line: "+str(ARGUMENT))

			# An invite argument was passed
			if LOBBY_INVITE_ARG:
				_join_Lobby(int(ARGUMENT))

			# A Steam connection argument exists
			if ARGUMENT == "+connect_lobby":
				LOBBY_INVITE_ARG = true

func _create_Lobby():
	# Make sure a lobby is not already set
	if STEAM_LOBBY_ID == 0:
		# (lobby type, max players)
		Steam.createLobby(2, 5)

func _on_Lobby_Created(connect, lobbyID):
	NetworkManager.is_host = true
	
	if connect == 1:
		# Set the lobby ID
		STEAM_LOBBY_ID = lobbyID
		print("Created a lobby: "+str(STEAM_LOBBY_ID))

		# Set some lobby data
		Steam.setLobbyData(lobbyID, "name", "Gramps' Lobby")
		Steam.setLobbyData(lobbyID, "mode", "GodotSteam test")

		# Allow P2P connections to fallback to being relayed through Steam if needed
		var RELAY = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: "+str(RELAY))

func _on_Open_Lobby_List_pressed():
	# Set distance to worldwide
	Steam.addRequestLobbyListDistanceFilter(3)

	print("Requesting a lobby list")
	Steam.requestLobbyList()

func _on_Lobby_Match_List(lobbies):
	for LOBBY in lobbies:

		# Pull lobby data from Steam, these are specific to our example
		var LOBBY_NAME = Steam.getLobbyData(LOBBY, "name")
		var LOBBY_MODE = Steam.getLobbyData(LOBBY, "mode")

		# Get the current number of members
		var LOBBY_MEMBERS = Steam.getNumLobbyMembers(LOBBY)

		# Create a button for the lobby
		var LOBBY_BUTTON = Button.new()
		LOBBY_BUTTON.set_text("Lobby "+str(LOBBY)+": "+str(LOBBY_NAME)+" ["+str(LOBBY_MODE)+"] - "+str(LOBBY_MEMBERS)+" Player(s)")
		LOBBY_BUTTON.set_size(Vector2(800, 50))
		LOBBY_BUTTON.set_name("lobby_"+str(LOBBY))
		LOBBY_BUTTON.connect("pressed", self, "_join_Lobby", [LOBBY])

		# Add the new lobby to the list
		$"LobbyList".add_child(LOBBY_BUTTON)

func _join_Lobby(lobbyID):
	print("Attempting to join lobby "+str(lobbyID)+"...")
	
	# Clear any previous lobby members lists, if you were in a previous lobby
	LOBBY_MEMBERS.clear()

	# Make the lobby join request to Steam
	Steam.joinLobby(lobbyID)

func _on_Lobby_Joined(lobbyID, permissions, locked, response):
	# Set this lobby ID as your lobby ID
	STEAM_LOBBY_ID = lobbyID
	
	# Get the lobby members
	_get_Lobby_Members()
	
	# Make the initial handshake
	_make_P2P_Handshake()

func _on_Lobby_Join_Requested(lobbyID, friendID):
	
	# Get the lobby owner's name
	var OWNER_NAME = Steam.getFriendPersonaName(friendID)
	print("Joining "+str(OWNER_NAME)+"'s lobby...")
	
	# Attempt to join the lobby
	_join_Lobby(lobbyID)

func _get_Lobby_Members():

	# Clear your previous lobby list
	LOBBY_MEMBERS.clear()

	# Get the number of members from this lobby from Steam
	MEMBERS = Steam.getNumLobbyMembers(STEAM_LOBBY_ID)


	# Get the data of these players from Steam
	for MEMBER in range(0, MEMBERS):

		# Get the member's Steam ID
		var MEMBER_STEAM_ID = Steam.getLobbyMemberByIndex(STEAM_LOBBY_ID, MEMBER)

		# Get the member's Steam name
		var MEMBER_STEAM_NAME = Steam.getFriendPersonaName(MEMBER_STEAM_ID)

		# Add them to the list
		LOBBY_MEMBERS.append({"steam_id":MEMBER_STEAM_ID, "steam_name":MEMBER_STEAM_NAME})

func _make_P2P_Handshake():

	print("Sending P2P handshake to the lobby")
	var DATA = PoolByteArray()
	DATA.append(256)
	DATA.append_array(var2bytes({"message":"handshake", "from":STEAM_ID}))
	_send_P2P_Packet(DATA, 2, 0)

func _on_Lobby_Chat_Update(lobbyID, changedID, makingChangeID, chatState):

	# Get the user who has made the lobby change
	var CHANGER = Steam.getFriendPersonaName(makingChangeID)

	# If a player has joined the lobby
	if chatState == 1:
		print(str(CHANGER)+" has joined the lobby.")

	# Else if a player has left the lobby
	elif chatState == 2:
		print(str(CHANGER)+" has left the lobby.")

	# Else if a player has been kicked
	elif chatState == 8:
		print(str(CHANGER)+" has been kicked from the lobby.")

	# Else if a player has been banned
	elif chatState == 16:
		print(str(CHANGER)+" has been banned from the lobby.")

	# Else there was some unknown change
	else:
		print(str(CHANGER)+" did... something.")

	# Update the lobby now that a change has occurred
	_get_Lobby_Members()
	#print(LOBBY_MEMBERS)

func _on_Send_Chat_pressed():

	# Get the entered chat message
	var MESSAGE = $Chat.get_text()

	# Pass the message to Steam
	var SENT = Steam.sendLobbyChatMsg(STEAM_LOBBY_ID, MESSAGE)

	# Was it sent successfully?
	if not SENT:
		print("ERROR: Chat message failed to send.")

	# Clear the chat input
	$Chat.clear()

func _leave_Lobby():

	# If in a lobby, leave it

	if STEAM_LOBBY_ID != 0:

		# Send leave request to Steam
		Steam.leaveLobby(STEAM_LOBBY_ID)

		# Wipe the Steam lobby ID then display the default lobby ID and player list title
		STEAM_LOBBY_ID = 0

		# Close session with all users
		for MEMBERS in LOBBY_MEMBERS:
			Steam.closeP2PSessionWithUser(MEMBERS['steam_id'])
		
		# Clear the local lobby list
		LOBBY_MEMBERS.clear()

func _on_P2P_Session_Request(remoteID):
	
	# Get the requester's name
	var REQUESTER = Steam.getFriendPersonaName(remoteID)
	
	# Accept the P2P session; can apply logic to deny this request if needed
	Steam.acceptP2PSessionWithUser(remoteID)
	
	# Make the initial handshake
	_make_P2P_Handshake()

func _read_P2P_Packet():

	var PACKET_SIZE = Steam.getAvailableP2PPacketSize(0)

	# There is a packet
	if PACKET_SIZE > 0:

		var PACKET = Steam.readP2PPacket(PACKET_SIZE, 0)

		if PACKET.empty() or PACKET.data.empty():
			print("WARNING: read an empty packet with non-zero size!")


		# Get the remote user's ID
		var PACKET_ID = str(PACKET.steamIDRemote)
		var PACKET_CODE = str(PACKET.data[0])


		# Make the packet data readable
		var READABLE = bytes2var(PACKET.data.subarray(1, PACKET_SIZE - 1))

		# Print the packet to output
		#print("Packet: "+str(READABLE))
		packets_read += 1
		print("packets read" + str(packets_read))
		return READABLE # Append logic here to deal with packet data
		


func _send_P2P_Packet(data, send_type, channel):
	
	# If there is more than one user, send packets
	if LOBBY_MEMBERS.size() > 1:
	
		# Loop through all members that aren't you
		for MEMBER in LOBBY_MEMBERS:
			if MEMBER['steam_id'] != STEAM_ID:
				
				packets_sent += 1
				print("packets sent" + str(packets_sent))
				Steam.sendP2PPacket(MEMBER['steam_id'], data, send_type, channel)

func _on_P2P_Session_Connect_Fail(lobbyID, session_error):

	# If no error was given
	if session_error == 0:
		print("WARNING: Session failure with "+str(lobbyID)+" [no error given].")

	# Else if target user was not running the same game
	elif session_error == 1:
		print("WARNING: Session failure with "+str(lobbyID)+" [target user not running the same game].")

	# Else if local user doesn't own app / game
	elif session_error == 2:
		print("WARNING: Session failure with "+str(lobbyID)+" [local user doesn't own app / game].")

	# Else if target user isn't connected to Steam
	elif session_error == 3:
		print("WARNING: Session failure with "+str(lobbyID)+" [target user isn't connected to Steam].")

	# Else if connection timed out
	elif session_error == 4:
		print("WARNING: Session failure with "+str(lobbyID)+" [connection timed out].")

	# Else if unused
	elif session_error == 5:
		print("WARNING: Session failure with "+str(lobbyID)+" [unused].")

	# Else no known error
	else:
		print("WARNING: Session failure with "+str(lobbyID)+" [unknown error "+str(session_error)+"].")

func _on_Lobby_Data_Update(success, lobbyID, memberID, key):
	print("Success: "+str(success)+", Lobby ID: "+str(lobbyID)+", Member ID: "+str(memberID)+", Key: "+str(key))





