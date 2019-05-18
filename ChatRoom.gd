extends Control

var my_name = "User"
var clients = {}
var character_index = 0
var current_emote = 0
var current_bg = 0
var current_pos = 0
var additive_text = false
var last_speaker = -1

signal ooc_message(msg)
signal ic_name(nick)
signal ic_message(msg, color, additive)
signal ic_logs(msg)
signal ic_character(resource, stretch)
signal ic_background(resource)
signal clients_changed(array)
signal character_changed(character)
signal play_song(song)

func _ready():
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	#network.connect(
	emit_signal("character_changed", characters.get_char(character_index))

	if not get_tree().is_network_server():
		var id = get_tree().get_network_unique_id()
		rpc_id(1, "user_auth", id, network.my_name)

func _server_disconnected():
	emit_signal("ooc_message", "[b]Disconnected from Server[/b]")
	leave_room()

remote func user_auth(id, name):
	clients[id] = name
	if get_tree().is_network_server():
		for client in clients:
			rpc_id(client, "user_auth", id, name)
	emit_signal("ooc_message", "[b]" + name + " joined the room[/b]")
	emit_signal("clients_changed", clients.values())

func user_exited(id):
	if clients.has(id):
		emit_signal("ooc_message", "[b]" + clients[id] + " left the room[/b]")
		clients.erase(id)
	emit_signal("clients_changed", clients.values())

func leave_room():
	get_tree().set_network_peer(null)
	clients.clear()
	emit_signal("clients_changed", clients)
	emit_signal("ooc_message", "[b]Left Room[/b]")

func send_ooc_message(msg):
	if not get_tree().is_network_server():
		rpc_id(1, "receive_ooc_message", msg)
	else:
		msg = "[color=aqua][b]SERVER[/b][/color]: %s" % text_parser.strip_bbcode(msg)
		for client in clients:
			rpc_id(client, "receive_ooc_message", msg)
		emit_signal("ooc_message", msg)

remote func receive_ooc_message(msg):
	if get_tree().is_network_server():
		msg = "[b]%s[/b]: %s" % [clients[get_tree().get_rpc_sender_id()], text_parser.strip_bbcode(msg)]
		for client in clients:
			rpc_id(client, "receive_ooc_message", msg)
	emit_signal("ooc_message", msg)

func send_ic_message(msg, color: Color = ColorN("white")):
	if msg == "": #Don't send blank messages ya doofus.
		return
	var id = get_tree().get_network_unique_id()
	if not get_tree().is_network_server():
		rpc_id(1, "receive_ic_message", id, msg, color, characters.get_char(character_index)["name"],
			 current_emote, backgrounds.get_bg(current_bg)["name"], current_pos, additive_text)
	else:
		receive_ic_message(1, msg, color, characters.get_char(character_index)["name"],
			 current_emote, backgrounds.get_bg(current_bg)["name"], current_pos, additive_text)

remote func receive_ic_message(id, msg, color, charname, emote_index, bg_name, pos_idx, additive):
	if get_tree().is_network_server():
		#do various checks on the vars provided and adjust as needed
		#example: don't send ic messages to people that aren't in the same location as the speaker
#		id = get_tree().get_rpc_sender_id() #double-check so you can't pose as anyone if you look under the hood
		for client in clients:
			rpc_id(client, "receive_ic_message", id, msg, color, charname, emote_index, bg_name, pos_idx, additive)

	var ooc_name = "Null"
	if id != 1:
		ooc_name = clients[id]
	else:
		ooc_name = "[color=aqua]SERVER[/color]"

	if id != last_speaker:
		additive = false
	last_speaker = id
	emit_signal("ic_message", msg, color, additive)
	
	var showname = "Missingchar"
	var char_idx = characters.get_char_index(charname)
	if char_idx != -1:
		var character = characters.get_char(char_idx)
		showname = character["name"]
		var emote = characters.get_char_emote(char_idx, emote_index)
		if emote:
			emit_signal("ic_character", emote["file"], emote["stretch"])
		else:
			emit_signal("ic_character", characters.missing, false)

	emit_signal("ic_name", showname)
	emit_signal("ic_logs", "[b]%s (%s)[/b]: %s" % [showname, ooc_name, text_parser.parse_markup(msg)])

	var pos = backgrounds.get_bg_pos(backgrounds.get_bg_index(bg_name), pos_idx)
	if pos:
		emit_signal("ic_background", pos["file"])
	else:
		emit_signal("ic_background", backgrounds.missing)

func _on_LeaveButton_button_up():
	leave_room()

func _on_character_changed(idx):
	current_emote = 0
	character_index = idx
	emit_signal("character_changed", characters.get_char(idx))

func _on_emote_selected(index):
	current_emote = index

func _on_song_selected(song):
	if not get_tree().is_network_server():
		rpc_id(1, "receive_song", song)
	else:
		receive_song(song)

remote func receive_song(song):
	if get_tree().is_network_server():
		for client in clients:
			rpc_id(client, "receive_song", song)
	emit_signal("play_song", song) #send song signal on server too

func _on_Location_set_position(pos_idx):
	current_pos = pos_idx

func _on_Location_set_background(bg_idx):
	current_bg = bg_idx

func _on_Options_additive_text(toggle):
	additive_text = toggle
