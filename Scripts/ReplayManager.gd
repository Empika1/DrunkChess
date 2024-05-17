extends Node
class_name ReplayManager

@export var board: TextureRect
@export var pieceHolder: Control
@export var blackTimer: Label
@export var whiteTimer: Label
@export var blackCaptures: HBoxContainer
@export var whiteCaptures: HBoxContainer
@export var nextButton: ModulateScaleButton
@export var previousButton: ModulateScaleButton
@export var loadMenuButton: BorderScaleButton

@export var menu: TextureRect
@export var menuBox: LineEdit
@export var menuMainMenuButton: BorderScaleButton
@export var menuLoadReplayButton: BorderScaleButton
@export var menuLoadReplayButtonText: Label

@export var screenForMenu: ColorRect

@export var lines: TextureRect
@export var circles: TextureRect
@export var circleArcs: TextureRect
@export var arrows: TextureRect

var replayString: String = "H4sIAAAAAAAACmPMEHnHAAIsYgoMCgxJDHIMAgoMCQxMDFIMQglAETWQSAJQhA0oIrIAKOIFElkAFOECikg8AIr0gUQeAEX4gCLSIHM2AUUEQeYIAUVEQeaEgURA5ogBRYRB5liBREDmSAGhOMicOpAIyBw5oAgQMCoyzd3QLJQ3vUd4AsMEBg6Rt/O1mXg8DxQ3MDcwOCzP+RkhkOTHcodBhoGJ1Tro66H+GA1lBYYHDAKat6avE6l66KjOwMrA0Oh3blo7UB/HCQYPBhauspItlhECCZ4HGA4wKARv8jBUe1nJZAR0FiPT3EmOnebeJ4Ras6Wmcoi8mcTjuSvOgZuTgQEAzoAYPyYBAAA="
var states: Array[BoardState] = []
var stateIndex: int = 0

const shadowRealm: Vector2 = Vector2(9999999, 9999999)
var pieceScene: PackedScene = preload("res://Prefabs/DraggablePiece.tscn")
var usedPiecePool: Array[DraggablePiece]
var freePiecePool: Array[DraggablePiece]

var whiteCapturesContainers: Array[AspectRatioContainer]
var blackCapturesContainers: Array[AspectRatioContainer]

func getScaledRectSize() -> float:
	return board.get_rect().size.x

func boardLengthToGameLength(boardLength: int) -> float:
	return boardLength * getScaledRectSize() / float(Piece.boardSize)

func boardPosToGamePos(boardPos: Vector2i) -> Vector2:
	return Vector2(boardLengthToGameLength(boardPos.x) + board.global_position.x, boardLengthToGameLength(boardPos.y) + board.global_position.y)

func addPieceToFreePool(piece) -> void:
	var sprite: DraggablePiece = pieceScene.instantiate()
	sprite.material = sprite.material.duplicate()
	freePiecePool.append(sprite)
	pieceHolder.add_child(sprite)
	sprite.init(piece)

func tryStringToStateList(replayString_: String) -> Array[BoardState]: #returns [] if invalid replay
	var arr: BitArray = BitArray.fromBase64(replayString_, 3)
	if arr == null:
		return []
	var state: BoardState = Replay.bitArrayToValidBoardState(arr)
	if state == null:
		return []
	
	var states_: Array[BoardState] = [Replay.bitArrayToValidBoardState(BitArray.fromBase64(replayString_, 3))]
	while states_[-1].previousState != null:
		states_.append(states_[-1].previousState)
	states_.reverse()
	return states_

func resetPieces(states_: Array[BoardState]) -> void:
	states = states_
	stateIndex = 0
	for node in whiteCaptures.get_children():
		whiteCaptures.remove_child(node)
		node.queue_free()
	for node in blackCaptures.get_children():
		blackCaptures.remove_child(node)
		node.queue_free()
	whiteCapturesContainers = []
	blackCapturesContainers = []
	for piece in states_[0].pieces:
		addPieceToFreePool(piece)
		
		var container: AspectRatioContainer = AspectRatioContainer.new()
		container.stretch_mode = AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH
		if piece.color == Piece.PieceColor.WHITE:
			whiteCaptures.add_child(container)
			whiteCapturesContainers.append(container)
		else:
			blackCaptures.add_child(container)
			blackCapturesContainers.append(container)
	
	for i in range(5):
		var container: AspectRatioContainer = AspectRatioContainer.new()
		container.stretch_mode = AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH
		whiteCaptures.add_child(container)
		whiteCapturesContainers.append(container)
	
	for i in range(5):
		var container: AspectRatioContainer = AspectRatioContainer.new()
		container.stretch_mode = AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH
		blackCaptures.add_child(container)
		blackCapturesContainers.append(container)
	
	previousButton.buttonComponent.disable()
	if len(states) == 1:
		nextButton.buttonComponent.disable()
	else:
		nextButton.buttonComponent.enable()

