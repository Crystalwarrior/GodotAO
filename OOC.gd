extends VBoxContainer

onready var input: LineEdit = $Input as LineEdit
onready var text: RichTextLabel = $Text as RichTextLabel

signal message_sent(msg)

func _on_ooc_message(msg: String) -> void:
	text.bbcode_text += text_parser.strip_bbcode(msg) + "\n"

func _on_Input_text_entered(new_text):
	emit_signal("message_sent", new_text)
	input.text = ""