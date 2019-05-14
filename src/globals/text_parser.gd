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
	var tokens = [] #a tag array
	var color = ""
	var i = 0
	while i < msg.length():
		var symbol = msg[i]
		var wait = ""
		if not tokens.empty():
			wait = tokens.front()
#		print(str(i) + symbol + ": " + token + " | " + wait)
		if markup.has(token + symbol) and (wait == "" or token != wait):
			if i+1 < msg.length():	 #and tag != wait:
				token += symbol
			i += 1
			continue
		elif markup.has(token): #the symbol is alien to us now, it's probably not a token
			var tag = markup[token]
			print("TAG: " + tag)
			if tag == "color": #special shit
				if color != "":
					parsed += "[/" + tag + "]"
				if colors.has(token+symbol):
					var prevtags = []
					if token in tokens: #oh shit we got a wait on the color let's close/reopen all previous nerds
						for t in tokens:
							t = markup[t]
							if t == "color":
								break
							parsed += "[/" + t + "]"
							prevtags.push_back(t)
#					tokens.push_front(tag)
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
				if wait == token: #we were waiting to close this one
					tokens.pop_front()
					parsed += "[/" + tag + "]"
				elif not (token in tokens): #open that tag right up
					tokens.push_front(token)
					parsed += "[" + tag + "]"
				if color != "":
					parsed += "[color=" + color +"]"
			token = ""
			continue
		parsed += symbol
		i += 1
	if color != "":
		parsed += "[/color]"
	for t in tokens: #close lingering tags
		t = markup[t]
		parsed += "[/" + t + "]"
	return parsed