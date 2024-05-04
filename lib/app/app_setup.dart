import 'package:chess/services/chess_service.dart';
import 'package:stacked/stacked_annotations.dart';

@StackedApp(routes: [], dependencies: [LazySingleton(classType: ChessService)])
class AppSetup {}
