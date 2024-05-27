extends RefCounted
class_name Replay

static func validateBoardStateForReplay(startingState: BoardState, moves: Array[Move]) -> bool: #true if good, false if bad
	if !startingState.result in [BoardState.StateResult.VALID, BoardState.StateResult.DRAW]:
		print("bad1")
		return false
	if len(startingState.capturedPieces) != 0:
		print("bad2")
		return false
	for piece in startingState.pieces:
		if piece.hasMoved:
			print("bad3")
			return false
		if piece.pos.x < 0 or piece.pos.x > Piece.boardSize or piece.pos.y < 0 or piece.pos.y > Piece.boardSize:
			print("bad4")
			return false
	var currentState: BoardState = startingState
	for move in moves:
		if currentState.result != BoardState.StateResult.VALID:
			print("bad5")
			return false
		currentState = currentState.makeMove(move)
	if not currentState.result in [BoardState.StateResult.VALID, BoardState.StateResult.DRAW, BoardState.StateResult.WIN_WHITE, BoardState.StateResult.WIN_BLACK]:
		print("bad6 ", currentState.result)
	return currentState.result in [BoardState.StateResult.VALID, BoardState.StateResult.DRAW, BoardState.StateResult.WIN_WHITE, BoardState.StateResult.WIN_BLACK]

static func validBoardStateToBitArray(state: BoardState) -> BitArray:
	var arr: BitArray = BitArray.new()
	var i: int = 0
	
	#read in version length as ubyte
	arr.changeLength(i + 8)
	arr.setFromInt(i, 8, 1) #version 1
	i += 8
	
	#get starting state and all moves that have happened in the game
	var moves: Array[Move] = []
	var states: Array[BoardState] = [state]
	var startingState: BoardState = state
	while startingState.previousState != null:
		moves.append(startingState.previousMove)
		states.append(startingState.previousState)
		startingState = startingState.previousState
	moves.reverse()
	states.reverse()
	
	#validate state
	if !validateBoardStateForReplay(startingState, moves):
		return null
	
	#read in startsettings
	arr.changeLength(i + 3)
	arr.setFromInt(i, 2, int(startingState.startSettings.assistMode))
	i += 2
	arr.setFromInt(i, 1, 1 if startingState.startSettings.isTimed else 0)
	i += 1
	if startingState.startSettings.isTimed:
		arr.changeLength(i + 64)
		arr.setFromFloat(i, startingState.startSettings.startingTime)
		i += 64
	
	#read in starting state of board
	#read in number of pieces
	arr.changeLength(i + 8)
	arr.setFromInt(i, 8, len(startingState.pieces))
	i += 8
	
	#read in all pieces in the order of their length being specified
	for piece in startingState.pieces:
		arr.changeLength(i + 36)
		arr.setFromInt(i, 1, int(piece.color)) #2 options for col, so 1 byte
		i += 1
		arr.setFromInt(i, 3, int(piece.type)) #7 options for type, so 3 bytes
		i += 3
		arr.setFromInt(i, 16, piece.pos.x) #16 bytes for x pos and y pos each
		i += 16
		arr.setFromInt(i, 16, piece.pos.y)
		i += 16
	
	#read in number of states updates
	arr.changeLength(i + 32)
	arr.setFromInt(i, 32, len(moves))
	i += 32
	
	#read in first "state update"
	arr.changeLength(i + 67)
	arr.setFromInt(i, 3, int(startingState.drawState)) #7 options for draw state, so 3 bytes
	i += 3
	arr.changeLength(i + 64)
	if startingState.turnToMove == Piece.PieceColor.WHITE:
		arr.setFromFloat(i, startingState.whiteTime)
	else:
		arr.setFromFloat(i, startingState.blackTime)
	i += 64
	
	#read in all moves
	for moveI in range(len(moves)):
		var move: Move = moves[moveI]
		var state_: BoardState = states[moveI + 1]
		
		arr.changeLength(i + 2)
		arr.setFromInt(i, 2, int(move.moveType)) #3 options for type, so 2 bytes
		i += 2
		match move.moveType:
			Move.MoveType.NORMAL:
				arr.changeLength(i + 40)
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedPiece)) #8 bytes for index of moved piece
				i += 8
				arr.setFromInt(i, 16, move.posTryMovedTo.x) #16 bytes for x pos and y pos each
				i += 16
				arr.setFromInt(i, 16, move.posTryMovedTo.y)
				i += 16
			Move.MoveType.PROMOTION:
				arr.changeLength(i + 43)
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedPiece)) #8 bytes for index of moved piece
				i += 8
				arr.setFromInt(i, 16, move.posTryMovedTo.x) #16 bytes for x pos and y pos each
				i += 16
				arr.setFromInt(i, 16, move.posTryMovedTo.y)
				i += 16
				arr.setFromInt(i, 3, int(move.promotingTo)) #7 options for type, so 3 bytes
				i += 3
			Move.MoveType.CASTLE:
				arr.changeLength(i + 16)
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedKing))
				i += 8
				arr.setFromInt(i, 8, state_.previousState.findPieceIndex(move.movedRook))
				i += 8
		
		arr.changeLength(i + 67)
		arr.setFromInt(i, 3, int(state_.drawState)) #7 options for draw state, so 3 bytes
		i += 3
		arr.changeLength(i + 64)
		if state_.turnToMove == Piece.PieceColor.WHITE:
			arr.setFromFloat(i, state_.whiteTime)
		else:
			arr.setFromFloat(i, state_.blackTime)
		i += 64
	return arr

