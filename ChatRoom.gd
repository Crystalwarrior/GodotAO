extends Control

const PORT = 25565
const MAX_USERS = 16 #not including host

onready var chat_display = $PanelContainer/MainWindow/HSplit/VSplit/Info2/OOC/Text
onready var chat_input = $PanelContainer/MainWindow/HSplit/VSplit/Info2/OOC/Input

onready var say_box = $PanelContainer/MainWindow/HSplit/View/IC/Say/Box
onready var say_display = $PanelContainer/MainWindow/HSplit/View/IC/Say/Box/Display/Text
onready var say_name = $PanelContainer/MainWindow/HSplit/View/IC/Say/Box/Name/Text
onready var say_input = $PanelContainer/MainWindow/HSplit/View/IC/Say/Input

onready var say_logs = $PanelContainer/MainWindow/HSplit/VSplit/Info/Logs/Text

onready var login = $PanelContainer/MainWindow/HSplit/VSplit/Info/Login

var my_name = ""
var clients = {}

func _ready():
	get_tree().connect("connected_to_server", self, "enter_room")
#	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _server_disconnected():
	chat_display.bbcode_text += "[b]Disconnected from Server[/b]\n"
	leave_room()

#func user_entered(id):


sync func user_auth(id, name):
	clients[id] = name
	chat_display.bbcode_text += "[b]" + clients[id] + " joined the room[/b]\n"
	if not get_tree().is_network_server():
		return
	rpc_id(id, "receive_client_list", clients)

remote func receive_client_list(array):
	clients = array

func user_exited(id):
	chat_display.bbcode_text += "[b]" + clients[id] + " left the room[/b]\n"
	clients.erase(id)

func host_room():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_USERS)
	get_tree().set_network_peer(host)
	enter_room()
	chat_display.bbcode_text = "[u][b]Room Created[/b][/u]\n"

func join_room():
	var ip = login.get_node("JoinBox/IPEnter").text
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)

func enter_room():
	chat_display.bbcode_text = "[b]Successfully joined room[/b]\n"
	login.get_node("LeaveButton").show()
	login.get_node("HostButton").hide()
	login.get_node("JoinBox").hide()
	login.get_node("NameBox").hide()
	var id = get_tree().get_network_unique_id()
	rpc("user_auth", id, login.get_node("NameBox/Input").text)

func leave_room():
	get_tree().set_network_peer(null)
	chat_display.bbcode_text += "[b]Left Room[/b]\n"
	
	login.get_node("LeaveButton").hide()
	login.get_node("HostButton").show()
	login.get_node("JoinBox").show()
	login.get_node("NameBox").show()

func send_message(msg):
	chat_input.text = ""
	var id = get_tree().get_network_unique_id()
	rpc("receive_message", id, msg)

func send_ic_message(msg):
	say_input.text = ""
	var id = get_tree().get_network_unique_id()
	rpc("receive_ic_message", id, msg)

sync func receive_message(id, msg):
	chat_display.bbcode_text += "[b]" + clients[id] + "[/b]: " + msg + "\n"

sync func receive_ic_message(id, msg):
	if msg == "":
		say_box.hide()
	else:
		say_box.show()
	say_name.text = clients[id]
	say_display.bbcode_text = msg
	say_logs.bbcode_text += "[b]" + clients[id] + "[/b]: " + msg + "\n"

func _on_JoinButton_button_up():
	join_room()

func _on_LeaveButton_button_up():
	leave_room()

func _on_HostButton_button_up():
	host_room()

func _on_ChatInput_text_entered(new_text):
	send_message(new_text)

func _on_SayInput_text_entered(new_text):
	send_ic_message(new_text)