func _ready() -> void:
	loadMenuButton.buttonComponent.stateUpdated.connect(pause)
	menuLoadReplayButton.buttonComponent.stateUpdated.connect(loadReplay)
	menuMainMenuButton.buttonComponent.stateUpdated.connect(goToMainMenu)
	
	nextButton.buttonComponent.stateUpdated.connect(next)
	previousButton.buttonComponent.stateUpdated.connect(previous)
	
	menuBox.text_changed.connect(updateEnteredReplay)
	
	var states_: Array[BoardState] = tryStringToStateList(replayString)
	resetPieces(states_)

static func getPieceFrame(col: Piece.PieceColor, type: Piece.PieceType) -> int:
	return int(col) * 6 + int(type)

func formatTime(seconds_: float) -> String:
	var totalTenths: int = int(seconds_ * 10)
	var tenths: int = totalTenths
	var hours: int = tenths / 36000
	tenths %= 36000
	var minutes: int = tenths / 600
	tenths %= 600
	var seconds: int = tenths / 10
	tenths %= 10
	return ((str(hours) + ":" if hours > 0 else "") +
			(str(minutes) + ":" if minutes > 0 else "") +
			(("0" if seconds < 10 else "") + str(seconds)) +
			("." + str(tenths) if totalTenths <= 300 else ""))

