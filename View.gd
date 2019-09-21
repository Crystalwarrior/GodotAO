extends ReferenceRect

onready var bg = $bg
onready var character = $character
onready var flap = $flap

var current_emote = null

var current_frames = [0, 0]
var base_delay = 0
var current_delay = 0
var timer = 0.0
var current_frame = 0
var current_loop = false
var cycle_number = 0
var frame_counter = 0
var current_effects = []
var keep_delay = false
var played = false

func _ready():
	pass

func _process(delta):
	
	var viewportWidth = self.rect_size.x
	var viewportHeight = self.rect_size.y
	
	character.set_position(Vector2(viewportWidth/2, viewportHeight/2))

	if character.texture:
		var scale = viewportHeight / (character.texture.get_size().y / character.vframes)
		character.set_scale(Vector2(scale, scale))

	timer += delta
	
	if character.hframes > 1 and frame_counter <= current_frames.size()-1:

		if timer >= current_delay:
			# If the current element in the array is a string
			if typeof(current_frames[frame_counter]) == 4 && cycle_number == 0:
				# Check if this element in the array playing the first time
				if played == false:
					current_frame =  int(current_frames[frame_counter].split("-")[0])
					cycle_number = int(current_frames[frame_counter].split("-")[1]) - int(current_frames[frame_counter].split("-")[0])
					played = true
				# Check if animation should loop
				if played == true and current_loop == true:
					frame_counter = 0
					current_delay = base_delay
					keep_delay = false
					played = false
				# If not looping or playing animation it go to the next element in the array
				elif cycle_number == 0:
					frame_counter += 1
					played = false
					current_delay = base_delay
					keep_delay = false
			# If the current element in the array is an integer
			elif cycle_number == 0: 
				current_frame = current_frames[frame_counter]
				# Check if animation is finished and if it's looping
				if frame_counter == current_frames.size()-1 and current_loop == true:
					frame_counter = 0
					current_delay = base_delay
					keep_delay = false
					played = false
				# If animation not finished go to the next element in the array
				else:
					frame_counter += 1
					played = false
			# Go to the next frame of the animation and counting down the length
			if cycle_number > 0:
					current_frame += 1
					cycle_number -= 1
			# Set the delay to the animation's base delay
			if keep_delay == false:
				current_delay = base_delay
			# check if current frame have any effect
			if current_effects.has(String(current_frame)):
				var frame_effects = current_effects[String(current_frame)]
				# Set delay to the frame's delay
				if frame_effects.has("delay"):
					current_delay = frame_effects["delay"]
					# Check if the frame's delay remain the delay for the animation
					if frame_effects.has("keep_delay"):
						keep_delay = frame_effects["keep_delay"]
					else:
						keep_delay = false
			timer = 0.0
		character.frame = current_frame

func _on_Main_ic_character(emote, resource, frames, delay, rows, columns, loop, effects):
	current_emote = emote
	current_frame = 0
	frame_counter = 0
	cycle_number = 0
	character.texture = resource
	character.vframes = rows
	character.hframes = columns
	if frames != null:
		current_frames = frames
		current_delay = delay
		base_delay = delay
		current_loop = loop
		current_effects = effects

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