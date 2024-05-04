import 'package:chess/app/app_theme.dart';
import 'package:chess/ui/views/home/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final AppColors _appColors = AppColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ViewModelBuilder.reactive(
            viewModelBuilder: () => HomeViewModel(),
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
                            return Container(
                              color: ((row + col) % 2) == 0
                                  ? _appColors.lightTile
                                  : _appColors.darkTile,
                            );
                          }),
                    )
                  ],
                ),
              );
            }));
  }
}
