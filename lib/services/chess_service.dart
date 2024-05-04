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
          svg: AppAssets.pawnSvg(en.pieceColor.light));
      starting[6][i] = model.ChessPiece(
          type: en.ChessPiece.pawn, svg: AppAssets.pawnSvg(en.pieceColor.dark));
    }

    //Rooks position
    starting[0][0] = model.ChessPiece(
        type: en.ChessPiece.rook, svg: AppAssets.rookSvg(en.pieceColor.light));
    starting[0][7] = model.ChessPiece(
        type: en.ChessPiece.rook, svg: AppAssets.rookSvg(en.pieceColor.light));

    starting[7][0] = model.ChessPiece(
        type: en.ChessPiece.rook, svg: AppAssets.rookSvg(en.pieceColor.dark));
    starting[7][7] = model.ChessPiece(
        type: en.ChessPiece.rook, svg: AppAssets.rookSvg(en.pieceColor.dark));

    //Knights position
    starting[0][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.light));
    starting[0][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.light));

    starting[7][1] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.dark));
    starting[7][6] = model.ChessPiece(
        type: en.ChessPiece.knight,
        svg: AppAssets.knightSvg(en.pieceColor.dark));

    //Bishops position
    starting[0][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.light));
    starting[0][5] = model.ChessPiece(
        type: en.ChessPiece.rook,
        svg: AppAssets.bishopSvg(en.pieceColor.light));

    starting[7][2] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.dark));
    starting[7][5] = model.ChessPiece(
        type: en.ChessPiece.bishop,
        svg: AppAssets.bishopSvg(en.pieceColor.dark));

    //Queens position
    starting[0][3] = model.ChessPiece(
        type: en.ChessPiece.queen,
        svg: AppAssets.queenSvg(en.pieceColor.light));
    starting[7][4] = model.ChessPiece(
        type: en.ChessPiece.queen, svg: AppAssets.queenSvg(en.pieceColor.dark));

    //Kings position
    starting[0][4] = model.ChessPiece(
        type: en.ChessPiece.king, svg: AppAssets.kingSvg(en.pieceColor.light));
    starting[7][3] = model.ChessPiece(
        type: en.ChessPiece.king, svg: AppAssets.kingSvg(en.pieceColor.dark));

    board = starting;
  }

  select(Position position, model.ChessPiece? piece) {
    _selectedPiece.value = piece;
    _selectedPosition.value = position;

    notifyListeners();
  }
}
