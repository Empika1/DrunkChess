extends ButtonImprover

var toggleOnPress: bool = false
var buttonIsToggledOn: bool = false
var buttonJustToggled: bool = false #jank and bad

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

var toggleOnFuncs: Array[Callable] = []
var toggleOffFuncs: Array[Callable] = []

func updateState():
	super.updateState()
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
		   pressFuncs_: Array[Callable], disableFuncs_: Array[Callable], toggleOnFuncs_: Array[Callable], toggleOffFuncs_: Array[Callable]):
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
