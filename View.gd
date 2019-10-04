extends ReferenceRect

onready var bg = $bg
onready var character = $character
onready var flap = $character/flap
onready var blink = $character/blink

var current_emote = null

var character_frames = [0]
var character_base_delay = 0
var character_delay = 0
var timer = 0.0
var current_frame = 0
var character_loop = false
var cycle_number = 0
var frame_counter = 0
var character_effects = []
var keep_delay = false
var played = false
var anim_frame = 0
var characterTexture = ImageTexture.new()
var characterImage = null
var characterBaseImage = null
var flapImage = null
var blinkImage = null
var off = []
var blinkoff = []
var character_timer = 0.0
var flap_timer = 0.0
var blink_timer = 0.0
var charImageW = 0
var charImageH = 0
var flapImageW = 0
var flapImageH = 0
var blinkImageW = 0
var blinkImageH = 0
var blinkWaitFrames = []
var blinkWaitFrame = 0
var blinkCurrentWait = 0
var blinkWaitTimer = 0.0

func _ready():
	characterTexture.storage = ImageTexture.STORAGE_COMPRESS_LOSSLESS
	character.texture = characterTexture

func _process(delta):

	character_timer += delta
	flap_timer += delta

	if blinkWaitFrames.size() > 0:
		if blink.anim_frame == 0 and blinkWaitTimer == 0:
			if typeof(blinkWaitFrames[blinkWaitFrame]) == 3:
				blinkCurrentWait = blinkWaitFrames[blinkWaitFrame]
			else:
				var times = blinkWaitFrames[blinkWaitFrame].split("-")
				var rng = RandomNumberGenerator.new()
				rng.randomize()
				blinkCurrentWait = rng.randi_range(int(times[0]),int(times[1]))
		if blink.anim_frame == 0 and blinkWaitTimer <= blinkCurrentWait:
			 blinkWaitTimer += delta
		else:
			if blinkWaitFrame > blinkWaitFrames.size()-1:
				blinkWaitFrame = 0
			blink_timer += delta

	var viewportWidth = self.rect_size.x
	var viewportHeight = self.rect_size.y

	if character.hframes > 1 and character.frame_counter <= character.current_frames.size()-1:
		if character_timer >= character.current_delay:
			_anim(character)
			character_timer = 0.0

	if flap.hframes > 1 and flap.frame_counter <= flap.current_frames.size()-1:
		if flap_timer >= flap.current_delay:
			_anim(flap)
			flap_timer = 0.0

	if blink.hframes > 1 and blink.frame_counter <= blink.current_frames.size()-1:
		if blink_timer >= blink.current_delay:
			_anim(blink)
			if blinkWaitTimer != 0.0:
				blinkWaitFrame += 1
				if blinkWaitFrame > blinkWaitFrames.size()-1:
					blinkWaitFrame = 0
			blinkWaitTimer = 0.0
			blink_timer = 0.0

	character.set_position(Vector2(viewportWidth/2, viewportHeight/2))

	if character.texture:
		if character.texture.get_size().y > 0:
			var scale = viewportHeight / (character.texture.get_size().y / character.vframes)
			character.set_scale(Vector2(scale, scale))

	$Label.text = String(int(blinkCurrentWait))


func _on_Main_ic_character(emote, resource, frames, delay, rows, columns, loop, effects, flap_data, flapfile, blink_data, blinkfile):
	if current_emote != emote:
		current_emote = emote
		current_frame = 0
		character.frame_counter = 0
		character.current_frame = 0
		character.cycle_number = 0
		character.frame = 0
		character.anim_frame = 0
		character.played = false
		character.vframes = rows
		character.hframes = columns
		characterImage = resource.get_data()
		characterBaseImage = resource.get_data()
	if frames != null:
		character.current_frames = frames
		character.current_delay = delay
		character.current_base_delay = character.current_delay
		character.current_loop = loop
		character.current_effects = effects
	if flap_data.size() > 0:
		character.texture = characterTexture
#		flap.visible = true
		flap.frame_counter = 0
		flap.cycle_number = 0
		flap.anim_frame = 0
		flap.texture = flapfile
		flap.vframes = flap_data["rows"]
		flap.hframes = flap_data["columns"]
		flap.current_frames = flap_data["frames"]
		flap.current_base_delay = flap_data["delay"]
		off = flap_data["offset"].split(" ")
