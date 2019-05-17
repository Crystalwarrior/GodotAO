extends Node

const PORT = 25565
const MAX_USERS = 16 #not including host

var my_ip = "127.0.0.1"
var my_name = "User"

func _ready():
#	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	#Client
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _host_room():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT, MAX_USERS)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	get_tree().change_scene("res://ChatRoom.tscn")

func _join_room():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(my_ip, PORT)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)

func _connected_to_server(): #success
	get_tree().change_scene("res://ChatRoom.tscn")

func _on_Login_change_ip(msg):
	my_ip = msg

func _on_Login_change_name(msg):
	my_name = msg