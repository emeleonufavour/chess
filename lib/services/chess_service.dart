import 'dart:developer';

import 'package:chess/app/app_assets.dart';
import 'package:chess/models/enums.dart' as en; // Chess Piece as an enum
import 'package:stacked/stacked.dart';
import '../models/chess_piece.dart' as model; //Chess Piece as a model
import '../models/position.dart';

class ChessService with ListenableServiceMixin {
  List<List<model.ChessPiece?>>? board;
  final ReactiveValue<model.ChessPiece?> _selectedPiece = ReactiveValue(null);
  final ReactiveValue<Position?> _selectedPosition = ReactiveValue(null);

  model.ChessPiece? get getSelectedPiece => _selectedPiece.value;
  Position? get getSelectedPosition => _selectedPosition.value;

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
    // Check if tile is empty
    if (board![position.row][position.column] == null &&
        _selectedPiece.value != null) {
      updateTilePiece(_selectedPiece.value!, position);
    }
    //Check if enemy piece is on the tile and previous selected piece is not null
    else if (board![position.row][position.column] != null &&
        _selectedPiece.value != null &&
        (board![position.row][position.column]!.variation !=
            _selectedPiece.value!.variation)) {
      capturePiece(_selectedPiece.value!, position);
    } else {
      _selectedPosition.value = position;
      _selectedPiece.value = piece;
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
}
