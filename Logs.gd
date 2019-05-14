extends VBoxContainer

onready var text: RichTextLabel = $Text as RichTextLabel

func _on_ic_logs(msg: String) -> void:
	text.bbcode_text += text_parser.parse_markup(msg) + "\n"