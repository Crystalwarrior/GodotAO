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

#You may be asking: "What the FUCK is this huge blob (?!.*\[\/?\w*\])[^*]+?) !?
#The answer is simple - we don't want to match bbcode to not cause any problems.
const regex = {
	#strip BBCode:
	"bbcode": {"regex": "\\[\\/?\\w*\\]", "replace": ""},

	"bold": {"regex": "(\\*{2})((?!.*\\[\\/?\\w*\\])[^*]+?)(\\1)", "replace": "[b]$2[/b]"},
	"underline": {"regex": "(_{2})((?!.*\\[\\/?\\w*\\])[^_]+?)(\\1)", "replace": "[u]$2[/u]"},
	"italics": {"regex": "(\\*|_)((?!.*\\[\\/?\\w*\\])[^*_]+?)(\\1)", "replace": "[i]$2[/i]"},
	"strike": {"regex": "(~{2})((?!.*\\[\\/?\\w*\\])[^~]+?)(\\1)", "replace": "[s]$2[/s]"},

	"color": {"regex": "(\\\\.[0-9]?)([^\\\\]+)", "replace": "$3"},
}

func parse_markup(msg: String) -> String:
	msg = msg.strip_edges()

	var re = RegEx.new()
	re.compile(regex["bbcode"]["regex"])
	msg = re.sub(msg, regex["bbcode"]["replace"], true)

	re.compile(regex["bold"]["regex"])
	msg = re.sub(msg, regex["bold"]["replace"], true)

	re.compile(regex["underline"]["regex"])
	msg = re.sub(msg, regex["underline"]["replace"], true)

	re.compile(regex["italics"]["regex"])
	msg = re.sub(msg, regex["italics"]["replace"], true)

	re.compile(regex["strike"]["regex"])
	msg = re.sub(msg, regex["strike"]["replace"], true)
	print(msg)
	re.compile(regex["color"]["regex"])
	var search = re.search_all(msg)
	for re_match in search:
		var color = re_match.get_string(1)
		var text = re_match.get_string(2)
		print(color + " " + text)
		if color in colors:
			msg = re.sub(msg, "[color=" + colors[color] + "]$2[/color]")
		print(msg)
	return msg