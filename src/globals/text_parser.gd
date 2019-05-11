extends Node

const colors = {
#	"\\c0": "white",
#	"\\c1": "red",
#	"\\c2": "yellow",
#	"\\c3": "#ffa500", #orange
#	"\\c4": "lime",
#	"\\c5": "#0088ff", #blue
#	"\\c6": "aqua",
#	"\\c7": "#ff55ff", #purple
#	"\\c8": "silver",
#	"\\c9": "gray",
#	"\\C0": "black",
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

func parse_markup(msg: String) -> String:
	var token: String = ""
	var parsed: String = ""
	var color: String = ""

	var bold = false
	var italics = false
	var underline = false

	msg = msg.strip_edges()

	for symbol in msg:
		if token.begins_with("\\") or symbol == "\\":
			token += symbol
			if token.length() == 2 and colors.has(token):
				if not color.empty():
					parsed += "[/color]"
				color = colors[token]
				parsed += "[color=" + color + "]"
				token = ""
			elif token.length() >= 2:
				parsed += token.substr(1, token.length())
				token = ""
		elif token.begins_with("*") or symbol == "*":
			if symbol == "*":
				token += "*"
			else:
				if token.length() == 1 or token.length() == 3: #bold
					if not bold:
						bold = true
						parsed += "[b]"
					else:
						bold = false
						parsed += "[/b]"
				if token.length() == 1 or token.length() == 3: #italics
					if not italics:
						italics = true
						parsed += "[i]"
					else:
						italics = false
						parsed += "[/i]"
				token = ""
				parsed += symbol
		elif token.begins_with("_") or symbol == "_":
			if symbol == "_":
				token += "_"
			else:
				if token.length() == 2 or token.length() == 3: #underline
					if not underline:
						underline = true
						parsed += "[u]"
					else:
						underline = false
						parsed += "[/u]"
				if token.length() == 1 or token.length() == 3: #italics
					if not italics:
						italics = true
						parsed += "[i]"
					else:
						italics = false
						parsed += "[/i]"
				token = ""
				parsed += symbol
		else:
			parsed += symbol
	print(parsed)
	if not color.empty():
		parsed += "[/color]"
	return parsed