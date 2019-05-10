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
	
	var bold: bool = false
	var italics: bool = false
	var underline: bool = false

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
#		elif not color.empty():
#
		else:
			parsed += symbol

	if not color.empty():
		parsed += "[/color]"
	return parsed