#		flap.set_position(off[0], off[1])
		flapImage = flapfile.get_data()
		flapImageW = flapfile.get_width()/flap.hframes
		flapImageH = flapfile.get_height()/flap.vframes
	else:
		flap.visible = false
		flapImage = null
		characterImage = null
		character.texture = resource
	if blink_data.size() > 0:
		blink.frame_counter = 0
		blink.cycle_number = 0
		blink.anim_frame = 0
		blink.texture = blinkfile
		blink.vframes = blink_data["rows"]
		blink.hframes = blink_data["columns"]
		blink.current_frames = blink_data["frames"]
		blink.current_delay = blink_data["delay"]
		blink.current_base_delay = blink_data["delay"]
		blinkoff = blink_data["offset"].split(" ")
		blinkImage = blinkfile.get_data()
		blinkImageW = blinkfile.get_width()/blink.hframes
		blinkImageH = blinkfile.get_height()/blink.vframes
		blinkWaitFrames = blink_data["wait"]
		blinkWaitFrame = 0
		blinkWaitTimer = 0
		blink_timer = 0.0
	else:
		blinkImage = null
		blinkWaitFrames = []


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

func _anim(object):
	# Check if the current frame declared as a string
	if typeof(object.current_frames[frame_counter]) == 4:
		if object.cycle_number == 0 && object.played == false:
			object.current_frame =  int(object.current_frames[object.frame_counter].split("-")[0])
			object.cycle_number = int(object.current_frames[object.frame_counter].split("-")[1]) - int(object.current_frames[object.frame_counter].split("-")[0])
			object.played = true
		if object.cycle_number > 0:
			object.current_frame += 1
			object.cycle_number -= 1
			object.anim_frame += 1
	# If current frame not a string and nothing plays
	elif object.cycle_number == 0:
		object.current_frame = object.current_frames[object.frame_counter]
		object.played = true

	if object.cycle_number == 0:
		_set_loop(object)

	_set_delay(object)

	if object.flap == true:
		object.frame = object.current_frame
	else:
		object.frame = 0

	if characterImage != null:
		_set_imagetexture(object)

func _set_loop(object):
# Check if animation should loop
	if object.frame_counter == object.current_frames.size()-1 and object.current_loop == true and object.played == true:
		object.frame_counter = 0
		object.cycle_number = 0
		object.anim_frame = 0
		object.current_delay = object.current_base_delay
		object.keep_delay = false
		object.played = false
	# If no looping it jump to the next frame in the array
	else:
		object.frame_counter += 1
		object.anim_frame += 1
		object.played = false

func _set_delay(object):
	# delay shenanigans
	if object.keep_delay == false:
		object.current_delay = object.current_base_delay
	if object.current_effects.has(String(object.anim_frame)):
		object.frame_effects = object.current_effects[String(object.anim_frame)]
		# Set delay to the frame's delay
		if object.frame_effects.has("delay"):
			object.current_delay = object.frame_effects["delay"]
			# Check if the frame's delay remain the delay for the animation
			if object.frame_effects.has("keep_delay"):
				object.keep_delay = object.frame_effects["keep_delay"]
			else:
				object.keep_delay = false

func _set_imagetexture(object):
	#Getting the width and height of the textures
	charImageW = character.texture.get_width()/character.hframes
	charImageH = character.texture.get_height()/character.vframes
	if flapImage != null:
		flapImageW = flap.texture.get_width()/flap.hframes
		flapImageH = flap.texture.get_height()/flap.vframes
	if blinkImage != null:
		blinkImageW = blink.texture.get_width()/blink.hframes
		blinkImageH = blink.texture.get_height()/blink.vframes
	#Reset the character texture before adding to it
	characterImage.copy_from(characterBaseImage)
	if blinkoff.size() > 0:
		characterImage.blend_rect(blinkImage, Rect2(Vector2(blinkImageW * blink.frame, 0), Vector2(blinkImageW, blinkImageH)), Vector2(int(blinkoff[0]) + charImageW * character.frame, blinkoff[1]))
	if off.size() > 0:
		characterImage.blend_rect(flapImage, Rect2(Vector2(flapImageW * flap.frame, 0), Vector2(flapImageW, flapImageH)), Vector2(int(off[0]) + charImageW * character.frame, off[1]))
	characterTexture.create_from_image(characterImage, 0)