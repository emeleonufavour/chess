import 'package:chess/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final AppColors _appColors = AppColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: GridView.builder(
              itemCount: 64,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                return Container(
                  color: ((row + col) % 2) == 0
                      ? _appColors.lightTile
                      : _appColors.darkTile,
                );
              }),
        )
      ],
    ));
  }
}
