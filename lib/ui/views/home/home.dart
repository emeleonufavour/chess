import 'package:chess/app/app_theme.dart';
import 'package:chess/ui/views/home/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../models/position.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ViewModelBuilder.reactive(
            viewModelBuilder: () => HomeViewModel(),
            onViewModelReady: (viewModel) {
              viewModel.chessService.init();
            },
            builder: (context, model, _) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GridView.builder(
                          itemCount: 64,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8),
                          itemBuilder: (context, index) {
                            int row = index ~/ 8;
                            int col = index % 8;

                            return GestureDetector(
                              onTap: () => model.select(row, col),
                              child: Container(
                                color: model.isSelected(row, col)
                                    ? AppColors.selected
                                    : model.chessService
                                            .getHighlightedTiles[row][col]
                                        ? AppColors.highlight
                                        : (((row + col) % 2) == 0
                                            ? AppColors.lightTile
                                            : AppColors.darkTile),
                                child: model.chessService.board![row][col]?.svg,
                              ),
                            );
                          }),
                    )
                  ],
                ),
              );
            }));
  }
}
