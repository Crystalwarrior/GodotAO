extends VBoxContainer

onready var text: RichTextLabel = $Text as RichTextLabel

func _on_ic_logs(msg: String) -> void:
	text.bbcode_text += msg + "\n"