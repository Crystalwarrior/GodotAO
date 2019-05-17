extends VBoxContainer

onready var playerlist: ItemList = $PlayerList as ItemList

func _on_Main_clients_changed(array):
	playerlist.clear()
	for client in array:
		playerlist.add_item(client)