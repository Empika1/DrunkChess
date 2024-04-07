extends RefCounted
class_name CustomTimer

var clampToZero: bool

var timeRemaining: float
var timeRemainingAtStart: float

var timestampAtLastUnpause: float
var timeRemainingAtLastUnpause: float
var paused: bool = false

func _init(timeRemaining_: float, timestamp_: float, clampToZero_: bool, paused_: bool):
	timeRemaining = timeRemaining_
	timeRemainingAtStart = timeRemaining_
	clampToZero = clampToZero_
	unpause(timestamp_)
	if paused_:
		pause()

func pause():
	paused = true

func unpause(timestamp_: float):
	paused = false
	timestampAtLastUnpause = timestamp_
	timeRemainingAtLastUnpause = timeRemaining

func updateTime(timestamp_: float):
	if not paused:
		timeRemaining = timeRemainingAtLastUnpause - (timestamp_ - timestampAtLastUnpause)
		if clampToZero:
			timeRemaining = maxf(timeRemaining, 0.)
