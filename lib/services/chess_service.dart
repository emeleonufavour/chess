import 'dart:developer';
import 'dart:math' as math;

import 'package:chess/app/app_assets.dart';
import 'package:chess/models/enums.dart' as en; // Chess Piece as an enum
import 'package:chess/services/helper.dart';

import 'package:stacked/stacked.dart';
import '../models/chess_piece.dart' as model; //Chess Piece as a model
import '../models/move.dart';
import '../models/move_history.dart';
import '../models/position.dart';
import 'chess_bot.dart';

class ChessService with ListenableServiceMixin {
  List<List<model.ChessPiece?>>? board;
  List<MoveHistory> moveHistory = [];
  ChessBot? bot;
  final ReactiveValue<model.ChessPiece?> _selectedPiece = ReactiveValue(null);
  final ReactiveValue<Position?> _selectedPosition = ReactiveValue(null);
  Map<String, int> whiteKingPosition = {"row": 7, "col": 4};
  Map<String, int> blackKingPosition = {"row": 0, "col": 3};
  final ReactiveValue<en.Variation> _previousPlayerVariation =
      ReactiveValue(en.Variation.white);
  final ReactiveValue<bool> check = ReactiveValue(false);
  final ReactiveValue<bool> checkMate = ReactiveValue(false);
  Position? checkedPosition;
  en.Variation? winner;

  //Tracks the possible moves for a selected piece
  final ReactiveValue<List<List<bool>>> validMoves = ReactiveValue(
      List.generate(8, (index) => List.generate(8, (index) => false)));

  model.ChessPiece? get getSelectedPiece => _selectedPiece.value;
  Position? get getSelectedPosition => _selectedPosition.value;
  List<List<bool>> get getHighlightedTiles => validMoves.value;
  Position? get getCheckedPosition => checkedPosition;
  bool get getCheck => check.value;
  bool get getCheckMate => checkMate.value;
  en.Variation get getPreviousPlayerVariation => _previousPlayerVariation.value;

  initializeValues() {
    checkMate.value = false;
    check.value = false;
    checkedPosition = null;
    winner = null;
    whiteKingPosition = {"row": 7, "col": 4};
    blackKingPosition = {"row": 0, "col": 3};
    _selectedPiece.value = null;
    _selectedPosition.value = null;
    _previousPlayerVariation.value = en.Variation.white;
    bot = ChessBot(this, en.Variation.black);
    notifyListeners();
  }

  //Initialize the chess board
  void init() {
    initializeValues();
    List<List<model.ChessPiece?>>? starting =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //Pawns position
    for (int i = 0; i < 8; i++) {
      starting[1][i] = model.ChessPiece(
          type: en.ChessPiece.pawn,
          svg: AppAssets.pawnSvg(en.pieceColor.dark),
          variation: en.Variation.black);
      starting[6][i] = model.ChessPiece(
          type: en.ChessPiece.pawn,
          svg: AppAssets.whitePawnSvg(),
          variation: en.Variation.white);
    }

    //Rooks position
    starting[0][0] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.blackRookSvg(),
        ableToCastle: true,
        variation: en.Variation.black);
    starting[0][7] = model.ChessPiece(
        type: en.ChessPiece.rook,
        ableToCastle: true,
        svg: AppAssets.blackRookSvg(),
        variation: en.Variation.black);

