import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chess/models/enums.dart' as en;

class ChessPiece {
  en.ChessPiece type;
  SvgPicture svg;
  en.Variation variation;
  bool? ableToCastle = false;

  ChessPiece({
    required this.type,
    required this.svg,
    required this.variation,
    this.ableToCastle,
  });

  @override
  String toString() {
    return "Piece => ${type.string} ${variation.string} ableToCastle: $ableToCastle";
  }
}
