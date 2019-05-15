extends MenuButton

var popup

signal character_changed(character)

func _ready():
	popup = get_popup()
	for charname in characters.names:
		popup.add_item(charname)
		popup.connect("id_pressed", self, "_on_item_pressed")

func _on_item_pressed(ID):
	emit_signal("character_changed", popup.get_item_text(ID))