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
  //Tracks the possible moves for a selected piece
  final ReactiveValue<List<List<bool>>> validMoves = ReactiveValue(
      List.generate(8, (index) => List.generate(8, (index) => false)));

  model.ChessPiece? get getSelectedPiece => _selectedPiece.value;
  Position? get getSelectedPosition => _selectedPosition.value;
  List<List<bool>> get getHighlightedTiles => validMoves.value;

  void init() {
    List<List<model.ChessPiece?>>? starting =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //Pawns position
    for (int i = 0; i < 8; i++) {
      starting[1][i] = model.ChessPiece(
          type: en.ChessPiece.pawn,
          svg: AppAssets.pawnSvg(en.pieceColor.light),
          variation: en.Variation.white);
      starting[6][i] = model.ChessPiece(
          type: en.ChessPiece.pawn,
          svg: AppAssets.pawnSvg(en.pieceColor.dark),
          variation: en.Variation.black);
    }

    //Rooks position
    starting[0][0] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[0][7] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.light),
        variation: en.Variation.white);

    starting[7][0] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[7][7] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.rookSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    //Knights position
    starting[0][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[0][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.light),
        variation: en.Variation.white);

    starting[7][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[7][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    //Bishops position
    starting[0][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[0][5] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.bishopSvg(en.pieceColor.light),
        variation: en.Variation.white);

    starting[7][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.dark),
        variation: en.Variation.black);
    starting[7][5] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    //Queens position
    starting[0][3] = model.ChessPiece(
        type: en.ChessPiece.queen,
        svg: AppAssets.queenSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[7][4] = model.ChessPiece(
        type: en.ChessPiece.queen,
        svg: AppAssets.queenSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    //Kings position
    starting[0][4] = model.ChessPiece(
        type: en.ChessPiece.king,
        svg: AppAssets.kingSvg(en.pieceColor.light),
        variation: en.Variation.white);
    starting[7][3] = model.ChessPiece(
        type: en.ChessPiece.king,
        svg: AppAssets.kingSvg(en.pieceColor.dark),
        variation: en.Variation.black);

    board = starting;
  }

  /// This function runs when a [board] tile is selected
  select(Position position, model.ChessPiece? piece) {
    // Check if tile is empty and moving to the empty tile
    if (board![position.row][position.column] == null &&
        _selectedPiece.value != null &&
        ((validMoves.value)[position.row][position.column] == true)) {
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
    } else if (board![position.row][position.column] != null) {
      refreshValidMoves();
      _selectedPosition.value = position;
      _selectedPiece.value = piece;
      log("Valid move (${position.row},${position.column})? ${(validMoves.value)[position.row][position.column]}");
      calculateValidMoves(position, piece!.variation);
    }
    log("Currently selected piece: ${_selectedPiece.value}");

    notifyListeners();
  }

  void updateTilePiece(model.ChessPiece piece, Position position) {
    final selectedPiece = _selectedPiece.value;
    final prevPosition = _selectedPosition.value;

    if (selectedPiece != null && prevPosition != null) {
      board![prevPosition.row][prevPosition.column] = null;
      board![position.row][position.column] = selectedPiece;

      _selectedPiece.value = null;
      _selectedPosition.value = null;
    }
  }

  capturePiece(model.ChessPiece piece, Position position) {
    updateTilePiece(piece, position);
  }

  int getDirection(en.Variation variation) {
    return variation == en.Variation.white ? 1 : -1;
  }

  calculateValidMoves(Position position, en.Variation variation) {
    possiblePawnMoves(position, variation);
    //log
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
    if ((position.row == 1 && variation == en.Variation.white) ||
        (position.row == 6 && variation == en.Variation.black)) {
      if (withinBounds(
              position.row + (2 * getDirection(variation)), position.column) &&
          board![position.row + (2 * getDirection(variation))]
                  [position.column] ==
              null) {
        (validMoves.value)[position.row + (2 * getDirection(variation))]
            [position.column] = true;
        log("(${position.row + (2 * getDirection(variation))},${position.column}) is valid? ${(validMoves.value)[position.row + (2 * getDirection(variation))][position.column]}");
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
      log("(${position.row + (1 * getDirection(variation))},${position.column}) is valid? ${(validMoves.value)[position.row + (1 * getDirection(variation))][position.column]}");
      notifyListeners();
    }
  }
}
