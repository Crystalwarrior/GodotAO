extends ReferenceRect

onready var bg = $bg
onready var character = $character

func _ready():
	pass

func _on_Main_ic_character(resource, stretch):
	character.texture = resource
	if stretch:
		character.stretch_mode = TextureRect.STRETCH_SCALE
	else:
		character.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED