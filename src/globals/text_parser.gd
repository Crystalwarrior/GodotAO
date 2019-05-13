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
	"~~": "s"
}

func parse_markup(msg: String) -> String:
	var re = RegEx.new()
	re.compile("\\[\\/?\\w*=?\\S*?\\]") #strip bbcode completely
	msg = re.sub(msg, "", true)
	
	var parsed = ""
	var token = "" #the token we detected
	var tags = [] #a tag array
	var i = 0
	while i < msg.length():
		var symbol = msg[i]
		var wait = ""
		if not tags.empty():
			wait = tags.front()
		print(wait)
		print(str(i) + symbol + ": " + parsed + " | " + token)
		if markup.has(token + symbol):
			var tag = markup[token+symbol]
			if i+1 < msg.length() and tag != wait:
				token += symbol
			else:
				if wait == tag: #we were waiting to close this one
					tags.pop_front()
					parsed += "[/" + tag + "]"
				elif not (tag in tags): #open that tag right up
					tags.push_front(tag)
					parsed += "[" + tag + "]"
				token = ""
			i += 1
			continue
		elif markup.has(token): #the symbol is alien to us now, it's probably not a token
			var tag = markup[token]
			if wait == tag: #we were waiting to close this one
				tags.pop_front()
				parsed += "[/" + tag + "]"
			elif not (tag in tags): #open that tag right up
				tags.push_front(tag)
				parsed += "[" + tag + "]"
			token = ""
			continue
		parsed += symbol
		i += 1
	print(tags)
	return parsed