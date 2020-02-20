extends Control

var my_name = "User"
var clients = {}
var character_index = 0
var current_emote = 0
var current_bg = 0
var current_pos = 0
var additive_text = false
var play_pre = false
var flipit = false
var no_interrupt = false
var last_speaker = -1

signal ooc_message(msg)
signal ic_name(nick)
signal ic_message(msg, color, additive)
signal ic_logs(msg)
signal ic_character(character, resource, stretch)
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
	set_location(-1, 0)
	if get_tree().is_network_server():
		for client in clients:
			rpc_id(client, "user_auth", id, name)
		rpc_id(id, "get_client_list", clients)
#	emit_signal("ooc_message", "[b]" + name + " joined the room[/b]")
	emit_signal("clients_changed", clients.values())

remote func get_client_list(list):
	if not get_tree().is_network_server():
		clients = list
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
			 current_emote, current_bg, current_pos, additive_text, play_pre, flipit, no_interrupt)
	else:
		receive_ic_message(1, msg, color, characters.get_char(character_index)["name"],
			 current_emote, current_bg, current_pos, additive_text, play_pre, flipit, no_interrupt)

remote func receive_ic_message(id, msg, color, charname, emote_index, bg_idx, pos_idx, additive, pre, flip, interrupt):
	if get_tree().is_network_server():
		#do various checks on the vars provided and adjust as needed
		#example: don't send ic messages to people that aren't in the same location as the speaker
		if id != 1:
			id = get_tree().get_rpc_sender_id() #double-check
			bg_idx = 0
			for i in backgrounds.list.size():
				var bg = backgrounds.list[i]
				if bg["clients"].has(id):
					bg_idx = i
					break
		for client in backgrounds.get_bg(bg_idx)["clients"]:
			rpc_id(client, "receive_ic_message", id, msg, color, charname, emote_index, bg_idx, pos_idx, additive, pre, flip, interrupt)

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
		var flap = null
		var blink = null
		var pre_data = null
		
		if emote.has("flap"):
			flap = characters.get_char_flap(char_idx, emote["flap"])
		if emote.has("blink"):
			blink = characters.get_char_blink(char_idx, emote["blink"])
		if emote.has("pre"):
			pre_data = characters.get_char_pre(char_idx, emote["pre"])

		if emote:
			emit_signal("ic_character", emote, flap, blink, pre_data, pre, flip, interrupt)
		else:
			emit_signal("ic_character", characters.missing, null, null, null, false, false, false)

	emit_signal("ic_name", showname)
	emit_signal("ic_logs", "[b]%s (%s)[/b]: %s" % [showname, ooc_name, text_parser.parse_markup(msg)])

	var pos = backgrounds.get_bg_pos(bg_idx, pos_idx)
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

remote func set_location(bg_from, bg_to):
	if get_tree().is_network_server():
		var id = get_tree().get_rpc_sender_id()
		print(id)
		if id != 1:
			if bg_from != -1:
				backgrounds.get_bg(bg_from)["clients"].erase(id)
			if bg_to != -1:
				backgrounds.get_bg(bg_to)["clients"].append(id)
	current_bg = bg_to

func _on_Location_set_background(bg_idx):
	if not get_tree().is_network_server():
		rpc_id(1, "set_location", current_bg, bg_idx)
	else:
		set_location(current_bg, bg_idx)

func _on_Options_additive_text(toggle):
	additive_text = toggle

func _on_Options_pre_animation(toggle):
	play_pre = toggle

func _on_Options_flip(toggle):
	flipit = toggle

func _on_Options_no_interrupt(toggle):
	no_interrupt = toggle
