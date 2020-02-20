extends Sprite

var current_frames = [0]
var current_base_delay = 0
var current_delay = 0
var current_frame = 0
var current_loop = true
var current_effects = []
var frame_effects = []
var cycle_number = 0
var frame_counter = 0
var keep_delay = false
var played = false
var anim_frame = 0
var timer = 0.0
var flap = true

func _ready():
	pass