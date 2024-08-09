import 'dart:developer';

import 'package:chess/app/app_assets.dart';
import 'package:chess/models/enums.dart' as en; // Chess Piece as an enum
import 'package:chess/services/helper.dart';
import 'package:stacked/stacked.dart';
import '../models/chess_piece.dart' as model; //Chess Piece as a model
import '../models/position.dart';

class ChessService with ListenableServiceMixin {
  List<List<model.ChessPiece?>>? board;
  final ReactiveValue<model.ChessPiece?> _selectedPiece = ReactiveValue(null);
  final ReactiveValue<Position?> _selectedPosition = ReactiveValue(null);
  final ReactiveValue<en.Variation?> _previousPlayerVariation =
      ReactiveValue(en.Variation.black);
  bool kingInCheck = false;

  //Tracks the possible moves for a selected piece
  final ReactiveValue<List<List<bool>>> validMoves = ReactiveValue(
      List.generate(8, (index) => List.generate(8, (index) => false)));

  model.ChessPiece? get getSelectedPiece => _selectedPiece.value;
  Position? get getSelectedPosition => _selectedPosition.value;
  List<List<bool>> get getHighlightedTiles => validMoves.value;

  //Initialize the chess board
  void init() {
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
          svg: AppAssets.pawnSvg(en.pieceColor.light),
          variation: en.Variation.white);
    }

    //Rooks position
    starting[0][0] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[0][7] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    starting[7][0] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[7][7] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.light),
        variation: en.Variation.white);

    //Knights position
    starting[0][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[0][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    starting[7][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[7][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.light),
        variation: en.Variation.white);

    //Bishops position
    starting[0][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[0][5] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    starting[7][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[7][5] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.light),
        variation: en.Variation.white);

    //Queens position
    starting[0][3] = model.ChessPiece(
        type: en.ChessPiece.queen,
        svg: AppAssets.queenSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[7][4] = model.ChessPiece(
        type: en.ChessPiece.queen,
        svg: AppAssets.queenSvg(en.pieceColor.light),
        variation: en.Variation.white);

    //Kings position
    starting[0][4] = model.ChessPiece(
        type: en.ChessPiece.king,
        svg: AppAssets.kingSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[7][3] = model.ChessPiece(
        type: en.ChessPiece.king,
        svg: AppAssets.kingSvg(en.pieceColor.light),
        variation: en.Variation.white);

    board = starting;
  }

  /// This function runs when a [board] tile is selected
  select(Position position, model.ChessPiece? piece) {
    // Check if tile is empty and moving to the empty tile
    if (board![position.row][position.column] == null &&
        _selectedPiece.value != null &&
        ((validMoves.value)[position.row][position.column] == true)) {
      // Make a move if the king is in check

      updateTilePiece(_selectedPiece.value!, position);

      refreshValidMoves();
    }

    //Check if enemy piece is on the tile and previous selected piece is not null
    else if (board![position.row][position.column] != null &&
        _selectedPiece.value != null &&
        (board![position.row][position.column]!.variation !=
            _selectedPiece.value!.variation) &&
        (validMoves.value)[position.row][position.column]) {
      capturePiece(_selectedPiece.value!, position);
      refreshValidMoves();
    }
    // Check if owner's piece is being tapped
    else if (board![position.row][position.column] != null) {
      // Make sure a user cannot tap his own piece twice in succession
      _selectedPiece.value = piece;

      if (_previousPlayerVariation.value == null ||
          (_selectedPiece.value != null &&
              _previousPlayerVariation.value !=
                  _selectedPiece.value!.variation)) {
        refreshValidMoves();
        _selectedPosition.value = position;

        calculateValidMoves(
            position, piece!.variation, _selectedPiece.value!.type);
      }
    }

    notifyListeners();
  }

  void updateTilePiece(model.ChessPiece piece, Position newPosition) {
    final selectedPiece = _selectedPiece.value;
    final prevPosition = _selectedPosition.value;
    _previousPlayerVariation.value = piece.variation;

    if (selectedPiece != null && prevPosition != null) {
      board![prevPosition.row][prevPosition.column] = null;
      board![newPosition.row][newPosition.column] = selectedPiece;

      _selectedPiece.value = null;
      _selectedPosition.value = null;
    }
  }

  capturePiece(model.ChessPiece piece, Position position) {
    updateTilePiece(piece, position);
  }

  int getDirection(en.Variation variation) {
    return variation == en.Variation.white ? -1 : 1;
  }

  calculateValidMoves(
      Position position, en.Variation variation, en.ChessPiece chessPiece) {
    switch (chessPiece) {
      case en.ChessPiece.pawn:
        possiblePawnMoves(position, variation);
        break;
      case en.ChessPiece.knight:
        possibleKnightMoves(position, variation);
        break;
      case en.ChessPiece.rook:
        possibleRookMoves(position, variation);
        break;
      case en.ChessPiece.bishop:
        possibleBishopMoves(position, variation);
        break;
      case en.ChessPiece.queen:
        possibleQueenMoves(position, variation);
        break;
      case en.ChessPiece.king:
        possibleKingMoves(position, variation);
        break;
    }
  }

  // Check to know if the king is in check
  bool isOpponentKingInCheck(en.Variation variation,
      [Position? possibleKingPosition]) {
    Position? kingPosition = possibleKingPosition;
    List<List<bool>> previousValidMoves = validMoves.value;

    // If possible king's location is not provided then locate the opponent king's position
    if (possibleKingPosition == null) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          if (board![row][col] != null &&
              board![row][col]!.type == en.ChessPiece.king &&
              board![row][col]!.variation != variation) {
            kingPosition = Position(row: row, column: col);
            break;
          }
        }
        if (kingPosition != null) break;
      }

      if (kingPosition == null) return false; // King not found, not in check
    }

    // Check for each type of players piece if it can attack the opponent king's position
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board![row][col] != null &&
            board![row][col]!.variation == variation) {
          Position pos = Position(row: row, column: col);
          refreshValidMoves();
          calculateValidMoves(
              pos, board![row][col]!.variation, board![row][col]!.type);

          if (validMoves.value[kingPosition!.row][kingPosition.column]) {
            return true; // King is in check
          }
        }
      }
    }
    validMoves.value = previousValidMoves;
    return false; // King is not in check
  }

  bool isKingInCheck(en.Variation variation, [Position? possibleKingPosition]) {
    Position? kingPosition = possibleKingPosition;

    // Locate the king's position
    if (kingPosition == null) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          if (board![row][col] != null &&
              board![row][col]!.type == en.ChessPiece.king &&
              board![row][col]!.variation == variation) {
            kingPosition = Position(row: row, column: col);
            break;
          }
        }
        if (kingPosition != null) break;
      }

      if (kingPosition == null) return false; // King not found, not in check
    }

    // Check for each type of opposing piece if it can attack the king's position
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board![row][col] != null &&
            board![row][col]!.variation != variation) {
          Position pos = Position(row: row, column: col);
          refreshValidMoves();
          calculateValidMoves(
              pos, board![row][col]!.variation, board![row][col]!.type);

          if (validMoves.value[kingPosition.row][kingPosition.column]) {
            return true; // King is in check
          }
        }
      }
    }

    return false; // King is not in check
  }

  // Makes no tile to be highlighted
  refreshValidMoves() {
    validMoves.value =
        List.generate(8, (index) => List.generate(8, (index) => false));
    notifyListeners();
  }

  // Function to get possible moves for a Pawn
  possiblePawnMoves(Position position, en.Variation variation) {
    // Move two or one when starting
    if ((position.row == 1 && variation == en.Variation.black) ||
        (position.row == 6 && variation == en.Variation.white)) {
      if (withinBounds(
              position.row + (2 * getDirection(variation)), position.column) &&
          board![position.row + (2 * getDirection(variation))]
                  [position.column] ==
              null) {
        (validMoves.value)[position.row + (2 * getDirection(variation))]
            [position.column] = true;

        notifyListeners();
      }
    }
    // Move only one tile at a time
    if (withinBounds(
            position.row + (1 * getDirection(variation)), position.column) &&
        board![position.row + (1 * getDirection(variation))][position.column] ==
            null) {
      (validMoves.value)[position.row + (1 * getDirection(variation))]
          [position.column] = true;

      notifyListeners();
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
      (validMoves.value)[position.row + (1 * getDirection(variation))]
          [position.column - (1 * getDirection(variation))] = true;
      notifyListeners();
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
      (validMoves.value)[position.row + (1 * getDirection(variation))]
          [position.column + (1 * getDirection(variation))] = true;
      notifyListeners();
    }
  }

  possibleKnightMoves(Position position, en.Variation variation) {
    //Upper right side(1)
    if (withinBounds(position.row - (2), position.column + (1))) {
      if (board![position.row - (2)][position.column + (1)] == null) {
        (validMoves.value)[position.row - (2)][position.column + (1)] = true;
      } else if (board![position.row - (2)][position.column + (1)] != null &&
          (board![position.row - (2)][position.column + (1)]
                      as model.ChessPiece)
                  .variation !=
              variation) {
        (validMoves.value)[position.row - (2)][position.column + (1)] = true;
      }

      notifyListeners();
    }

    //Upper right side(2)
    if (withinBounds(position.row - (1), position.column + (2))) {
      int row = position.row - (1);
      int col = position.column + (2);
      if (board![row][col] == null) {
        (validMoves.value)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
      }

      notifyListeners();
    }

    //Lower right side(2)
    if (withinBounds(position.row + (1), position.column + (2))) {
      int row = position.row + (1);
      int col = position.column + (2);
      if (board![row][col] == null) {
        (validMoves.value)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
      }

      notifyListeners();
    }

    //Lower right side (1)
    if (withinBounds(position.row + (2), position.column + (1))) {
      int row = position.row + (2);
      int col = position.column + (1);
      if (board![row][col] == null) {
        (validMoves.value)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
      }

      notifyListeners();
    }

    // Upper left side(1)
    if (withinBounds(position.row - (2), position.column - (1))) {
      int row = position.row - (2);
      int col = position.column - (1);
      if (board![row][col] == null) {
        (validMoves.value)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
      }

      notifyListeners();
    }

    // Upper left side (2)
    if (withinBounds(position.row - (1), position.column - (2))) {
      int row = position.row - (1);
      int col = position.column - (2);
      if (board![row][col] == null) {
        (validMoves.value)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
      }

      notifyListeners();
    }

    // Lower left side (2)
    if (withinBounds(position.row + (1), position.column - (2))) {
      int row = position.row + (1);
      int col = position.column - (2);
      if (board![row][col] == null) {
        (validMoves.value)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
      }

      notifyListeners();
    }

    // Lower left side (1)
    if (withinBounds(position.row + (2), position.column - (1))) {
      int row = position.row + (2);
      int col = position.column - (1);
      if (board![row][col] == null) {
        (validMoves.value)[row][col] = true;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
      }

      notifyListeners();
    }
  }

  possibleRookMoves(Position position, en.Variation variation) {
    int row = position.row - 1;
    int col = position.column;
    // positive y-axis
    while (withinBounds(row, col)) {
      if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
        break;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row][col] = true;
      row = row - 1;
    }

    // negative y-axis
    int row2 = position.row + 1;
    int col2 = position.column;
    while (withinBounds(row2, col2)) {
      if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row2][col2] = true;
        break;
      } else if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row2][col2] = true;
      row2 = row2 + 1;
    }

    // negative x-axis
    int row3 = position.row;
    int col3 = position.column - 1;
    while (withinBounds(row3, col3)) {
      if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row3][col3] = true;
        break;
      } else if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row3][col3] = true;
      col3 = col3 - 1;
    }

    // positive x-axis
    int row4 = position.row;
    int col4 = position.column + 1;
    while (withinBounds(row4, col4)) {
      if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row4][col4] = true;
        break;
      } else if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row4][col4] = true;
      col4 = col4 + 1;
    }
  }

  possibleBishopMoves(Position position, en.Variation variation) {
    // upper right diagonal
    int row = position.row - 1;
    int col = position.column + 1;

    while (withinBounds(row, col)) {
      if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row][col] = true;
        break;
      } else if (board![row][col] != null &&
          (board![row][col] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row][col] = true;
      row = row - 1;
      col = col + 1;
    }

    // upper left diagonal
    int row2 = position.row - 1;
    int col2 = position.column - 1;

    while (withinBounds(row2, col2)) {
      if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row2][col2] = true;
        break;
      } else if (board![row2][col2] != null &&
          (board![row2][col2] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row2][col2] = true;
      row2 = row2 - 1;
      col2 = col2 - 1;
    }

    // lower right diagonal
    int row3 = position.row + 1;
    int col3 = position.column + 1;

    while (withinBounds(row3, col3)) {
      if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row3][col3] = true;
        break;
      } else if (board![row3][col3] != null &&
          (board![row3][col3] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row3][col3] = true;
      row3 = row3 + 1;
      col3 = col3 + 1;
    }

    // lower left diagonal
    int row4 = position.row + 1;
    int col4 = position.column - 1;

    while (withinBounds(row4, col4)) {
      if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation != variation) {
        (validMoves.value)[row4][col4] = true;
        break;
      } else if (board![row4][col4] != null &&
          (board![row4][col4] as model.ChessPiece).variation == variation) {
        break;
      }
      (validMoves.value)[row4][col4] = true;
      row4 = row4 + 1;
      col4 = col4 - 1;
    }
  }

  possibleQueenMoves(Position position, en.Variation variation) {
    // Straight movements.................
    possibleRookMoves(position, variation);
    // Diagonal movements.................
    possibleBishopMoves(position, variation);
  }

  possibleKingMoves(Position position, en.Variation variation) {
    // Up right diagonal
    if (withinBounds(position.row - 1, position.column + 1)) {
      if (board![position.row - 1][position.column + 1] == null) {
        (validMoves.value)[position.row - 1][position.column + (1)] = true;
      } else if (board![position.row - 1][position.column + (1)] != null &&
          (board![position.row - 1][position.column + (1)] as model.ChessPiece)
                  .variation !=
              variation) {
        // Allow a move only if moving the king does not result in check

        (validMoves.value)[position.row - 1][position.column + (1)] = true;
      }

      notifyListeners();
    }

    // Up
    if (withinBounds(position.row - 1, position.column)) {
      if (board![position.row - 1][position.column] == null) {
        (validMoves.value)[position.row - 1][position.column] = true;
      } else if (board![position.row - 1][position.column] != null &&
          (board![position.row - 1][position.column] as model.ChessPiece)
                  .variation !=
              variation) {
        if (!isKingInCheck(variation)) {
          (validMoves.value)[position.row - 1][position.column] = true;
        }
      }

      notifyListeners();
    }

    // Up left diagonal
    if (withinBounds(position.row - 1, position.column - 1)) {
      if (board![position.row - 1][position.column - 1] == null) {
        (validMoves.value)[position.row - 1][position.column - 1] = true;
      } else if (board![position.row - 1][position.column - 1] != null &&
          (board![position.row - 1][position.column - 1] as model.ChessPiece)
                  .variation !=
              variation) {
        if (!isKingInCheck(variation)) {
          (validMoves.value)[position.row - 1][position.column - 1] = true;
        }
      }

      notifyListeners();
    }

    //down left diagonal
    if (withinBounds(position.row + 1, position.column - 1)) {
      if (board![position.row + 1][position.column - 1] == null) {
        (validMoves.value)[position.row + 1][position.column - 1] = true;
      } else if (board![position.row + 1][position.column - 1] != null &&
          (board![position.row + 1][position.column - 1] as model.ChessPiece)
                  .variation !=
              variation) {
        if (!isKingInCheck(variation)) {
          (validMoves.value)[position.row + 1][position.column - 1] = true;
        }
      }

      notifyListeners();
    }

    //down
    if (withinBounds(position.row + 1, position.column)) {
      if (board![position.row + 1][position.column] == null) {
        (validMoves.value)[position.row + 1][position.column] = true;
      } else if (board![position.row + 1][position.column] != null &&
          (board![position.row + 1][position.column] as model.ChessPiece)
                  .variation !=
              variation) {
        if (!isKingInCheck(variation)) {
          (validMoves.value)[position.row + 1][position.column] = true;
        }
      }

      notifyListeners();
    }

    // down right diagonal
    if (withinBounds(position.row + 1, position.column + 1)) {
      if (board![position.row + 1][position.column + 1] == null) {
        (validMoves.value)[position.row + 1][position.column + 1] = true;
      } else if (board![position.row + 1][position.column + 1] != null &&
          (board![position.row + 1][position.column + 1] as model.ChessPiece)
                  .variation !=
              variation) {
        if (!isKingInCheck(variation)) {
          (validMoves.value)[position.row + 1][position.column + 1] = true;
        }
      }

      notifyListeners();
    }

    // left
    if (withinBounds(position.row, position.column - 1)) {
      if (board![position.row][position.column - 1] == null) {
        (validMoves.value)[position.row][position.column - 1] = true;
      } else if (board![position.row][position.column - 1] != null &&
          (board![position.row][position.column - 1] as model.ChessPiece)
                  .variation !=
              variation) {
        if (!isKingInCheck(variation)) {
          (validMoves.value)[position.row][position.column - 1] = true;
        }
      }

      notifyListeners();
    }

    // right
    if (withinBounds(position.row, position.column + 1)) {
      if (board![position.row][position.column + 1] == null) {
        (validMoves.value)[position.row][position.column + 1] = true;
      } else if (board![position.row][position.column + 1] != null &&
          (board![position.row][position.column + 1] as model.ChessPiece)
                  .variation !=
              variation) {
        if (!isKingInCheck(variation)) {
          (validMoves.value)[position.row][position.column + 1] = true;
        }
      }

      notifyListeners();
    }
  }
}
