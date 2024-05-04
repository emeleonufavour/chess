import 'package:chess/models/enums.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class AppAssets {
  static SvgPicture pawnSvg(pieceColor color) => SvgPicture.asset(
        "assets/pawn.svg",
        color: color.color,
      );

  static SvgPicture rookSvg(pieceColor color) => SvgPicture.asset(
        "assets/rook.svg",
        color: color.color,
      );

  static SvgPicture knightSvg(pieceColor color) => SvgPicture.asset(
        "assets/knight.svg",
        color: color.color,
      );

  static SvgPicture bishopSvg(pieceColor color) => SvgPicture.asset(
        "assets/bishop.svg",
        color: color.color,
      );

  static SvgPicture queenSvg(pieceColor color) => SvgPicture.asset(
        "assets/queen.svg",
        color: color.color,
      );

  static SvgPicture kingSvg(pieceColor color) => SvgPicture.asset(
        "assets/b_king.svg",
        color: color.color,
      );
}
