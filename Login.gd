extends VBoxContainer

onready var name_enter: LineEdit = $NameBox/NameEntry as LineEdit
onready var ip_enter: LineEdit = $JoinBox/IPEntry as LineEdit

func _on_NameEntry_text_entered(new_text: String) -> void:
	if new_text == "":
		name_enter.text = "User"
		return
	network.my_name = new_text

func _on_NameEntry_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	network.my_name = new_text

func _on_IPEntry_text_changed(new_text: String) -> void:
	if not new_text.is_valid_ip_address():
		return
	network.my_ip = new_text

func _on_IPEntry_text_entered(new_text: String) -> void:
	if not new_text.is_valid_ip_address():
		ip_enter.text = "127.0.0.1"
		return
	network.my_ip = new_text

func _on_HostButton_pressed():
	network._host_room()

func _on_JoinButton_pressed():
	network._join_room()