static func bitArrayToValidBoardState(arr: BitArray) -> BoardState:
	var i: int = 0
	
	#read in version
	var versionNum: int = arr.getToInt(i, 8)
	i += 8
	if versionNum != 1:
		print("b1")
		return null #only v1 replays allowed
	
	#read in start settings
	var assistModeInt: int = arr.getToInt(i, 2)
	i += 2
	if assistModeInt < 0 or assistModeInt > 2:
		print("b2")
		return null #invalid assist mode
	var isTimedInt: int = arr.getToInt(i, 1)
	i += 1
	if isTimedInt < 0 or isTimedInt > 1:
		print("b3")
		return null
	var isTimed = true if isTimedInt == 1 else false
	var startingTime: float = -1
	if isTimed:
		startingTime = arr.getToFloat(i)
		i += 64
		if startingTime < 0:
			print("b4")
			return null #no negative starting time
	var startSettings: BoardState.StartSettings = BoardState.StartSettings.new(
		assistModeInt as BoardState.StartSettings.AssistMode, isTimed, startingTime
	)
	
	#read in number of pieces
	var numPieces: int = arr.getToInt(i, 8)
	i += 8
	if numPieces < 0:
		print("b5")
		return null
	
	#read in pieces
	var pieces: Array[Piece] = []
	for pieceI in range(numPieces):
		var colorInt: int = arr.getToInt(i, 1)
		i += 1
		if colorInt < 0:
			print("b6")
			return null
		var typeInt: int = arr.getToInt(i, 3)
		i += 3
		if typeInt < 0 or typeInt > 7:
			print("b7")
			return null
		var posX: int = arr.getToInt(i, 16)
		i += 16
		if posX < 0 or posX > Piece.boardSize:
			print("b8")
			return null
		var posY: int = arr.getToInt(i, 16)
		i += 16
		if posY < 0 or posY > Piece.boardSize:
			print("b9")
			return null
		var pos: Vector2i = Vector2i(posX, posY)
		var piece: Piece = Piece.new(
			pos, 
			typeInt as Piece.PieceType, 
			colorInt as Piece.PieceColor, 
			false)
		pieces.append(piece)
	
	#construct first state
	var startingState: BoardState = BoardState.newStartingState(pieces, startSettings)
	
	#read in number of state updates
	var numStateUpdates: int = arr.getToInt(i, 32)
	i += 32
	if numStateUpdates < 0:
		print("b10")
		return null
	
	#read in first state update
	var firstDrawStateInt: int = arr.getToInt(i, 3)
	i += 3
	if firstDrawStateInt < 0 or firstDrawStateInt > 7:
		print("b11")
		return null
	var firstNewTime: float = arr.getToFloat(i)
	i += 64
	startingState.updateTimer(firstNewTime)
	if startingState.drawState in [BoardState.DrawState.BLACK_OFFERED_ACCEPTED, BoardState.DrawState.WHITE_OFFERED_REJECTED]:
		startingState.result = BoardState.StateResult.DRAW
	if numStateUpdates == 0:
		if !startingState.result in [BoardState.StateResult.VALID, BoardState.StateResult.DRAW, BoardState.StateResult.WIN_WHITE, BoardState.StateResult.WIN_BLACK]:
			print("b12", " ", BoardState.StateResult.keys()[startingState.result])
			return null
	else:
		if startingState.result != BoardState.StateResult.VALID:
			print("b13")
			return null
	
	#read in state updates
	var states: Array[BoardState] = [startingState]
	for stateI in range(numStateUpdates):
		var moveTypeInt: int = arr.getToInt(i, 2)
		i += 2
		if moveTypeInt < 0 or moveTypeInt > 3:
			print("b14")
			return null
		var move: Move
		match moveTypeInt:
			int(Move.MoveType.NORMAL):
				var pieceIndex: int = arr.getToInt(i, 8)
				i += 8
				if pieceIndex < 0 or pieceIndex >= len(states[-1].pieces):
					print("b15")
					return null
				var piece: Piece = states[-1].pieces[pieceIndex]
				var posTryMovedToX: int = arr.getToInt(i, 16)
				i += 16
				if posTryMovedToX < 0:
					print("b16")
					return null
				var posTryMovedToY: int = arr.getToInt(i, 16)
				i += 16
				if posTryMovedToY < 0:
					print("b17")
					return null
				var posTryMovedTo: Vector2i = Vector2i(posTryMovedToX, posTryMovedToY)
				move = Move.newNormal(piece, posTryMovedTo)
			int(Move.MoveType.PROMOTION):
				var pieceIndex: int = arr.getToInt(i, 8)
				i += 8
				if pieceIndex < 0 or pieceIndex >= len(states[-1].pieces):
					print("b18")
					return null
				var piece: Piece = states[-1].pieces[pieceIndex]
				var posTryMovedToX: int = arr.getToInt(i, 16)
				i += 16
				if posTryMovedToX < 0:
					print("b19")
					return null
				var posTryMovedToY: int = arr.getToInt(i, 16)
				i += 16
				if posTryMovedToY < 0:
					print("b20")
					return null
				var posTryMovedTo: Vector2i = Vector2i(posTryMovedToX, posTryMovedToY)
				var promotingToInt: int = arr.getToInt(i, 3)
				i += 3
				if promotingToInt < 0 or promotingToInt > 7:
					print("b21")
					return null
				move = Move.newPromotion(piece, posTryMovedTo, promotingToInt)
			int(Move.MoveType.CASTLE):
				var kingIndex: int = arr.getToInt(i, 8)
				i += 8
				if kingIndex < 0 or kingIndex >= len(states[-1].pieces):
					print("b22")
					return null
				var king: Piece = states[-1].pieces[kingIndex]
				var rookIndex: int = arr.getToInt(i, 8)
				i += 8
				if rookIndex < 0 or rookIndex >= len(states[-1].pieces):
					print("b23")
					return null
				var rook: Piece = states[-1].pieces[rookIndex]
				move = Move.newCastle(king, rook)
		var nextState: BoardState = states[-1].makeMove(move)
		var drawStateInt: int = arr.getToInt(i, 3)
		i += 3
		if drawStateInt < 0 or drawStateInt > 7:
			print("b24")
			return null
		var newTime: float = arr.getToFloat(i)
		i += 64
		nextState.updateTimer(newTime)
		nextState.drawState = drawStateInt as BoardState.DrawState #manually setting draw state lmao
		if nextState.drawState in [BoardState.DrawState.BLACK_OFFERED_ACCEPTED, BoardState.DrawState.WHITE_OFFERED_REJECTED]:
			nextState.result = BoardState.StateResult.DRAW
		if stateI == numStateUpdates - 1:
			if !nextState.result in [BoardState.StateResult.VALID, BoardState.StateResult.DRAW, BoardState.StateResult.WIN_WHITE, BoardState.StateResult.WIN_BLACK]:
				print("b25")
				return null
		else:
			if nextState.result != BoardState.StateResult.VALID:
				print("b26")
				return null
		states.append(nextState)
	return states[-1]
