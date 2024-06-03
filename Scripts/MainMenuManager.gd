extends Node

@export var screenForMenu: ColorRect
@export var title: TextureRect
@export var playButton: BorderScaleButton
@export var loadReplayButton: BorderScaleButton

@export var playMenu: Control
@export var playMenuCheckbox: BorderScaleButton
@export var playMenuTimeControlBox1: LineEdit
@export var playMenuTimeControlBox2: LineEdit
@export var playMenuTimeControlBox3: LineEdit
@export var playMenuPlayButton: BorderScaleButton
@export var playMenuExitButton: BorderScaleButton

var gameScene: PackedScene = load("res://Scenes/Game.tscn")
var replayScene: PackedScene = load("res://Scenes/Replay.tscn")

func _ready():
	playButton.buttonComponent.stateUpdated.connect(openPlayMenu)
	loadReplayButton.buttonComponent.stateUpdated.connect(loadReplay)
	
	playMenuCheckbox.buttonComponent.stateUpdated.connect(toggleIsTimed)	
	playMenuTimeControlBox1.text_changed.connect(box1TextChanged)
	playMenuTimeControlBox2.text_changed.connect(func(newText: String): box2Or3TextChanged(newText, playMenuTimeControlBox2))
	playMenuTimeControlBox3.text_changed.connect(func(newText: String): box2Or3TextChanged(newText, playMenuTimeControlBox3))
	playMenuPlayButton.buttonComponent.stateUpdated.connect(play)
	playMenuExitButton.buttonComponent.stateUpdated.connect(closePlayMenu)

func _process(_delta):
	title.pivot_offset = Vector2(title.size.x * 316.075/611, title.size.y * 191.68/333)
	title.rotation = sin(float(Time.get_ticks_msec()) / 500) / 50

func openPlayMenu(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		screenForMenu.color = Color(0.5, 0.5, 0.5, 0.5)
		playMenu.visible = true
		playButton.buttonComponent.disable()
		loadReplayButton.buttonComponent.disable()

func toggleIsTimed(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justToggled(oldState, newState):
		if newState.toggleState == 0:
			playMenuTimeControlBox1.editable = false
			playMenuTimeControlBox2.editable = false
			playMenuTimeControlBox3.editable = false
		else:
			playMenuTimeControlBox1.editable = true
			playMenuTimeControlBox2.editable = true
			playMenuTimeControlBox3.editable = true

func play(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		var isTimed: int = playMenuCheckbox.buttonComponent.state.toggleState == 1
		var timeSeconds: float = 0
		if isTimed:
			timeSeconds += float(playMenuTimeControlBox1.text if playMenuTimeControlBox1.text != "" else playMenuTimeControlBox1.placeholder_text) * 3600
			timeSeconds += float(playMenuTimeControlBox2.text if playMenuTimeControlBox2.text != "" else playMenuTimeControlBox2.placeholder_text) * 60
			timeSeconds += float(playMenuTimeControlBox3.text if playMenuTimeControlBox3.text != "" else playMenuTimeControlBox3.placeholder_text)
		timeSeconds = max(timeSeconds, 0.001)
		
		GameManager.states = [BoardState.newDefaultStartingState(BoardState.StartSettings.new(BoardState.StartSettings.AssistMode.MOVE_ARROWS, isTimed, timeSeconds))]
		get_tree().change_scene_to_packed(gameScene)

func closePlayMenu(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		screenForMenu.color = Color(0.5, 0.5, 0.5, 0.)
		playMenu.visible = false
		playButton.buttonComponent.enable()
		loadReplayButton.buttonComponent.enable()

func loadReplay(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		ReplayManager.replayString = ReplayManager.defaultReplayString
		get_tree().change_scene_to_packed(replayScene)

func box1TextChanged(newText: String):
	var oldCaretColumn: int = playMenuTimeControlBox1.caret_column
	var newerText: String = ""
	for i: String in newText:
		if i in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]:
			newerText += i
	playMenuTimeControlBox1.text = newerText
	playMenuTimeControlBox1.caret_column = oldCaretColumn - len(newText) + len(newerText)

func box2Or3TextChanged(newText: String, box: LineEdit):
	if len(newText) == 1:
		if not newText[0] in ["1", "2", "3", "4", "5", "0"]:
			box.text = ""
	elif len(newText) == 2:
		var oldCaretColumn: int = box.caret_column
		var newerText: String = ""
		if newText[0] in ["1", "2", "3", "4", "5", "0"]:
			newerText += newText[0]
		if newText[1] in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]:
			newerText += newText[1]
		box.text = newerText
		box.caret_column = oldCaretColumn - len(newText) + len(newerText)
