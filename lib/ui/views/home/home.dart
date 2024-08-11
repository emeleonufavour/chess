import 'package:chess/app/app_theme.dart';
import 'package:chess/models/enums.dart';
import 'package:chess/ui/views/home/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: const Color(0xff302e2b),
        appBar: AppBar(
          backgroundColor: const Color(0xff302e2b),
        ),
        body: ViewModelBuilder.reactive(
            viewModelBuilder: () => HomeViewModel(),
            onViewModelReady: (viewModel) {
              viewModel.chessService.init();
            },
            builder: (context, model, _) {
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Chess bot
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.02,
                            horizontal: size.width * 0.05),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: size.height * 0.05,
                              backgroundImage:
                                  const AssetImage("assets/png/black_guy.jpeg"),
                            ),
                            SizedBox(
                              width: size.width * 0.05,
                            ),
                            model.chessService.getCheckMate &&
                                    model.chessService.winner == Variation.black
                                ? Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: model.chessService.winner ==
                                                Variation.black
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Text(
                                      model.isBusy
                                          ? "Thinking..."
                                          : model.chessService.winner ==
                                                  Variation.black
                                              ? "Checkmate! I win🙂"
                                              : "Nice game bro",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const Text(
                                    "Bot",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                          ],
                        ),
                      ),

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
                                onTap: () async => await model.select(row, col),
                                child: Stack(children: [
                                  Container(
                                    width: double.maxFinite,
                                    height: double.maxFinite,
                                    color: model.isSelected(row, col)
                                        ? AppColors.selected
                                        : (((row + col) % 2) == 0
                                            ? AppColors.lightTile
                                            : AppColors.darkTile),
                                  ),
                                  if (model.chessService
                                      .getHighlightedTiles[row][col])
                                    Container(
                                      width: double.maxFinite,
                                      height: double.maxFinite,
                                      color:
                                          AppColors.highlight.withOpacity(0.6),
                                    ),
                                  // Check color
                                  if (model.chessService.getCheckedPosition !=
                                          null &&
                                      model.chessService.getCheckedPosition!
                                              .row ==
                                          row &&
                                      model.chessService.getCheckedPosition!
                                              .column ==
                                          col)
                                    Container(
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                        color: Colors.redAccent),
                                  // Chess piece
                                  if (model
                                          .chessService.board![row][col]?.svg !=
                                      null)
                                    model.chessService.board![row][col]!.svg,
                                ]),
                              );
                            }),
                      ),
                      // White player
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05)
                                .copyWith(bottom: size.height * 0.02),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            model.chessService.getCheckMate &&
                                    model.chessService.winner == Variation.black
                                ? Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: model.chessService.winner !=
                                                Variation.black
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Text(
                                      model.chessService.winner !=
                                              Variation.black
                                          ? "Checkmate! I win🙂"
                                          : "Nice game bro",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const Text(
                                    "Player 2",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                            SizedBox(
                              width: size.width * 0.05,
                            ),
                            CircleAvatar(
                              radius: size.height * 0.05,
                              backgroundImage: const AssetImage(
                                  "assets/png/white_face.jpeg"),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: GestureDetector(
                          onTap: () => model.restartGame(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: const Text(
                              "Restart",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}
