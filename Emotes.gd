extends ItemList

var emotes = []
signal emote_selected(index)
signal toggle_pre()
signal off_pre()

func _ready():
	pass

func generate_buttons():
	clear()
	for emote in emotes:
		add_item(emote["name"], emote["icon"])

func _on_Main_character_changed(character):
	emotes = character["emotes"]
	generate_buttons()

func _on_item_selected(index):
	emit_signal("emote_selected", index)
	if emotes[index].has("pre") == true:
		emit_signal("toggle_pre")
	else:
		emit_signal("off_pre")
