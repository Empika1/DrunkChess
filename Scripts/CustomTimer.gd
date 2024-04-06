extends RefCounted
class_name CustomTimer

var clampToZero: bool

var timeRemaining: float
var timeRemainingAtStart: float

var timestampAtLastUnpause: float
var timeRemainingAtLastUnpause: float

func _init(timeRemaining_: float, timestamp_: float, clampToZero_: bool):
	timeRemaining = timeRemaining_
	clampToZero = clampToZero_
	unpause(timestamp_)

func unpause(timestamp_: float):
	timestampAtLastUnpause = timestamp_
	timeRemainingAtLastUnpause = timeRemaining

func updateTime(timestamp_: float):
	timeRemaining = timeRemainingAtLastUnpause - (timestamp_ - timestampAtLastUnpause)
	if clampToZero:
		timeRemaining = maxf(timeRemaining, 0.)
