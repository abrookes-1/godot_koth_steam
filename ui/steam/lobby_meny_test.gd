#extends MarginContainer
#
#var smeg = load("../ui/steam/steam_multiplayer_manage.gd")
#var STEAM_LOBBY_ID = 0
#var LOBBY_INVITE_ARG = false
#var LOBBY_MEMBERS = []
#var STEAM_ID = 76561198164523231
#
#func _ready():
#
#	var INIT = Steam.steamInit()
#	#var STEAM_ID = Steam.getSteamID()
#	Steam.connect("lobby_created", self, "_on_Lobby_Created")
#	Steam.connect("lobby_match_list", self, "_on_Lobby_Match_List")
#	Steam.connect("lobby_joined", self, "_on_Lobby_Joined")
#	Steam.connect("lobby_chat_update", self, "_on_Lobby_Chat_Update")
#	Steam.connect("lobby_message", self, "_on_Lobby_Message")
#	Steam.connect("lobby_data_update", self, "_on_Lobby_Data_Update")
#	Steam.connect("lobby_invite", self, "_on_Lobby_Invite")
#	Steam.connect("join_requested", self, "_on_Lobby_Join_Requested")
#	Steam.connect("p2p_session_request", self, "_on_P2P_Session_Request")
#	Steam.connect("p2p_session_connect_fail", self, "_on_P2P_Session_Connect_Fail")
#	# Check for command line arguments
#	_check_Command_Line()
#
##func _on_Host_pressed():
##	_create_Lobby()
###	_on_Lobby_Created(1,76561198164523231)
##	pass
#
#func _create_Lobby():
#
#	# Make sure a lobby is not already set
#	if STEAM_LOBBY_ID == 0:
#		Steam.createLobby(2, 2)
#
#func _on_Lobby_Created(connect, lobbyID):
#	print("reeeee")
#
#	if connect == 1:
#
#		# Set the lobby ID
#		STEAM_LOBBY_ID = lobbyID
#		print("Created a lobby: "+str(STEAM_LOBBY_ID))
#
#		# Set some lobby data
#		Steam.setLobbyData(lobbyID, "name", "Gramps' Lobby")
#		Steam.setLobbyData(lobbyID, "mode", "GodotSteam test")
#
#		# Allow P2P connections to fallback to being relayed through Steam if needed
#		var RELAY = Steam.allowP2PPacketRelay(true)
#		print("Allowing Steam to be relay backup: "+str(RELAY))
#	else:
#		print("error")
#
#func _check_Command_Line():
#	var ARGUMENTS = OS.get_cmdline_args()
#
#	# There are arguments to process
#	if ARGUMENTS.size() > 0:
#
#		# Loop through them and get the useful ones
#		for ARGUMENT in ARGUMENTS:
#			print("Command line: "+str(ARGUMENT))
#
#			# An invite argument was passed
#			if LOBBY_INVITE_ARG:
#				_join_Lobby(int(ARGUMENT))
#
#			# A Steam connection argument exists
#			if ARGUMENT == "+connect_lobby":
#				LOBBY_INVITE_ARG = true
#
#func _join_Lobby(lobbyID):
#	print("Attempting to join lobby "+str(lobbyID)+"...")
#
#	# Clear any previous lobby members lists, if you were in a previous lobby
#	LOBBY_MEMBERS.clear()
#
#	# Make the lobby join request to Steam
#	Steam.joinLobby(lobbyID)
#
#func _get_Lobby_Members():
#
#	# Clear your previous lobby list
#	LOBBY_MEMBERS.clear()
#
#	# Get the number of members from this lobby from Steam
#	var MEMBERS = Steam.getNumLobbyMembers(STEAM_LOBBY_ID)
#
#	# Get the data of these players from Steam
#	for MEMBER in range(0, MEMBERS):
#
#		# Get the member's Steam ID
#		var MEMBER_STEAM_ID = Steam.getLobbyMemberByIndex(STEAM_LOBBY_ID, MEMBER)
#
#		# Get the member's Steam name
#		var MEMBER_STEAM_NAME = Steam.getFriendPersonaName(MEMBER_STEAM_ID)
#
#		# Add them to the list
##		LOBBY_MEMBERS.append({"steam_id":steam_id, "steam_name":steam_name})
