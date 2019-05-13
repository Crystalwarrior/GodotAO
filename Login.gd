extends VBoxContainer

onready var join_box: Control = $JoinBox as Control
onready var name_box: Control = $NameBox as Control
onready var host_button: Control = $HostButton as Control
onready var leave_button: Control = $LeaveButton as Control
onready var ip_enter: LineEdit = $JoinBox/Input as LineEdit
onready var name_enter: LineEdit = $NameBox/Input as LineEdit
onready var playerlist: ItemList = $PlayerList as ItemList

signal change_ip(msg)
signal change_name(msg)

func _on_login():
	join_box.hide()
	name_box.hide()
	host_button.hide()
	leave_button.show()

func _on_logout():
	join_box.show()
	name_box.show()
	host_button.show()
	leave_button.hide()


func _on_IP_text_entered(new_text: String) -> void:
	if not new_text.is_valid_ip_address():
		name_enter.text = "127.0.0.1"
		return
	emit_signal("change_ip", new_text)

func _on_IP_text_changed(new_text: String) -> void:
	if not new_text.is_valid_ip_address():
		return
	emit_signal("change_ip", new_text)

func _on_Name_text_entered(new_text: String) -> void:
	if new_text == "":
		name_enter.text = "User"
		return
	emit_signal("change_name", new_text)

func _on_Name_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	emit_signal("change_name", new_text)

func _on_Main_clients_changed(array):
	playerlist.clear()
	for client in array:
		playerlist.add_item(client)
