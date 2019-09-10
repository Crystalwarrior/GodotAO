extends ReferenceRect

onready var bg = $bg
onready var character = $character
onready var flap = $flap

var current_emote = null

func _ready():
	pass

func _on_Main_ic_character(emote, resource, stretch):
	current_emote = emote
	character.texture = resource
	if stretch:
		character.stretch_mode = TextureRect.STRETCH_SCALE
	else:
		character.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _on_Main_ic_background(resource):
	bg.texture = resource

func _on_Say_flap(vis, frame):
	flap.visible = vis
	if current_emote and current_emote["flap"]:
		flap.texture = current_emote["flap"]
		var off = current_emote["flap_offset"].split(" ")
		off = Vector2(off[0], off[1])
		flap.offset = off
	flap.frame = frame