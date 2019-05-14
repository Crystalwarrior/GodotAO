extends Control

const PORT = 25565
const MAX_USERS = 16 #not including host

var my_ip = "127.0.0.1"
var my_name = "User"
var clients = {}
var characters = ["Female Student 1", "Female Student 2"]
var character = "Female Student 1"
var current_emote = 0

var emotes = {
	"Female Student 1":
		[
		{"name": "blush", "file": preload("res://res/sprites/characters/Female Student 1/blush.png")},
		{"name": "happy", "file": preload("res://res/sprites/characters/Female Student 1/happy.png")},
		{"name": "sad", "file": preload("res://res/sprites/characters/Female Student 1/sad.png")},
		{"name": "surprised", "file": preload("res://res/sprites/characters/Female Student 1/surprised.png")},
		{"name": "upset", "file": preload("res://res/sprites/characters/Female Student 1/upset.png")},
		],
	"Female Student 2":
		[
		{"name": "blush", "file": preload("res://res/sprites/characters/Female Student 2/blush.png")},
		{"name": "happy", "file": preload("res://res/sprites/characters/Female Student 2/happy.png")},
		{"name": "sad", "file": preload("res://res/sprites/characters/Female Student 2/sad.png")},
		{"name": "surprised", "file": preload("res://res/sprites/characters/Female Student 2/surprised.png")},
		{"name": "upset", "file": preload("res://res/sprites/characters/Female Student 2/upset.png")}
		],
}

signal ooc_message(msg)
signal ic_name(nick)
signal ic_message(msg)
signal ic_logs(msg)
signal ic_character(resource)
signal login()
signal logout()
signal clients_changed(array)
signal character_changed(character, emotes)

func _ready():
	get_tree().connect("connected_to_server", self, "enter_room")
#	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	emit_signal("character_changed", character, emotes[character])

func _server_disconnected():
	emit_signal("ooc_message", "[b]Disconnected from Server[/b]")
	leave_room()

sync func user_auth(id, name):
	emit_signal("ooc_message", "[b]" + name + " joined the room[/b]")
	if not get_tree().is_network_server():
		return
	clients[id] = name
	rpc("receive_client_list", clients)
	emit_signal("clients_changed", clients.values())

remote func receive_client_list(dict):
	clients = dict
	emit_signal("clients_changed", clients.values())

func user_exited(id):
	if clients.has(id):
		emit_signal("ooc_message", "[b]" + clients[id] + " left the room[/b]")
		clients.erase(id)

func host_room():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_USERS)
	get_tree().set_network_peer(host)
	enter_room()
	emit_signal("ooc_message", "[u][b]Room Created[/b][/u]")

func join_room():
	var host = NetworkedMultiplayerENet.new()
	host.create_client(my_ip, PORT)
	get_tree().set_network_peer(host)

func enter_room():
	emit_signal("ooc_message", "[b]Successfully joined room[/b]")
	emit_signal("login")
	var id = get_tree().get_network_unique_id()
	rpc("user_auth", id, my_name)

func leave_room():
	get_tree().set_network_peer(null)
	emit_signal("ooc_message", "[b]Left Room[/b]")
	emit_signal("logout")

func send_ooc_message(msg):
	var id = get_tree().get_network_unique_id()
	rpc("receive_ooc_message", id, msg)

func send_ic_message(msg):
	var id = get_tree().get_network_unique_id()
	rpc("receive_ic_message", id, msg, character, current_emote)

sync func receive_ooc_message(id, msg):
	emit_signal("ooc_message", "[b]" + clients[id] + "[/b]: " + text_parser.parse_markup(msg))

sync func receive_ic_message(id, msg, chara, emote_index):
	emit_signal("ic_name", clients[id])
	msg = text_parser.parse_markup(msg)
	emit_signal("ic_message", msg)
	emit_signal("ic_logs", "[b]" + clients[id] + "[/b]: " + msg)
	emit_signal("ic_character", emotes[chara][emote_index]["file"])

func _on_JoinButton_button_up():
	join_room()

func _on_LeaveButton_button_up():
	leave_room()

func _on_HostButton_button_up():
	host_room()

func _on_Login_change_ip(msg):
	my_ip = msg

func _on_Login_change_name(msg):
	my_name = msg

func _on_character_changed(chara):
	current_emote = 0
	character = chara
	emit_signal("character_changed", character, emotes[character])

func _on_emote_selected(index):
	current_emote = index