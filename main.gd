extends Node

@onready var multiplayer_spawner = $MultiplayerSpawner

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer_spawner.spawn_function = spawn_level
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_lobby_list()
	
func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	$Host.hide()
	$ScrollContainer.hide()
	
func _on_host_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	multiplayer_spawner.spawn("res://level.tscn")
	$Host.hide()
	$ScrollContainer.hide()

func _on_lobby_created(connect,id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id,"name",str(Steam.getPersonaName(),"'s FunHouse"))
		Steam.setLobbyJoinable(lobby_id,true)
		print(str(lobby_id))

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


func _on_refresh_pressed():
	pass # Replace with function body.
