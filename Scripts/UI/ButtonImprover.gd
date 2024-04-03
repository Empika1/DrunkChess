extends RefCounted
class_name ButtonImprover

var buttonIsHovered: bool = false
var buttonIsPressed: bool = false
var buttonIsDisabled: bool = false

func hoverButton():
	if !buttonIsHovered:
		buttonIsHovered = true
		updateState()

func unhoverButton():
	if buttonIsHovered:
		buttonIsHovered = false
		updateState()

func pressButton():
	if !buttonIsPressed:
		buttonIsPressed = true
		updateState()

func unpressButton():
	if buttonIsPressed:
		buttonIsPressed = false
		updateState()

func disableButton():
	if !buttonIsDisabled:
		buttonIsDisabled = true
		updateState()

func enableButton():
	if buttonIsDisabled:
		buttonIsDisabled = false
		updateState()
	
var defaultFuncs: Array[Callable] = []
var hoverFuncs: Array[Callable] = []
var pressFuncs: Array[Callable] = []
var disableFuncs: Array[Callable] = []

func updateState():
	if buttonIsDisabled:
		for i: Callable in disableFuncs:
			i.call()
	elif buttonIsPressed:
		for i: Callable in pressFuncs:
			i.call()
	elif buttonIsHovered:
		for i: Callable in hoverFuncs:
			i.call()
	else:
		for i: Callable in defaultFuncs:
			i.call()

func _init(hoverSignal, unhoverSignal, pressSignal, unpressSignal, disableSignal, 
		   enableSignal, defaultFuncs_: Array[Callable], hoverFuncs_: Array[Callable], 
		   pressFuncs_: Array[Callable], disableFuncs_: Array[Callable]):
	if hoverSignal != null: hoverSignal.connect(hoverButton)
	if unhoverSignal != null: unhoverSignal.connect(unhoverButton)
	if pressSignal != null: pressSignal.connect(pressButton)
	if unpressSignal != null: unpressSignal.connect(unpressButton)
	if disableSignal != null: disableSignal.connect(disableButton)
	if enableSignal != null: enableSignal.connect(enableButton)
	defaultFuncs = defaultFuncs_
	hoverFuncs = hoverFuncs_
	pressFuncs = pressFuncs_
	disableFuncs = disableFuncs_
