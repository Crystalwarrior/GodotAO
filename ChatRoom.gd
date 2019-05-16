extends Control

const PORT = 25565
const MAX_USERS = 16 #not including host

var my_ip = "127.0.0.1"
var my_name = "User"
var clients = {}
var character_index = 0
var current_emote = 0

signal ooc_message(msg)
signal ic_name(nick)
signal ic_message(msg)
signal ic_logs(msg)
signal ic_character(resource)
signal login()
signal logout()
signal clients_changed(array)
signal character_changed(character)
signal play_song(song)

func _ready():
	get_tree().connect("connected_to_server", self, "enter_room")
#	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
#	emit_signal("character_changed", character, characters.emotes[character])

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
	emit_signal("clients_changed", clients.values())

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
	clients.clear()
	emit_signal("clients_changed", clients)
	emit_signal("ooc_message", "[b]Left Room[/b]")
	emit_signal("logout")

func send_ooc_message(msg):
	var id = get_tree().get_network_unique_id()
	rpc("receive_ooc_message", id, msg)

func send_ic_message(msg, color: Color = ColorN("white")):
	if msg == "": #Don't send blank messages ya doofus.
		return
	var id = get_tree().get_network_unique_id()
	rpc("receive_ic_message", id, msg, color, characters.get_char(character_index)["name"], current_emote)

sync func receive_ooc_message(id, msg):
	emit_signal("ooc_message", "[b]" + clients[id] + "[/b]: " + msg)

sync func receive_ic_message(id, msg, color, charname, emote_index):
	emit_signal("ic_name", clients[id])
	emit_signal("ic_message", msg, color)
	emit_signal("ic_logs", "[b]" + clients[id] + "[/b]: " + text_parser.parse_markup(msg))
	var emote = characters.get_char_emote(characters.get_char_index(charname), emote_index)
	if emote:
		emit_signal("ic_character", emote["file"], emote["stretch"])
	else:
		emit_signal("ic_character", characters.missing, false)

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

func _on_character_changed(idx):
	current_emote = 0
	character_index = idx
	emit_signal("character_changed", characters.get_char(idx))

func _on_emote_selected(index):
	current_emote = index

func _on_song_selected(song):
	rpc("receive_song", song)

sync func receive_song(song):
	emit_signal("play_song", song)