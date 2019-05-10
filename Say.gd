extends VBoxContainer

onready var input: LineEdit = $Input as LineEdit
onready var showname: Label = $Box/Name/Text as Label
onready var text: RichTextLabel = $Box/Display/Text as RichTextLabel

signal message_sent(msg)

func _on_ic_name(nick: String) -> void:
	showname.text = nick

func _on_ic_message(msg: String) -> void:
	text.bbcode_text = msg

func _on_Input_text_entered(new_text):
	emit_signal("message_sent", text_parser.parse_markup(new_text))
	input.text = ""