    starting[7][0] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.whiteRookSvg(),
        ableToCastle: true,
        variation: en.Variation.white);
    starting[7][7] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.whiteRookSvg(),
        ableToCastle: true,
        variation: en.Variation.white);

    //Knights position
    starting[0][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.blackKnightSvg(),
        variation: en.Variation.black);
    starting[0][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.blackKnightSvg(),
        variation: en.Variation.black);

    starting[7][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.whiteKnightSvg(),
        variation: en.Variation.white);
    starting[7][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.whiteKnightSvg(),
        variation: en.Variation.white);

    //Bishops position
    starting[0][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.blackBishopSvg(),
        variation: en.Variation.black);
    starting[0][5] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.blackBishopSvg(),
        variation: en.Variation.black);

    starting[7][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.whiteBishopSvg(),
        variation: en.Variation.white);
    starting[7][5] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.whiteBishopSvg(),
        variation: en.Variation.white);

    //Queens position
    starting[0][3] = model.ChessPiece(
        type: en.ChessPiece.queen,
        svg: AppAssets.blackQueenSvg(),
        variation: en.Variation.black);
    starting[7][3] = model.ChessPiece(
        type: en.ChessPiece.queen,
        svg: AppAssets.whiteQueenSvg(),
        variation: en.Variation.white);

    //Kings position
    starting[0][4] = model.ChessPiece(
        type: en.ChessPiece.king,
        svg: AppAssets.blackkingSvg(),
        ableToCastle: true,
        variation: en.Variation.black);
    starting[7][4] = model.ChessPiece(
        type: en.ChessPiece.king,
        svg: AppAssets.whitekingSvg(),
        ableToCastle: true,
        variation: en.Variation.white);

    board = starting;
  }

  /// This function runs when a [board] tile is selected
  Future<void> select(Position position, model.ChessPiece? piece) async {
    // Only allow selection if it's the player's turn
    if (_previousPlayerVariation.value != bot?.botColor) {
      if (piece != null && piece.variation == _previousPlayerVariation.value) {
        _selectedPiece.value = piece;
        _selectedPosition.value = position;
        validMoves.value = calculateValidMoves(position, piece.variation);
        notifyListeners();
      } else if (_selectedPiece.value != null &&
          validMoves.value[position.row][position.column]) {
        await makeMove(_selectedPosition.value!, position);
        clearSelection();
      }
    }
  }

  void clearSelection() {
    _selectedPiece.value = null;
    _selectedPosition.value = null;
    validMoves.value = List.generate(8, (_) => List.generate(8, (_) => false));
    notifyListeners();
  }

  bool isValidMove(Position from, Position to) {
    if (board?[from.row][from.column] == null) return false;
    List<List<bool>> validMoves =
        calculateValidMoves(from, board![from.row][from.column]!.variation);
    return validMoves[to.row][to.column];
  }

  // This function runs check before a board tile can be updated with a piece
  Future<void> makeMove(Position from, Position to) async {
    if (isValidMove(from, to)) {
      model.ChessPiece movingPiece = board![from.row][from.column]!;
      model.ChessPiece? capturedPiece = board![to.row][to.column];
      bool? prevCastlingRights = movingPiece.ableToCastle;

      // Save move to history
      moveHistory.add(MoveHistory(
          from, to, movingPiece, capturedPiece, prevCastlingRights));

      // Handle castling
      if (movingPiece.type == en.ChessPiece.king &&
          (to.column - from.column).abs() == 2) {
        int rookFromCol = to.column > from.column ? 7 : 0;
        int rookToCol = to.column > from.column ? to.column - 1 : to.column + 1;

        board![to.row][rookToCol] = board![from.row][rookFromCol];
        board![from.row][rookFromCol] = null;
        board![to.row][rookToCol]!.ableToCastle = false;
      }

      // Move the piece
      board![to.row][to.column] = movingPiece;
      board![from.row][from.column] = null;

      // Update king position if necessary
      if (movingPiece.type == en.ChessPiece.king) {
        if (movingPiece.variation == en.Variation.white) {
          whiteKingPosition = {"row": to.row, "col": to.column};
        } else {
          blackKingPosition = {"row": to.row, "col": to.column};
        }
      }

      // Remove ability to castle if necessary
      if (movingPiece.type == en.ChessPiece.king ||
          movingPiece.type == en.ChessPiece.rook) {
        movingPiece.ableToCastle = false;
      }

      // Switch to the next player
      _previousPlayerVariation.value =
          movingPiece.variation == en.Variation.white
              ? en.Variation.black
              : en.Variation.white;

      // Check for check and checkmate
      en.Variation opponentVariation =
          movingPiece.variation == en.Variation.white
              ? en.Variation.black
              : en.Variation.white;
      Position kingPosition = opponentVariation == en.Variation.white
          ? Position(
              row: whiteKingPosition["row"]!, column: whiteKingPosition["col"]!)
          : Position(
              row: blackKingPosition["row"]!,
              column: blackKingPosition["col"]!);

      check.value = isPositionUnderAttack(kingPosition, opponentVariation);
      checkMate.value = isCheckmate(opponentVariation);

      if (checkMate.value) {
        winner = movingPiece.variation;
        // log("Checkmate! ${movingPiece.variation} wins!");
      } else if (check.value) {
        checkedPosition = kingPosition;
        // log("Check!");
      } else {
        checkedPosition = null;
      }

      notifyListeners();

      // Add a small delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 100));

      // If it's now the bot's turn, make the bot move
      if (_previousPlayerVariation.value == bot?.botColor) {
        await makeBotMove();
      }
    }
  }

  void undoMove() {
    if (moveHistory.isEmpty) return;

    MoveHistory lastMove = moveHistory.removeLast();

    // Restore the board state
    board![lastMove.from.row][lastMove.from.column] = lastMove.movedPiece;
    board![lastMove.to.row][lastMove.to.column] = lastMove.capturedPiece;

    // Restore king positions if necessary
    if (lastMove.movedPiece.type == en.ChessPiece.king) {
      if (lastMove.movedPiece.variation == en.Variation.white) {
        whiteKingPosition = {
          "row": lastMove.from.row,
          "col": lastMove.from.column
        };
      } else {
        blackKingPosition = {
          "row": lastMove.from.row,
          "col": lastMove.from.column
        };
      }
    }

    // Restore castling rights if necessary
    if (lastMove.movedPiece.type == en.ChessPiece.king ||
        lastMove.movedPiece.type == en.ChessPiece.rook) {
      lastMove.movedPiece.ableToCastle = lastMove.prevCastlingRights;
    }

    // Switch back to the previous player
    _previousPlayerVariation.value = lastMove.movedPiece.variation;

    notifyListeners();
  }

  bool canCastle(
      Position kingPosition, Position rookPosition, en.Variation variation) {
    // Check if the positions are valid and the pieces exist
    if (!withinBounds(kingPosition.row, kingPosition.column) ||
        !withinBounds(rookPosition.row, rookPosition.column) ||
        board![kingPosition.row][kingPosition.column] == null ||
        board![rookPosition.row][rookPosition.column] == null) {
      return false;
    }

    // Check if both King and Rook have not moved
    if (board![kingPosition.row][kingPosition.column]!.ableToCastle != true ||
        board![rookPosition.row][rookPosition.column]!.ableToCastle != true) {
      return false;
    }

    // Cancel if both King and Rook have moved
    if (!board![kingPosition.row][kingPosition.column]!.ableToCastle! ||
        !board![rookPosition.row][rookPosition.column]!.ableToCastle!) {
      return false;
    }

    // Confirm if the path to castle is clear
    int start = math.min(kingPosition.column, rookPosition.column) + 1;
    int end = math.max(kingPosition.column, rookPosition.column);
    for (int col = start; col < end; col++) {
      if (board![kingPosition.row][col] != null) {
        return false;
      }
    }

    // Cancel if the king is currently in check
    if (isPositionUnderAttack(kingPosition, variation)) {
      return false;
    }

    // Cacnel if the king passes through or ends up in check
    int direction = kingPosition.column < rookPosition.column ? 1 : -1;
    for (int i = 0; i <= 2; i++) {
      Position position = Position(
          row: kingPosition.row, column: kingPosition.column + i * direction);
      if (isPositionUnderAttack(position, variation)) {
        return false;
      }
    }

    return true;
  }

  void updateTilePiece(model.ChessPiece piece, Position newPosition) {
    final selectedPiece = _selectedPiece.value;
    final prevPosition = _selectedPosition.value;
    _previousPlayerVariation.value = piece.variation;

    // For updating a board tile in the case the previous occupant of the tile is captured
    if (selectedPiece != null && prevPosition != null) {
      board![prevPosition.row][prevPosition.column] = null;
      board![newPosition.row][newPosition.column] = selectedPiece;

      _selectedPiece.value = null;
      _selectedPosition.value = null;
    }

    // Remove ability to castle if a valid party is being moved
    if (piece.type == en.ChessPiece.king || piece.type == en.ChessPiece.rook) {
      board![newPosition.row][newPosition.column]!.ableToCastle = false;
    }

    // Update king position variable for fast memory access to king location
    if (piece.type == en.ChessPiece.king) {
      if (piece.variation == en.Variation.black) {
        blackKingPosition["row"] = newPosition.row;
        blackKingPosition["col"] = newPosition.column;
      }
      if (piece.variation == en.Variation.white) {
        whiteKingPosition["row"] = newPosition.row;
        whiteKingPosition["col"] = newPosition.column;
      }
    }
  }

  // This function handles capturing a piece on the board
  capturePiece(Position from, Position to) {
    makeMove(from, to);
  }

  int getDirection(en.Variation variation) {
    return variation == en.Variation.white ? -1 : 1;
  }

  List<List<bool>> calculateValidMoves(
      Position position, en.Variation variation) {
    List<List<bool>> validMoves =
        List.generate(8, (_) => List.generate(8, (_) => false));
    model.ChessPiece? chessPiece = board![position.row][position.column];
    if (chessPiece == null) return validMoves;

    List<List<bool>>? potentialMoves;
    switch (chessPiece.type) {
      case en.ChessPiece.pawn:
        potentialMoves = possiblePawnMoves(position, variation);
        break;
      case en.ChessPiece.knight:
        potentialMoves = possibleKnightMoves(position, variation);
        break;
      case en.ChessPiece.rook:
        potentialMoves = possibleRookMoves(position, variation);
        break;
      case en.ChessPiece.bishop:
        potentialMoves = possibleBishopMoves(position, variation);
        break;
      case en.ChessPiece.queen:
        potentialMoves = possibleQueenMoves(position, variation);
        break;
      case en.ChessPiece.king:
        potentialMoves = possibleKingMoves(position, variation);
        break;
    }

    // Finds the current position of the king
    Position kingPosition = variation == en.Variation.black
        ? Position(
            row: blackKingPosition["row"]!, column: blackKingPosition["col"]!)
        : Position(
            row: whiteKingPosition["row"]!, column: whiteKingPosition["col"]!);

    // Filters out moves that would leave the king in check
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (potentialMoves[i][j]) {
          // Try the move
          model.ChessPiece? capturedPiece = board![i][j];
          board![i][j] = board![position.row][position.column];
          board![position.row][position.column] = null;

          // Update king position if the king was moved
          Position newKingPosition = (chessPiece.type == en.ChessPiece.king)
              ? Position(row: i, column: j)
              : kingPosition;

          // Check if the king is under attack after this move
          bool kingUnderAttack =
              isPositionUnderAttack(newKingPosition, variation);

          // Undo the move
          board![position.row][position.column] = board![i][j];
          board![i][j] = capturedPiece;

          // If this move doesn't leave the king under attack, it's valid
          if (!kingUnderAttack) {
            validMoves[i][j] = true;
          }
        }
      }
    }

    return validMoves;
  }

  // Makes no tile to be highlighted
  refreshValidMoves() {
    validMoves.value =
        List.generate(8, (index) => List.generate(8, (index) => false));
    notifyListeners();
  }

  // Function to get possible moves for a Pawn
  List<List<bool>> possiblePawnMoves(
      Position position, en.Variation variation) {
    List<List<bool>> _validMoves =
        List.generate(8, (index) => List.generate(8, (index) => false));
    // Move two or one when starting
    if ((position.row == 1 && variation == en.Variation.black) ||
        (position.row == 6 && variation == en.Variation.white)) {
      if (withinBounds(
              position.row + (2 * getDirection(variation)), position.column) &&
          board![position.row + (2 * getDirection(variation))]
                  [position.column] ==
              null) {
        (_validMoves)[position.row + (2 * getDirection(variation))]
            [position.column] = true;

        // notifyListeners();
      }
    }
    // Move only one tile at a time
    if (withinBounds(
            position.row + (1 * getDirection(variation)), position.column) &&
        board![position.row + (1 * getDirection(variation))][position.column] ==
            null) {
      (_validMoves)[position.row + (1 * getDirection(variation))]
          [position.column] = true;

      // notifyListeners();
    }

    //capture opponent in left(white) or right(black) adjacent box
    if (withinBounds(position.row + (1 * getDirection(variation)),
            position.column - (1 * getDirection(variation))) &&
        board![position.row + (1 * getDirection(variation))]
                [position.column - (1 * getDirection(variation))] !=
            null &&
        (board![position.row + (1 * getDirection(variation))]
                        [position.column - (1 * getDirection(variation))]
                    as model.ChessPiece)
                .variation !=
            variation) {
      (_validMoves)[position.row + (1 * getDirection(variation))]
          [position.column - (1 * getDirection(variation))] = true;
      // notifyListeners();
    }

    //capture opponent in right(white) or left(black) adjacent box
    if (withinBounds(position.row + (1 * getDirection(variation)),
            position.column + (1 * getDirection(variation))) &&
        board![position.row + (1 * getDirection(variation))]
                [position.column + (1 * getDirection(variation))] !=
            null &&
        (board![position.row + (1 * getDirection(variation))]
                        [position.column + (1 * getDirection(variation))]
                    as model.ChessPiece)
                .variation !=
            variation) {
      (_validMoves)[position.row + (1 * getDirection(variation))]
          [position.column + (1 * getDirection(variation))] = true;
      // notifyListeners();
    }
    return _validMoves;
  }

  List<List<bool>> possibleKnightMoves(
      Position position, en.Variation variation) {
    List<List<bool>> knightValidMoves =
        List.generate(8, (index) => List.generate(8, (index) => false));
    //Upper right side(1)
    if (withinBounds(position.row - (2), position.column + (1))) {
      if (board![position.row - (2)][position.column + (1)] == null) {
        (knightValidMoves)[position.row - (2)][position.column + (1)] = true;
      } else if (board![position.row - (2)][position.column + (1)] != null &&
          (board![position.row - (2)][position.column + (1)]
                      as model.ChessPiece)
                  .variation !=
              variation) {
        (knightValidMoves)[position.row - (2)][position.column + (1)] = true;
      }

      // notifyListeners();
    }

    //Upper right side(2)
    if (withinBounds(position.row - (1), position.column + (2))) {
      int row = position.row - (1);
      int col = position.column + (2);
      if (board![row][col] == null) {
        (knightValidMoves)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (knightValidMoves)[row][col] = true;
      }

      // notifyListeners();
    }

    //Lower right side(2)
    if (withinBounds(position.row + (1), position.column + (2))) {
      int row = position.row + (1);
      int col = position.column + (2);
      if (board![row][col] == null) {
        (knightValidMoves)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (knightValidMoves)[row][col] = true;
      }

      // notifyListeners();
    }

    //Lower right side (1)
    if (withinBounds(position.row + (2), position.column + (1))) {
      int row = position.row + (2);
      int col = position.column + (1);
      if (board![row][col] == null) {
        (knightValidMoves)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (knightValidMoves)[row][col] = true;
      }

      // notifyListeners();
    }

    // Upper left side(1)
    if (withinBounds(position.row - (2), position.column - (1))) {
      int row = position.row - (2);
      int col = position.column - (1);
      if (board![row][col] == null) {
        (knightValidMoves)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (knightValidMoves)[row][col] = true;
      }

      // notifyListeners();
    }

    // Upper left side (2)
    if (withinBounds(position.row - (1), position.column - (2))) {
      int row = position.row - (1);
      int col = position.column - (2);
      if (board![row][col] == null) {
        (knightValidMoves)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (knightValidMoves)[row][col] = true;
      }

      // notifyListeners();
    }

    // Lower left side (2)
    if (withinBounds(position.row + (1), position.column - (2))) {
      int row = position.row + (1);
      int col = position.column - (2);
      if (board![row][col] == null) {
        (knightValidMoves)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (knightValidMoves)[row][col] = true;
      }

      // notifyListeners();
    }

    // Lower left side (1)
    if (withinBounds(position.row + (2), position.column - (1))) {
      int row = position.row + (2);
      int col = position.column - (1);
      if (board![row][col] == null) {
        (knightValidMoves)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (knightValidMoves)[row][col] = true;
      }

      // notifyListeners();
    }
    return knightValidMoves;
  }

  List<List<bool>> possibleRookMoves(Position position, en.Variation variation,
      [List<List<bool>>? pieceValidMoves]) {
    int row = position.row - 1;
    int col = position.column;
    List<List<bool>>? rookValidMoves = pieceValidMoves;
    rookValidMoves ??=
        List.generate(8, (index) => List.generate(8, (index) => false));

    // positive y-axis
    while (withinBounds(row, col)) {
      if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (rookValidMoves)[row][col] = true;
        break;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation == variation) {
        break;
      }
      (rookValidMoves)[row][col] = true;
      row = row - 1;
    }

    // negative y-axis
    int row2 = position.row + 1;
    int col2 = position.column;
    while (withinBounds(row2, col2)) {
      if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation != variation) {
        (rookValidMoves)[row2][col2] = true;
        break;
      } else if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation == variation) {
        break;
      }
      (rookValidMoves)[row2][col2] = true;
      row2 = row2 + 1;
    }

    // negative x-axis
    int row3 = position.row;
    int col3 = position.column - 1;
    while (withinBounds(row3, col3)) {
      if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation != variation) {
        (rookValidMoves)[row3][col3] = true;
        break;
      } else if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation == variation) {
        break;
      }
      (rookValidMoves)[row3][col3] = true;
      col3 = col3 - 1;
    }

    // positive x-axis
    int row4 = position.row;
    int col4 = position.column + 1;
    while (withinBounds(row4, col4)) {
      if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation != variation) {
        (rookValidMoves)[row4][col4] = true;
        break;
      } else if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation == variation) {
        break;
      }
      (rookValidMoves)[row4][col4] = true;
      col4 = col4 + 1;
    }
    return rookValidMoves;
  }

  List<List<bool>> possibleBishopMoves(
      Position position, en.Variation variation,
      [List<List<bool>>? pieceValidMoves]) {
    // upper right diagonal
    int row = position.row - 1;
    int col = position.column + 1;
    List<List<bool>>? bishopValidMoves = pieceValidMoves;
    bishopValidMoves ??=
        List.generate(8, (index) => List.generate(8, (index) => false));

    while (withinBounds(row, col)) {
      if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (bishopValidMoves)[row][col] = true;
        break;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation == variation) {
        break;
      }
      (bishopValidMoves)[row][col] = true;
      row = row - 1;
      col = col + 1;
    }

    // upper left diagonal
    int row2 = position.row - 1;
    int col2 = position.column - 1;

    while (withinBounds(row2, col2)) {
      if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation != variation) {
        (bishopValidMoves)[row2][col2] = true;
        break;
      } else if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation == variation) {
        break;
      }
      (bishopValidMoves)[row2][col2] = true;
      row2 = row2 - 1;
      col2 = col2 - 1;
    }

    // lower right diagonal
    int row3 = position.row + 1;
    int col3 = position.column + 1;

    while (withinBounds(row3, col3)) {
      if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation != variation) {
        (bishopValidMoves)[row3][col3] = true;
        break;
      } else if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation == variation) {
        break;
      }
      (bishopValidMoves)[row3][col3] = true;
      row3 = row3 + 1;
      col3 = col3 + 1;
    }

    // lower left diagonal
    int row4 = position.row + 1;
    int col4 = position.column - 1;

    while (withinBounds(row4, col4)) {
      if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation != variation) {
        (bishopValidMoves)[row4][col4] = true;
        break;
      } else if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation == variation) {
        break;
      }
      (bishopValidMoves)[row4][col4] = true;
      row4 = row4 + 1;
      col4 = col4 - 1;
    }
    return bishopValidMoves;
  }

  List<List<bool>> possibleQueenMoves(
      Position position, en.Variation variation) {
    List<List<bool>> queenValidMoves =
        List.generate(8, (index) => List.generate(8, (index) => false));
    // Straight movements.................
    possibleRookMoves(position, variation, queenValidMoves);
    // Diagonal movements.................
    possibleBishopMoves(position, variation, queenValidMoves);
    return queenValidMoves;
  }

  List<List<bool>> possibleKingMoves(
      Position position, en.Variation variation) {
    List<List<bool>> kingValidMoves =
        List.generate(8, (index) => List.generate(8, (index) => false));

    List<Position> potentialMoves = [
      Position(row: position.row - 1, column: position.column + 1),
      Position(row: position.row - 1, column: position.column),
      Position(row: position.row - 1, column: position.column - 1),
      Position(row: position.row, column: position.column - 1),
      Position(row: position.row, column: position.column + 1),
      Position(row: position.row + 1, column: position.column + 1),
      Position(row: position.row + 1, column: position.column),
      Position(row: position.row + 1, column: position.column - 1),
    ];

    for (var move in potentialMoves) {
      if (withinBounds(move.row, move.column)) {
        bool isMoveValid = (board![move.row][move.column] == null ||
            (board![move.row][move.column] != null &&
                (board![move.row][move.column] as model.ChessPiece).variation !=
                    variation));

        if (isMoveValid) {
          if (!isPositionUnderAttack(move, variation)) {
            kingValidMoves[move.row][move.column] = true;
          }
        }
      }
    }

    // Check if castling is possible
    if (board![position.row][position.column]?.ableToCastle == true) {
      // Kingside castling
      Position kingsideRook = Position(row: position.row, column: 7);
      if (withinBounds(kingsideRook.row, kingsideRook.column) &&
          canCastle(position, kingsideRook, variation)) {
        kingValidMoves[position.row][position.column + 2] = true;
      }

      // Queenside castling
      Position queensideRook = Position(row: position.row, column: 0);
      if (withinBounds(queensideRook.row, queensideRook.column) &&
          canCastle(position, queensideRook, variation)) {
        kingValidMoves[position.row][position.column - 2] = true;
      }
    }

    return kingValidMoves;
  }

  bool isPositionUnderAttack(Position position, en.Variation variation) {
    // Check for pawn attacks
    int pawnDirection = (variation == en.Variation.white) ? -1 : 1;
    List<Position> pawnAttacks = [
      Position(row: position.row + pawnDirection, column: position.column - 1),
      Position(row: position.row + pawnDirection, column: position.column + 1),
    ];

    for (var attack in pawnAttacks) {
      if (withinBounds(attack.row, attack.column) &&
          board![attack.row][attack.column] != null &&
          board![attack.row][attack.column]!.type == en.ChessPiece.pawn &&
          board![attack.row][attack.column]!.variation != variation) {
        return true;
      }
    }

    // Check for knight attacks
    List<Position> knightMoves = [
      Position(row: position.row - 2, column: position.column - 1),
      Position(row: position.row - 2, column: position.column + 1),
      Position(row: position.row - 1, column: position.column - 2),
      Position(row: position.row - 1, column: position.column + 2),
      Position(row: position.row + 1, column: position.column - 2),
      Position(row: position.row + 1, column: position.column + 2),
      Position(row: position.row + 2, column: position.column - 1),
      Position(row: position.row + 2, column: position.column + 1),
    ];

    for (var move in knightMoves) {
      if (withinBounds(move.row, move.column) &&
          board![move.row][move.column] != null &&
          board![move.row][move.column]!.type == en.ChessPiece.knight &&
          board![move.row][move.column]!.variation != variation) {
        return true;
      }
    }

    // Check for attacks along ranks, files, and diagonals (rook, bishop, queen)
    List<List<int>> directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1], // Rook directions
      [-1, -1], [-1, 1], [1, -1], [1, 1], // Bishop directions
    ];

    for (var direction in directions) {
      int r = position.row + direction[0];
      int c = position.column + direction[1];
      while (withinBounds(r, c)) {
        if (board![r][c] != null) {
          if (board![r][c]!.variation != variation) {
            if ((board![r][c]!.type == en.ChessPiece.rook &&
                    direction[0] * direction[1] == 0) ||
                (board![r][c]!.type == en.ChessPiece.bishop &&
                    direction[0] * direction[1] != 0) ||
                board![r][c]!.type == en.ChessPiece.queen) {
              return true;
            }
          }
          break;
        }
        r += direction[0];
        c += direction[1];
      }
    }

    return false;
  }

  bool isCheckmate(en.Variation variation) {
    Position kingPosition = variation == en.Variation.black
        ? Position(
            row: blackKingPosition["row"]!, column: blackKingPosition["col"]!)
        : Position(
            row: whiteKingPosition["row"]!, column: whiteKingPosition["col"]!);

    // First, check if the king is in check
    if (!isPositionUnderAttack(kingPosition, variation)) {
      return false;
    }

    // Check all pieces of the current player
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board![row][col] != null &&
            board![row][col]!.variation == variation) {
          Position currentPosition = Position(row: row, column: col);
          List<List<bool>> possibleMoves =
              calculateValidMoves(currentPosition, variation);

          // Check if any of these moves can get the king out of check
          for (int i = 0; i < 8; i++) {
            for (int j = 0; j < 8; j++) {
              if (possibleMoves[i][j]) {
                // Try the move
                model.ChessPiece? capturedPiece = board![i][j];
                board![i][j] = board![row][col];
                board![row][col] = null;

                // Update king position if the king was moved
                if (board![i][j]!.type == en.ChessPiece.king) {
                  kingPosition = Position(row: i, column: j);
                }

                // Check if the king is still under attack after this move
                bool stillUnderAttack =
                    isPositionUnderAttack(kingPosition, variation);

                // Undo the move
                board![row][col] = board![i][j];
                board![i][j] = capturedPiece;

                // If this move gets the king out of check, it's not checkmate
                if (!stillUnderAttack) {
                  return false;
                }
              }
            }
          }
        }
      }
    }

    // If we've checked all possible moves and none get the king out of check, it's checkmate
    return true;
  }

  // Chess bot helper functions...
  int evaluateBoard() {
    int score = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board![row][col] != null) {
          score +=
              getPieceValue(board![row][col]!, Position(row: row, column: col));
        }
      }
    }
    return score;
  }

  int getPieceValue(model.ChessPiece piece, Position position) {
    int baseValue;
    switch (piece.type) {
      case en.ChessPiece.pawn:
        baseValue = 10;
        break;
      case en.ChessPiece.knight:
      case en.ChessPiece.bishop:
        baseValue = 30;
        break;
      case en.ChessPiece.rook:
        baseValue = 50;
        break;
      case en.ChessPiece.queen:
        baseValue = 90;
        break;
      case en.ChessPiece.king:
        baseValue = 900;
        break;
    }

    // Add position-based adjustments here

    return piece.variation == en.Variation.white ? baseValue : -baseValue;
  }

  Future<void> makeBotMove() async {
    try {
      Move bestMove = bot!.findBestMove(1); // Search 3 moves ahead
      await makeMove(bestMove.from, bestMove.to);
    } catch (e) {
      log("Error in makeBotMove: $e");
      // Handle the error appropriately, e.g., end the game or skip the bot's turn
    }
  }
}
