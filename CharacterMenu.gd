extends MenuButton

var popup

signal character_changed(character)

func _ready():
	popup = get_popup()
	popup.add_icon_item(preload("res://res/sprites/characters/Female Student 1/icon.png"), "Female Student 1")
	popup.add_icon_item(preload("res://res/sprites/characters/Female Student 2/icon.png"), "Female Student 2")
	popup.connect("id_pressed", self, "_on_item_pressed")

func _on_item_pressed(ID):
	emit_signal("character_changed", popup.get_item_text(ID))