func previous(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		stateIndex -= 1
		if stateIndex == 0:
			previousButton.buttonComponent.disable()
		else:
			nextButton.buttonComponent.enable()

func next(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		stateIndex += 1
		if stateIndex == len(states) - 1:
			nextButton.buttonComponent.disable()
		else:
			previousButton.buttonComponent.enable()

var stateToRender: BoardState
func _process(_delta) -> void:	
	deleteCircles(); deleteLines(); deleteArcs(); deleteArrows();
	stateToRender = states[stateIndex]
#
	while len(usedPiecePool) > 0:
		var sprite: DraggablePiece = usedPiecePool.pop_back()
		sprite.reparent(pieceHolder)
		freePiecePool.append(sprite)
	
	for piece in stateToRender.pieces:
		var sprite: DraggablePiece = freePiecePool.pop_back()
		usedPiecePool.append(sprite)
		
		sprite.piece = piece
		(sprite.material as ShaderMaterial).set_shader_parameter("frame", getPieceFrame(piece.color, piece.type))
		sprite.size = board.size / 8
		sprite.global_position = boardPosToGamePos(piece.pos) - sprite.size / 2
	
	var whiteCapturedPiecesSorted: Array[Piece] = []
	var blackCapturedPiecesSorted: Array[Piece] = []
	for piece in stateToRender.capturedPieces:
		if piece.color == Piece.PieceColor.WHITE:
			whiteCapturedPiecesSorted.append(piece)
		else:
			blackCapturedPiecesSorted.append(piece)
	whiteCapturedPiecesSorted.sort_custom(Piece.sortByType)
	blackCapturedPiecesSorted.sort_custom(Piece.sortByType)
	var i: int = 0
	while i < len(whiteCapturedPiecesSorted):
		var piece: Piece = whiteCapturedPiecesSorted[i]
		var sprite: DraggablePiece = freePiecePool.pop_back()
		usedPiecePool.append(sprite)
		sprite.piece = piece
		(sprite.material as ShaderMaterial).set_shader_parameter("frame", getPieceFrame(piece.color, piece.type))
		if i > 0 and piece.type != whiteCapturedPiecesSorted[i - 1].type:
			whiteCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
			i += 1
		sprite.reparent(whiteCapturesContainers[i])
		whiteCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		i += 1
	while i < len(whiteCapturesContainers):
		whiteCapturesContainers[i].size_flags_horizontal = Control.SIZE_FILL
		i += 1
	i = 0
	while i < len(blackCapturedPiecesSorted):
		var piece: Piece = blackCapturedPiecesSorted[i]
		var sprite: DraggablePiece = freePiecePool.pop_back()
		usedPiecePool.append(sprite)
		sprite.piece = piece
		(sprite.material as ShaderMaterial).set_shader_parameter("frame", getPieceFrame(piece.color, piece.type))
		if i > 0 and piece.type != blackCapturedPiecesSorted[i - 1].type:
			blackCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
			i += 1
		sprite.reparent(blackCapturesContainers[i])
		blackCapturesContainers[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		i += 1
	while i < len(blackCapturesContainers):
		blackCapturesContainers[i].size_flags_horizontal = Control.SIZE_FILL
		i += 1
	
	for sprite in freePiecePool:
		sprite.global_position = shadowRealm
		sprite.piece = null
	
	addCaptureArrows(stateToRender)
	
	whiteTimer.text = formatTime(states[-1].whiteTime)
	blackTimer.text = formatTime(states[-1].blackTime)
	
	setCircles(); setLines(); setArcs(); setArrows();

var lineStarts: PackedVector2Array
var lineEnds: PackedVector2Array
var lineColorsrg: PackedVector2Array
var lineColorsba: PackedVector2Array
var lineThicknesses: PackedFloat32Array
func setLines() -> void:
	var mat = lines.material as ShaderMaterial
	mat.set_shader_parameter("lineStarts", lineStarts)
	mat.set_shader_parameter("lineEnds", lineEnds)
	mat.set_shader_parameter("lineColorsrg", lineColorsrg)
	mat.set_shader_parameter("lineColorsba", lineColorsba)
	mat.set_shader_parameter("lineThicknesses", lineThicknesses)
func deleteLines() -> void:
	lineStarts = PackedVector2Array(); lineEnds = PackedVector2Array(); lineColorsrg = PackedVector2Array()
	lineColorsba = PackedVector2Array(); lineThicknesses = PackedFloat32Array()
	setLines()

var circleCenters: PackedVector2Array
var circleRadii: PackedFloat32Array
var circleColorsrg: PackedVector2Array
var circleColorsba: PackedVector2Array
func setCircles() -> void:
	var mat = circles.material as ShaderMaterial
	mat.set_shader_parameter("circleCenters", circleCenters)
	mat.set_shader_parameter("circleRadii", circleRadii)
	mat.set_shader_parameter("circleColorsrg", circleColorsrg)
	mat.set_shader_parameter("circleColorsba", circleColorsba)
func deleteCircles() -> void:
	circleCenters = PackedVector2Array(); circleRadii = PackedFloat32Array()
	circleColorsrg = PackedVector2Array(); circleColorsba = PackedVector2Array()
	setCircles()

var arcCenters: PackedVector2Array
var arcRadii: PackedFloat32Array
var arcThicknesses: PackedFloat32Array
var arcColorsrg: PackedVector2Array
var arcColorsba: PackedVector2Array
var arcEndIndices: PackedInt32Array
var arcStarts: PackedVector2Array
var arcEnds: PackedVector2Array
func setArcs() -> void:
	var mat = circleArcs.material as ShaderMaterial
	mat.set_shader_parameter("circleCenters", arcCenters)
	mat.set_shader_parameter("circleRadii", arcRadii)
	mat.set_shader_parameter("circleThicknesses", arcThicknesses)
	mat.set_shader_parameter("circleColorsrg", arcColorsrg)
	mat.set_shader_parameter("circleColorsba", arcColorsba)
	mat.set_shader_parameter("arcEndIndices", arcEndIndices)
	mat.set_shader_parameter("arcStarts", arcStarts)
	mat.set_shader_parameter("arcEnds", arcEnds)
func deleteArcs() -> void:
	arcCenters = PackedVector2Array(); arcRadii = PackedFloat32Array(); arcThicknesses = PackedFloat32Array()
	arcColorsrg = PackedVector2Array(); arcColorsba = PackedVector2Array(); arcEndIndices = PackedInt32Array()
	arcStarts = PackedVector2Array(); arcEnds = PackedVector2Array()
	setArcs()

@export var hitRadiusColor: Color
func addHitRadii(pieces: Array[Piece]) -> void:
	for piece in pieces:
		addHitRadius(piece)
func addHitRadius(piece: Piece) -> void:
	circleCenters.append(Vector2(piece.pos) / Piece.boardSize)
	circleRadii.append(float(piece.hitRadius) / Piece.boardSize)
	circleColorsrg.append(Vector2(hitRadiusColor.r, hitRadiusColor.g))
	circleColorsba.append(Vector2(hitRadiusColor.b, hitRadiusColor.a))

var arrowStarts: PackedVector2Array
var arrowEnds: PackedVector2Array
var arrowColorsrg: PackedVector2Array
var arrowColorsba: PackedVector2Array
var arrowThicknesses: PackedFloat32Array
var arrowDistortPoints: PackedVector2Array
func setArrows() -> void:
	var mat = arrows.material as ShaderMaterial
	mat.set_shader_parameter("arrowStarts", arrowStarts)
	mat.set_shader_parameter("arrowEnds", arrowEnds)
	mat.set_shader_parameter("arrowColorsrg", arrowColorsrg)
	mat.set_shader_parameter("arrowColorsba", arrowColorsba)
	mat.set_shader_parameter("arrowThicknesses", arrowThicknesses)
	mat.set_shader_parameter("arrowDistortPoints", arrowDistortPoints)
func deleteArrows() -> void:
	arrowStarts = PackedVector2Array(); arrowEnds = PackedVector2Array(); arrowColorsrg = PackedVector2Array()
	arrowColorsba = PackedVector2Array(); arrowThicknesses = PackedFloat32Array(); arrowDistortPoints = PackedVector2Array()
	setLines()

@export var whiteCapturerArrowColor: Color
@export var blackCapturerArrowColor: Color
@export var arrowThickness: float
func addCaptureArrows(state: BoardState) -> void:
	for i in range(len(state.pieces)):
		var capturer: Piece = state.pieces[i]
		var piecesCanCapture: Array[Piece] = state.piecesCanCapture[i]
		for capturee: Piece in piecesCanCapture:
			arrowStarts.append(Vector2(capturer.pos) / Piece.boardSize)
			arrowEnds.append(Vector2(capturee.pos) / Piece.boardSize)
			if capturer.color == Piece.PieceColor.WHITE:
				arrowColorsrg.append(Vector2(whiteCapturerArrowColor.r, whiteCapturerArrowColor.g))
				arrowColorsba.append(Vector2(whiteCapturerArrowColor.b, whiteCapturerArrowColor.a))
			else:
				arrowColorsrg.append(Vector2(blackCapturerArrowColor.r, blackCapturerArrowColor.g))
				arrowColorsba.append(Vector2(blackCapturerArrowColor.b, blackCapturerArrowColor.a))
			arrowThicknesses.append(arrowThickness)
			var arrowMidpoint: Vector2 = (arrowStarts[-1] + arrowEnds[-1]) / 2
			const lengthMultiplier: float = 0.1
			var arrowDisplace: Vector2 = arrowEnds[-1] - arrowStarts[-1]
			arrowDisplace = Vector2(arrowDisplace.y, -arrowDisplace.x)
			arrowDisplace *= lengthMultiplier
			arrowDistortPoints.append(arrowMidpoint + arrowDisplace)

func goToMainMenu(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

var nextButtonWasEnabled: bool
var previousButtonWasEnabled: bool
var loadMenuButtonWasEnabled: bool
func disableAllButtons():
	nextButtonWasEnabled = not nextButton.buttonComponent.state.isDisabled
	previousButtonWasEnabled = not previousButton.buttonComponent.state.isDisabled
	loadMenuButtonWasEnabled = not loadMenuButton.buttonComponent.state.isDisabled
	nextButton.disable()
	previousButton.disable()
	loadMenuButton.disable()

func undisableAllButtons():
	if nextButtonWasEnabled: nextButton.enable()
	if previousButtonWasEnabled: previousButton.enable()
	if loadMenuButtonWasEnabled: loadMenuButton.enable()

func pause(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	print("1")
	if ButtonComponent.justReleased(oldState, newState):
		print("2")
		disableAllButtons()
		
		menu.visible = true
		screenForMenu.color.a = 0.5

func unpause(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		undisableAllButtons()
		
		menu.visible = false
		screenForMenu.color.a = 0.
		
func loadReplay(oldState: ButtonComponent.ButtonState, newState: ButtonComponent.ButtonState):
	if ButtonComponent.justReleased(oldState, newState):
		if enteredReplayStates != []: #double check
			unpause(oldState, newState)
			resetPieces(enteredReplayStates)

var enteredReplayStates: Array[BoardState] = []
@export var invalidColor: Color
@export var validColor: Color
func updateEnteredReplay(newText: String):
	print(newText)
	enteredReplayStates = tryStringToStateList(newText)
	print(len(enteredReplayStates))
	if enteredReplayStates == []:
		menuLoadReplayButton.buttonComponent.disable()
		menuLoadReplayButtonText.add_theme_color_override("font_color", invalidColor)
		menuLoadReplayButtonText.text = "Invalid Replay"
	else:
		menuLoadReplayButton.buttonComponent.enable()
		menuLoadReplayButtonText.add_theme_color_override("font_color", validColor)
		menuLoadReplayButtonText.text = "Load"
