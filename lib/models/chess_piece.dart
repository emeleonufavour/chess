import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chess/models/enums.dart' as en;

class ChessPiece {
  en.ChessPiece type;
  SvgPicture svg;
  en.Variation variation;

  ChessPiece({required this.type, required this.svg, required this.variation});

  @override
  String toString() {
    return "Piece => ${type.string} ${variation.string}";
  }
}
