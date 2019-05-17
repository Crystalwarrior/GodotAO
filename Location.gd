extends VBoxContainer

onready var background_button: OptionButton = $BackgroundBox/BackgroundButton as OptionButton
onready var position_button: OptionButton = $PositionBox/PositionButton as OptionButton

signal set_background(bg_idx)
signal set_position(pos_idx)

var list: = []

func _ready():
	for bg in backgrounds.list:
		background_button.add_item(bg["name"])
	update_positions()

func update_positions():
	position_button.clear()
	for position in backgrounds.get_bg(background_button.selected)["positions"]:
		print(position)
		position_button.add_item(position["name"])

func _on_BackgroundButton_item_selected(ID):
	update_positions()
	emit_signal("set_background", ID)
	emit_signal("set_position", 0)

func _on_PositionButton_item_selected(ID):
	emit_signal("set_position", ID)
