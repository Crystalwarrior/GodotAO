extends HBoxContainer

signal color_changed(color)

onready var option_button: OptionButton = $OptionButton as OptionButton

var colorlist = [{"name": "White", "color": ColorN("white")},
				{"name": "Red", "color": ColorN("red")},
				{"name": "Orange", "color": Color("#ffa500")},
				{"name": "Yellow", "color": ColorN("yellow")},
				{"name": "Green", "color": ColorN("green")},
				{"name": "Blue", "color": Color("#0088ff")},
				{"name": "Aqua", "color": ColorN("aqua")},
				{"name": "Purple", "color": Color("#ff55ff")}]

func _ready():
	var i = 0
	for color in colorlist:
		option_button.add_item(color["name"], i)
		option_button.set_item_metadata(i, color["color"])
		i += 1

func _on_OptionButton_item_selected(ID):
	emit_signal("color_changed", option_button.get_item_metadata(ID))
	print(option_button.get_item_metadata(ID))