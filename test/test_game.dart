import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

class MyTestGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    debugPrint('--- MyTestGame.onLoad ENTERED ---');
    await super.onLoad();
    debugPrint('--- MyTestGame.onLoad COMPLETED ---');
  }
}
