extends RefCounted
class_name ButtonImprover

var buttonIsHovered: bool = false
var buttonIsPressed: bool = false
var buttonIsDisabled: bool = false

var toggleOnPress: bool = false
var buttonIsToggledOn: bool = false
var buttonJustToggled: bool = false #jank and bad but oh well

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
		if toggleOnPress:
			buttonIsToggledOn = not buttonIsToggledOn
			buttonJustToggled = true
		updateState()

func unpressButton():
	if buttonIsPressed:
		buttonIsPressed = false
		if not toggleOnPress:
			buttonIsToggledOn = not buttonIsToggledOn
			buttonJustToggled = true
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
var toggleOnFuncs: Array[Callable] = []
var toggleOffFuncs: Array[Callable] = []

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
	
	if buttonJustToggled:
		if buttonIsToggledOn:
			for i: Callable in toggleOnFuncs:
				i.call()
		else:
			for i: Callable in toggleOffFuncs:
				i.call()
		buttonJustToggled = false

func _init(hoverSignal, unhoverSignal, pressSignal, unpressSignal, disableSignal, 
		   enableSignal, defaultFuncs_: Array[Callable], hoverFuncs_: Array[Callable], 
		   pressFuncs_: Array[Callable], disableFuncs_: Array[Callable], toggleOnFuncs_: Array[Callable], 
		   toggleOffFuncs_: Array[Callable], toggleOnPress_: bool):
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
	toggleOnFuncs = toggleOnFuncs_
	toggleOffFuncs = toggleOffFuncs_
	toggleOnPress = toggleOnPress_
