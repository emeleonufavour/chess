import 'package:chess/models/enums.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class AppAssets {
  static SvgPicture pawnSvg(pieceColor color) => SvgPicture.asset(
        "assets/pawn.svg",
        color: color.color,
      );
  static SvgPicture whitePawnSvg() => SvgPicture.asset("assets/white_pawn.svg");

  // static SvgPicture rookSvg(pieceColor color) => SvgPicture.asset(
  //       "assets/rook.svg",
  //       color: color.color,
  //     );
  static SvgPicture whiteRookSvg() => SvgPicture.asset("assets/white_rook.svg");
  static SvgPicture blackRookSvg() => SvgPicture.asset("assets/black_rook.svg");

  // static SvgPicture knightSvg(pieceColor color) => SvgPicture.asset(
  //       "assets/knight.svg",
  //       color: color.color,
  //     );
  static SvgPicture whiteKnightSvg() =>
      SvgPicture.asset("assets/white_knight.svg");

  static SvgPicture blackKnightSvg() =>
      SvgPicture.asset("assets/black_knight.svg");

  // static SvgPicture bishopSvg(pieceColor color) => SvgPicture.asset(
  //       "assets/bishop.svg",
  //       color: color.color,
  //     );
  static SvgPicture whiteBishopSvg() =>
      SvgPicture.asset("assets/white_bishop.svg");

  static SvgPicture blackBishopSvg() =>
      SvgPicture.asset("assets/black_bishop.svg");

  // static SvgPicture queenSvg(pieceColor color) => SvgPicture.asset(
  //       "assets/queen.svg",
  //       color: color.color,
  //     );
  static SvgPicture whiteQueenSvg() =>
      SvgPicture.asset("assets/white_queen.svg");

  static SvgPicture blackQueenSvg() =>
      SvgPicture.asset("assets/black_queen.svg");

  static SvgPicture whitekingSvg() => SvgPicture.asset("assets/white_king.svg");

  static SvgPicture blackkingSvg() => SvgPicture.asset("assets/black_king.svg");
}
