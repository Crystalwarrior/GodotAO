extends VBoxContainer

onready var input: LineEdit = $Input as LineEdit
onready var box: Control = $Box as Control
onready var showname: Label = $Box/Name/Text as Label
onready var text: RichTextLabel = $Box/Display/Text as RichTextLabel
onready var blip: AudioStreamPlayer = $Blip as AudioStreamPlayer

signal message_sent(msg)

var timer = 0.0
var delay = 0.05

func _on_ic_name(nick: String) -> void:
	showname.text = nick

func _on_ic_message(msg: String) -> void:
	if msg.empty() or msg == " ":
		box.hide()
	else:
		box.show()
	text.bbcode_text = text_parser.parse_markup(msg)
	text.visible_characters = 1

func _process(delta):
	if text.visible_characters < text.get_total_character_count():
		timer += delta
		if timer >= delay:
			if text.text and text.text[text.visible_characters] != " ":
				blip.play()
			text.visible_characters += 1
			timer = 0

func _on_Input_text_entered(new_text):
	emit_signal("message_sent", new_text)
	input.text = ""

func _on_emote_selected(index):
	input.grab_focus()