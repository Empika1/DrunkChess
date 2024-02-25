extends RefCounted
class_name BoardLogic

static func doPiecesOverlap(pos1: Vector2i, radius1: int, pos2: Vector2i, radius2: int) -> bool:
	var x_diff: int = abs(pos1.x - pos2.x)
	var y_diff: int = abs(pos1.y - pos2.y)
	var distance_squared: int = x_diff * x_diff + y_diff * y_diff

	var sum_radii: int = radius1 + radius2
	var sum_radii_squared: int = sum_radii ** 2

	return distance_squared < sum_radii_squared

static func isPieceOutsideBoard(pos: Vector2i, radius: int, maxPos: Vector2i) -> bool:
	return pos.x - radius < 0 or pos.y - radius < 0 or pos.x + radius > maxPos.x or pos.y + radius > maxPos.y

static func validateStartingState(state: BoardState) -> BoardState.StateResult:
	for piece: Piece in state.pieces:
		if isPieceOutsideBoard(piece.pos, piece.hitRadius, Vector2i(Piece.boardSize, Piece.boardSize)):
			return BoardState.StateResult.START_PIECE_OUTSIDE_BOARD
			
	for i in range(state.pieces.size()):
		var piece1: Piece = state.pieces[i]
		for j in range(i + 1, state.pieces.size()):
			var piece2: Piece = state.pieces[j]
			if doPiecesOverlap(piece1.pos, piece1.hitRadius, piece2.pos, piece2.hitRadius):
				return BoardState.StateResult.START_PIECE_OVERLAPS_PIECE
	
	var whiteKingCount: int = 0
	var blackKingCount: int = 0
	for piece: Piece in state.pieces:
		if piece.type == Piece.PieceType.KING:
			if piece.color == Piece.PieceColor.WHITE:
				whiteKingCount += 1
			else:
				blackKingCount += 1
		
		if whiteKingCount > 1:
			return BoardState.StateResult.START_MULTIPLE_WHITE_KINGS
		if blackKingCount > 1:
			return BoardState.StateResult.START_MULTIPLE_BLACK_KINGS
	
	if whiteKingCount == 0:
		return BoardState.StateResult.START_NO_WHITE_KING
	if blackKingCount == 0:
		return BoardState.StateResult.START_NO_BLACK_KING
		
	return BoardState.StateResult.VALID

static func validateNormalMove(state: BoardState, move: Move) -> BoardState.StateResult:
	if move.movedPiece.color != state.turnToMove:
		return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_WRONG_COLOR
		
	if isPieceOutsideBoard(move.posMovedTo, move.movedPiece.hitRadius, Vector2i(Piece.boardSize, Piece.boardSize)):
		return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_OUTSIDE_BOARD
	
	var pieceFound: bool = false
	for piece: Piece in state.pieces:
		if piece.valueEquals(move.movedPiece):
			pieceFound = true
			break
	if not pieceFound:
		return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_DOESNT_EXIST
		
	for piece: Piece in state.pieces:
		if piece.valueEquals(move.movedPiece):
			continue
		if piece.color == move.movedPiece.color:
			if doPiecesOverlap(piece.pos, piece.hitRadius, move.posMovedTo, move.movedPiece.hitRadius):
				return BoardState.StateResult.MOVE_ONE_PIECE_MOVED_PIECE_OVERLAPS_PIECE_OF_SAME_COLOR

	return BoardState.StateResult.VALID

static func makeMove(state: BoardState, move: Move) -> BoardState:
	var newState: BoardState = state.duplicate()
	newState.previousState = state
	match move.moveType:
		Move.MoveType.NORMAL:
			var result: BoardState.StateResult = validateNormalMove(newState, move)
			newState.result = result
			for piece: Piece in newState.pieces:
				if piece.valueEquals(move.movedPiece):
					piece.pos = move.posMovedTo
					piece.hasMoved = true
			
			var capturedPieceIndices: Array[int] = []
			for i: int in range(newState.pieces.size()):
				var piece: Piece = newState.pieces[i]
				if piece.color != move.movedPiece.color:
					if doPiecesOverlap(piece.pos, piece.hitRadius, move.posMovedTo, move.movedPiece.hitRadius):
						capturedPieceIndices.append(i)
			
			for i: int in range(capturedPieceIndices.size() - 1, -1, -1):
				var pieceIndex: int = capturedPieceIndices[i]
				newState.capturedPieces.append(newState.pieces[pieceIndex])
				newState.pieces.pop_at(pieceIndex)
			
			newState.turnToMove = (1 - newState.turnToMove) as Piece.PieceColor
			return newState
		_:
			return newState
