extends VBoxContainer

onready var input: LineEdit = $Input as LineEdit
onready var box: Control = $Box as Control
onready var showname: Label = $Box/Name/Text as Label
onready var text: RichTextLabel = $Box/Display/Text as RichTextLabel
onready var blip: AudioStreamPlayer = $Blip as AudioStreamPlayer

signal message_sent(msg, color)

var timer = 0.0
var color: Color = ColorN("white") #Our default typing color

func _on_ic_name(nick: String) -> void:
	showname.text = nick

func _on_ic_message(msg: String, col: Color = ColorN("white")) -> void:
	if msg.empty() or msg == " ":
		box.hide()
	else:
		box.show()
	text.add_color_override("default_color", col)
	text.bbcode_text = text_parser.parse_markup(msg)
	if settings.text_speed != 0: #the fastest it can be
		text.visible_characters = 0
		timer = settings.text_speed
	else:
		text.visible_characters = -1
		blip.play()

func _process(delta):
	if text.visible_characters != -1 and text.visible_characters < text.get_total_character_count():
		timer += delta
		if timer >=  settings.text_speed:
			if text.text and text.text[text.visible_characters] != " ":
				blip.play()
			text.visible_characters += 1
			timer = 0

func _on_Input_text_entered(new_text):
	emit_signal("message_sent", new_text, color)
	input.text = ""

func _on_emote_selected(index):
	input.grab_focus()

func _on_Options_color_changed(col):
	color = col
	input.grab_focus()