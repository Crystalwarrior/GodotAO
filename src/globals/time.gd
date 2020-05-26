extends Node

const FORMAT_HOURS = 1 << 0
const FORMAT_MINUTES = 1 << 1
const FORMAT_SECONDS = 1 << 2
const FORMAT_DEFAULT = FORMAT_HOURS | FORMAT_MINUTES | FORMAT_SECONDS

func format(time, format = FORMAT_DEFAULT, digit_format = "%02d") -> String:
	var digits = []
	time = int(ceil(time))
	if format & FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)

	if format & FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)

	if format & FORMAT_SECONDS:
		var seconds = digit_format % [time % 60]
		digits.append(seconds)

	var formatted = String()
	var colon = " : "

	for digit in digits:
		formatted += digit + colon

	if not formatted.empty():
		formatted = formatted.rstrip(colon)

	return formatted
