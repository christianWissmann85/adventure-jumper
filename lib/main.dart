import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/game/adventure_jumper_game.dart';
import 'src/utils/debug_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize debug infrastructure
  await Debug.initialize(
    enableDebugMode: kDebugMode,
    enableVerboseLogging: kDebugMode,
    enableInGameConsole: kDebugMode,
    enableVisualDebugging: kDebugMode,
    enablePerformanceTracking: kDebugMode,
  );

  runApp(const AdventureJumperApp());
}

class AdventureJumperApp extends StatelessWidget {
  const AdventureJumperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adventure Jumper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameWidget<AdventureJumperGame>.controlled(
        gameFactory: AdventureJumperGame.new,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
