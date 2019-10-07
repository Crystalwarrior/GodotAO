extends VBoxContainer

onready var input: LineEdit = $Input as LineEdit
onready var box: Control = $Box as Control
onready var showname: Label = $Box/Name/Text as Label
onready var text: RichTextLabel = $Box/Display/Text as RichTextLabel
onready var blip: AudioStreamPlayer = $Blip as AudioStreamPlayer
onready var flap = get_node("../View/character/flap")

signal message_sent(msg, color)
signal flap(vis, frame)
signal pre_off()

var timer = 0.0
var color: Color = ColorN("white") #Our default typing color
var pre = false

func _ready():
	flap.flap = false

func _on_ic_name(nick: String) -> void:
	showname.text = nick

func _on_ic_message(msg: String, col: Color = ColorN("white"), additive: bool = false) -> void:
	if msg.empty() or msg == " ":
		box.hide()
	else:
		box.show()
	text.add_color_override("default_color", col)
	if additive:
		text.bbcode_text += " %s" % text_parser.parse_markup(msg)
		timer = settings.text_speed
	else:
		text.bbcode_text = text_parser.parse_markup(msg)
		text.visible_characters = 0
		timer = settings.text_speed

	if settings.text_speed == 0:
		text.visible_characters = -1
		blip.play()

func _process(delta):
	if text.visible_characters == 0:
		box.hide()
	if text.visible_characters != -1 and text.visible_characters < text.get_total_character_count() and pre == false:
		timer += delta
		box.visible = true
		if timer >=  settings.text_speed:
			var letter: String = text.text[text.visible_characters] as String
			var pair: String = ""
			if text.visible_characters+1 < text.get_total_character_count():
				pair = letter + text.text[text.visible_characters+1] as String
				flap.flap = true
			else:
				flap.flap = false
			if text.text and letter != " ":
				blip.play()
			text.visible_characters += 1
			timer = 0

func _on_Input_text_entered(new_text):
	emit_signal("message_sent", new_text, color)
	emit_signal("pre_off")
	input.text = ""

func _on_emote_selected(index):
	input.grab_focus()

func _on_Options_color_changed(col):
	color = col
	input.grab_focus()

func _on_Toggle_pre(status):
	pre = status
