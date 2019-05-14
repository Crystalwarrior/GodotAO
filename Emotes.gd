extends ItemList

var emotes = []
signal emote_selected(index)

func _ready():
	pass

func generate_buttons():
	clear()
	for emote in emotes:
		add_item(emote["name"], emote["file"])

func _on_Main_character_changed(character, emo):
	emotes = emo
	generate_buttons()

func _on_item_selected(index):
	emit_signal("emote_selected", index)
