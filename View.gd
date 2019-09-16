extends ReferenceRect

onready var bg = $bg
onready var character = $character
onready var flap = $flap

var current_emote = null

var current_frames = [0, 0]
var current_delays = [0, 0]
var timer = 0.0
var current_frame = 0
var current_loop = true

func _ready():
	pass

func _process(delta):
	
	var viewportWidth = self.rect_size.x
	var viewportHeight = self.rect_size.y
	
	character.set_position(Vector2(viewportWidth/2, viewportHeight/2))

	if character.texture:
		var scale = viewportHeight / character.texture.get_size().y
		character.set_scale(Vector2(scale, scale))

	timer += delta
	if character.hframes > 1:
		if timer >= current_delays[current_frame] and current_frame <= current_frames.size():
			current_frame += 1
			timer = 0.0
			if current_frame == current_frames.size() and current_loop == true:
				current_frame = 0
	if current_frames.size() > 1:
		character.frame = current_frames[current_frame-1]

func _on_Main_ic_character(emote, resource, stretch, frames, delays, rows, columns, loop):
	current_emote = emote
	character.texture = resource
	if frames != null:
		character.vframes = rows
		character.hframes = columns
		current_frames = frames
		current_delays = delays
		current_loop = loop

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