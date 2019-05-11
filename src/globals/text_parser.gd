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
	var i = 0
	var symbol = ""
	while i < msg.length():
		symbol = msg[i]
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
		if token.begins_with("*") or symbol == "*":
			if symbol == "*" and token.length() < 3 and (token.empty() or token.begins_with("*")):
				token += "*"
				i += 1
				continue
			elif token.begins_with("*"):
				print(token + " | " + symbol, italics, underline, bold)
				if not italics and token.length() == 1:
					italics = true
					parsed += "[i]"
				elif not bold and token.length() == 2:
					bold = true
					parsed += "[b]"
				elif token.length() == 3:
					if not italics and not bold:
						italics = true
						bold = true
						parsed += "[i][b]"
					elif italics and bold:
						italics = false
						bold = false
						parsed += "[/b][/i]"
				elif bold and token.length() == 2:
					bold = false
					parsed += "[/b]"
				elif italics and token.length() == 1:
					italics = false
					parsed += "[/i]"
				token = ""
				continue
		if token.begins_with("_") or symbol == "_":
			if symbol == "_" and token.length() < 3 and (token.empty() or token.begins_with("_")):
				token += "_"
				i += 1
				continue
			elif token.begins_with("_"):
				print(token + " | " + symbol, italics, underline, bold)
				if not italics and token.length() == 1:
					italics = true
					parsed += "[i]"
				elif not underline and token.length() == 2:
					underline = true
					parsed += "[u]"
				elif token.length() == 3:
					if not italics and not underline:
						italics = true
						underline = true
						parsed += "[i][u]"
					elif italics and underline:
						italics = false
						underline = false
						parsed += "[/u][/i]"
				elif underline and token.length() == 2:
					underline = false
					parsed += "[/u]"
				elif italics and token.length() == 1:
					italics = false
					parsed += "[/i]"
				token = ""
				continue
#
#		if bold:
#			parsed += "[b]"
#		if italics:
#			parsed += "[i]"
#		if underline:
#			parsed += "[u]"
#		if not underline:
#			parsed += "[/u]"
#		if not italics:
#			parsed += "[/i]"
#		if not bold:
#			parsed += "[/b]"
		parsed += symbol
		i += 1
	print(parsed)
	if not color.empty():
		parsed += "[/color]"
	return parsed