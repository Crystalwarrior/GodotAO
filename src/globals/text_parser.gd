extends Node

const colors = {
	"\\c0": "white",
	"\\c1": "red",
	"\\c2": "yellow",
	"\\c3": "#ffa500", #orange
	"\\c4": "lime",
	"\\c5": "#0088ff", #blue
	"\\c6": "aqua",
	"\\c7": "#ff55ff", #purple
	"\\c8": "silver",
	"\\c9": "gray",
	"\\C0": "black",

	"\\w": "white",
	"\\r": "red",
	"\\y": "yellow",
	"\\o": "#ffa500", #orange
	"\\g": "lime",
	"\\b": "#0088ff", #blue
	"\\c": "aqua",
	"\\p": "#ff88ff", #purple
	"\\s": "silver",
	"\\G": "gray",
	"\\B": "black",
}

const markup = {
	"*": "i",
	"_": "i",
	"**": "b",
	"__": "u",
	"~~": "s",
	"\\": "color",
	"\\c": "color",
	"\\C": "color",
}

func strip_bbcode(msg: String) -> String:
	var re = RegEx.new()
	re.compile("\\[\\/?\\w*=?\\S*?\\]") #strip bbcode completely
	msg = re.sub(msg, "", true)

	return msg

func parse_markup(msg: String) -> String:
	msg = strip_bbcode(msg)

	var parsed = ""
	var token = "" #the token we detected
	var tags = [] #a tag array
	var color = ""
	var i = 0
	while i < msg.length():
		var symbol = msg[i]
		var wait = ""
		if not tags.empty():
			wait = tags.front()
#		print(str(i) + symbol + ": " + parsed + " | " + token)
		if markup.has(token + symbol):
			var tag = markup[token+symbol]
			if i+1 < msg.length() and tag != wait:
				token += symbol
			else:
				if color != "":
					parsed += "[/color]"
				if wait == tag: #we were waiting to close this one
					tags.pop_front()
					parsed += "[/" + tag + "]"
				elif not (tag in tags): #open that tag right up
					tags.push_front(tag)
					parsed += "[" + tag + "]"
				if color != "":
					parsed += "[color=" + color +"]"
				token = ""
			i += 1
			continue
		elif markup.has(token): #the symbol is alien to us now, it's probably not a token
			var tag = markup[token]
			if tag == "color": #special shit
				if color != "":
					parsed += "[/" + tag + "]"
				if colors.has(token+symbol):
					var prevtags = []
					if tag in tags: #oh shit we got a wait on the color let's close/reopen all previous nerds
						for t in tags:
							if t == "color":
								break
							parsed += "[/" + t + "]"
							prevtags.push_back(t)
#					tags.push_front(tag)
					color = colors[token+symbol]
					parsed += "[" + tag + "=" + color + "]"
					for t in prevtags:
						parsed += "[" + t + "]"
					i += 1
				else:
					color = ""
			else:
				if color != "":
					parsed += "[/color]"
				if wait == tag: #we were waiting to close this one
					tags.pop_front()
					parsed += "[/" + tag + "]"
				elif not (tag in tags): #open that tag right up
					tags.push_front(tag)
					parsed += "[" + tag + "]"
				if color != "":
					parsed += "[color=" + color +"]"
			token = ""
			continue
		parsed += symbol
		i += 1
	if color != "":
		parsed += "[/color]"
	for tag in tags: #close lingering tags
		parsed += "[/" + tag + "]"
	return parsed