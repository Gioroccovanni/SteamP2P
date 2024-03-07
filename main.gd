extends Node
var peer = null

@onready var multiplayer_spawner = $MultiplayerSpawner

var lobby_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer_spawner.spawn_function = spawn_level
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_invite.connect(_on_lobby_invite)
	open_lobby_list()
	
func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func join_lobby(id):
	Steam.joinLobby(id)
	hide_menu()
	
func _on_host_pressed():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC,10)

func _on_lobby_created(connect,id):
	print("connect:",connect)
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id,"name",str(Steam.getPersonaName(),"'s FunHouse"))
		Steam.setLobbyJoinable(lobby_id,true)
		create_socket()
		multiplayer.multiplayer_peer = peer
		multiplayer_spawner.spawn("res://level.tscn")
		hide_menu()
		print("Create lobby id:",str(lobby_id))

func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	
func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		var mem_count = Steam.getNumLobbyMembers(lobby)
		
		var but = Button.new()
		but.set_text(str(lobby_name," ",mem_count))
		but.set_size(Vector2(100,5))
		but.connect("pressed",Callable(self,"join_lobby").bind(lobby))
		
		$ScrollContainer/VBoxContainer.add_child(but)

func _on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	print("joined lobby",str(response))
	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != Steam.getSteamID():
			connect_socket(id)
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			2:  FAIL_REASON = "This lobby no longer exists."
			3:  FAIL_REASON = "You don't have permission to join this lobby."
			4:  FAIL_REASON = "The lobby is now full."
			5:  FAIL_REASON = "Uh... something unexpected happened!"
			6:  FAIL_REASON = "You are banned from this lobby."
			7:  FAIL_REASON = "You cannot join due to having a limited account."
			8:  FAIL_REASON = "This lobby is locked or disabled."
			9:  FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		print(FAIL_REASON)

func create_socket():
	print("test")
	peer = SteamMultiplayerPeer.new()
	peer.create_host(0, [])
	multiplayer.set_multiplayer_peer(peer)


func connect_socket(steam_id : int):
	peer = SteamMultiplayerPeer.new()
	peer.create_client(steam_id, 0, [])
	multiplayer.set_multiplayer_peer(peer)

func _on_lobby_invite(inviter: int, lobby: int, game: int):
	Steam.joinLobby(lobby)
	hide_menu()
	
func _on_refresh_pressed():
	if $ScrollContainer/VBoxContainer.get_child_count() > 0:
		for n in $ScrollContainer/VBoxContainer.get_children():
			n.queue_free()
		open_lobby_list()
		
func hide_menu():
	$Host.hide()
	$ScrollContainer.hide()
	$Refresh.hide()
