import 'dart:async'; // For Completer
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';

//ignore_for_file: avoid_print

// --- Animation Variables ---
Timer? _animationTimer;
int _wittyMessageIndex = 0;
int _spinnerIndex = 0;
int _messageTickCounter = 0;
const int _ticksPerMessageChange = 20; // e.g., 20 ticks * 200ms/tick = 4 seconds per message

const List<String> _wittyMessages = [
  "Brewing test potions... 🧪",
  "Summoning code spirits... 👻",
  "Polishing the pixels... ✨",
  "Herding bits & bytes... 🐑",
  "Checking for rogue semicolons... 👀",
  "Engaging warp drive (for tests!)... 🚀",
  "Making sure 1+1 still equals 2... 🤔",
  "Dusting off the assertions... 🧹",
  "Running the gauntlet of tests... 🏃💨",
  "Seeking truth in the code matrix... 💻",
  "Assembling the test-asaurus rex... 🦖",
  "Don't blink, or you'll miss the magic! 🪄",
  "Are we there yet? Almost... ⏳",
  "Warming up the hamsters for the test wheel... 🐹",
];

const List<String> _brailleSpinnerChars = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
final AnsiPen _spinnerPen = AnsiPen()..blue();

void _startWittyAnimation() {
  if (!stdout.hasTerminal) return;

  _animationTimer?.cancel(); // Cancel any existing timer (safety)
  _messageTickCounter = 0; // Reset counter
  // Display initial message immediately
  if (stdout.hasTerminal) {
    String initialMessage = _wittyMessages[_wittyMessageIndex];
    String initialSpinnerChar = _brailleSpinnerChars[_spinnerIndex];
    stdout.write('\r\x1B[K${_spinnerPen(initialSpinnerChar)} $initialMessage');
  }

  _animationTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
    _spinnerIndex = (_spinnerIndex + 1) % _brailleSpinnerChars.length;
    _messageTickCounter++;

    if (_messageTickCounter >= _ticksPerMessageChange) {
      _wittyMessageIndex = (_wittyMessageIndex + 1) % _wittyMessages.length;
      _messageTickCounter = 0;
    }
    
    String message = _wittyMessages[_wittyMessageIndex];
    String spinnerChar = _brailleSpinnerChars[_spinnerIndex];
    
    // ANSI escape code to clear the line: \x1B[K
    // \r to return to beginning of line
    stdout.write('\r\x1B[K${_spinnerPen(spinnerChar)} $message'); 
  });
}

void _stopWittyAnimation() {
  _animationTimer?.cancel();
  if (stdout.hasTerminal) {
    stdout.write('\r\x1B[K'); // Clear the line
  }
}
// --- End Animation Variables ---

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('report', abbr: 'r', help: 'Only lists failed tests and their files.', negatable: false)
    ..addFlag('verbose', abbr: 'v', help: 'Show verbose output for tests.', negatable: false)
    ..addFlag('ultra-compact', abbr: 'u', help: 'Shows only a final pass/fail summary, colored.', negatable: false)
    ..addOption('log-file', abbr: 'l', help: 'Redirect all raw test output to the specified file.');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('🚫 Error parsing arguments: ${e.toString()}\n');
    print('Usage: dart tool/test_runner.dart [options] [flutter_test_args_or_paths]\n');
    print(parser.usage);
    exit(64); // Command line usage error
  }

  final isReportMode = argResults['report'] as bool;
  final isVerboseMode = argResults['verbose'] as bool;
  final isUltraCompactMode = argResults['ultra-compact'] as bool;
  final logFilePath = argResults['log-file'] as String?;
  final remainingArgs = argResults.rest;

  final penError = AnsiPen()..red(bold: true);
  final penSuccess = AnsiPen()..green(bold: true);

  int modeFlagsSet = 0;
  if (isReportMode) modeFlagsSet++;
  if (isVerboseMode) modeFlagsSet++;
  if (isUltraCompactMode) modeFlagsSet++;

  if (modeFlagsSet > 1) {
    print(penError('Error: --report, --verbose, and --ultra-compact flags are mutually exclusive.'));
    print(parser.usage);
    exit(64);
  }

  List<String> flutterTestArgs = [];
  int exitCode = 0;
  IOSink? logFileSink;
  StreamSubscription<String>? stdoutLogSub, stderrLogSub;

  if (logFilePath != null) {
    try {
      final logFile = File(logFilePath);
      logFileSink = logFile.openWrite(mode: FileMode.append);
      logFileSink.writeln('\n--- New Test Run: ${DateTime.now()} ---');
      logFileSink.writeln('Command: dart tool/test_runner.dart ${arguments.join(' ')}\n');
    } catch (e) {
      print(penError('📄❌ Error opening log file "$logFilePath": $e'));
      logFileSink = null; // Ensure it's null if opening failed
    }
  }

  final List<Map<String, dynamic>> failures = [];
  int testsRunCount = 0;
  int testsPassedCount = 0;

  final flutterCommand = Platform.isWindows ? 'flutter.bat' : 'flutter';

  final bool showAnimation = (isUltraCompactMode || isReportMode) && !isVerboseMode;
  if (showAnimation) {
    _startWittyAnimation();
  }

  try {
    if (isReportMode) {
    if (!isUltraCompactMode) print('Running tests in report mode 📋 (json output, parsed for failures)...');
    flutterTestArgs.addAll(['-r', 'json']);
    flutterTestArgs.addAll(remainingArgs);

    final process = await Process.start(flutterCommand, ['test', ...flutterTestArgs]);

    final Map<int, String> suiteIdToPath = {};
    final Map<int, Map<String, dynamic>> testIdToDetails = {};
    
    final reportJsonCompleter = Completer<void>();
    
    process.stdout.transform(utf8.decoder).transform(LineSplitter()).listen(
      (line) {
        logFileSink?.writeln(line);
        try {
          final event = jsonDecode(line) as Map<String, dynamic>;
          final type = event['type'] as String?;

          if (type == 'suite') {
            final suite = event['suite'] as Map<String, dynamic>?;
            if (suite != null) {
              suiteIdToPath[suite['id'] as int] = suite['path'] as String;
            }
          } else if (type == 'testStart') {
            final test = event['test'] as Map<String, dynamic>?;
            if (test != null && (test['hidden'] as bool? ?? false) == false) {
                 testsRunCount++; // Count only non-hidden tests
            }
            if (test != null) {
                 testIdToDetails[test['id'] as int] = {
                    'name': test['name'] as String,
                    'suiteID': test['suiteID'] as int,
                 };
            }
          } else if (type == 'testDone') {
            final result = event['result'] as String?;
            final skipped = event['skipped'] as bool? ?? false;
            final hidden = event['hidden'] as bool? ?? false;
            final testID = event['testID'] as int;

            if (!hidden && !skipped && result == 'success') {
              testsPassedCount++;
            }

            if (!hidden && !skipped && result != 'success') {
              final testDetails = testIdToDetails[testID];
              if (testDetails != null) {
                final suitePath = suiteIdToPath[testDetails['suiteID'] as int];
                failures.add({
                  'name': testDetails['name'],
                  'path': suitePath,
                  'error': event['error'] as String? ?? 'Unknown error',
                  'stackTrace': event['stackTrace'] as String? ?? 'No stack trace available.',
                });
              }
            }
          } else if (type == 'allSuites') {
            // This event could provide total test count, but we sum `testStart` for non-hidden tests.
          }
        } catch (e) {
          if (!isUltraCompactMode) print(penError('💔 Error processing JSON: $e for line: $line'));
        }
      },
      onDone: () => reportJsonCompleter.complete(),
      onError: (e) {
        if (!isUltraCompactMode) print(penError('🌊 Error on stdout stream for report: $e'));
        if (!reportJsonCompleter.isCompleted) reportJsonCompleter.completeError(e);
      },
    );
    
    // Capture stderr for report mode (usually for critical errors from the test runner itself)
    final reportStderrCompleter = Completer<void>();
    process.stderr.transform(utf8.decoder).transform(LineSplitter()).listen(
      (line) {
        logFileSink?.writeln(line);
        if (!isUltraCompactMode) print(penError(line)); // Show critical errors
      },
      onDone: () => reportStderrCompleter.complete(),
      onError: (e) {
         if (!isUltraCompactMode) print(penError('🌊 Error on stderr stream for report: $e'));
         if(!reportStderrCompleter.isCompleted) reportStderrCompleter.completeError(e);
      },
    );

    await Future.wait([reportJsonCompleter.future, reportStderrCompleter.future]).catchError((_) => []);
    exitCode = await process.exitCode;

    if (!isUltraCompactMode) {
      if (failures.isNotEmpty) {
        print('\n🔍 --- FAILED TESTS DETAILS --- 🔍');
        for (final failure in failures) {
          print('File: ${failure['path']}');
          print('Test: ${failure['name']}');
          print('Error: ${failure['error']}');
          print('Stack:');
          print(failure['stackTrace']);
          print('');
        }
        print('\n📊 --- TEST SUMMARY --- 📊');
        print(penError('😬 ${failures.length} of $testsRunCount tests failed.'));
      } else if (exitCode == 0) {
        print('\n📊 --- TEST SUMMARY --- 📊');
        print(penSuccess('🎉 $testsPassedCount of $testsRunCount tests passed. All clear!'));
      } else {
        print('\n📊 --- TEST SUMMARY --- 📊');
        print(penError('🤔 Test run completed with exit code $exitCode, but no specific failures were parsed. $testsPassedCount/$testsRunCount passed.'));
      }
    }

  } else { // Normal, Verbose, or UltraCompact (if not report mode)
    if (isVerboseMode) {
      if (!isUltraCompactMode) print('Running tests in verbose mode 📢...');
      flutterTestArgs.add('--verbose');
    } else if (isUltraCompactMode) {
      // For ultra-compact non-report, use compact reporter to minimize console noise if not logging.
      // If logging, the full output (default reporter) goes to the file.
      if (logFileSink == null) flutterTestArgs.addAll(['-r', 'compact']);
    } else { // Normal mode
      print('Running tests in normal mode ⚙️ (expanded output)...');
      flutterTestArgs.addAll(['-r', 'expanded']);
    }
    flutterTestArgs.addAll(remainingArgs);

    final process = await Process.start(flutterCommand, ['test', ...flutterTestArgs]);

    final stdoutCompleter = Completer<void>();
    stdoutLogSub = process.stdout.transform(utf8.decoder).transform(LineSplitter()).listen(
      (line) {
        logFileSink?.writeln(line);
        if (!isUltraCompactMode) stdout.writeln(line);
      },
      onDone: () => stdoutCompleter.complete(),
      onError: (e) {
        if (!isUltraCompactMode) print(penError('🌊 Error on stdout stream: $e'));
        if(!stdoutCompleter.isCompleted) stdoutCompleter.completeError(e);
      },
    );

    final stderrCompleter = Completer<void>();
    stderrLogSub = process.stderr.transform(utf8.decoder).transform(LineSplitter()).listen(
      (line) {
        logFileSink?.writeln(line);
        if (!isUltraCompactMode) stderr.writeln(penError(line)); // Errors in red
      },
      onDone: () => stderrCompleter.complete(),
      onError: (e) {
        if (!isUltraCompactMode) print(penError('🌊 Error on stderr stream: $e'));
        if(!stderrCompleter.isCompleted) stderrCompleter.completeError(e);
      },
    );
    
    await Future.wait([stdoutCompleter.future, stderrCompleter.future]).catchError((_) => []); 
    exitCode = await process.exitCode;
  }



  // Ensure logs are written before exiting
  await stdoutLogSub?.cancel();
  await stderrLogSub?.cancel();
  await logFileSink?.flush();
  await logFileSink?.close();

  } finally {
    if (showAnimation) {
      _stopWittyAnimation();
    }
  }

  // Print final summary for ultra-compact mode AFTER stopping animation
  if (isUltraCompactMode) {
    if (exitCode == 0) {
      final countText = isReportMode ? '$testsPassedCount/$testsRunCount' : "All";
      print(penSuccess('✅ $countText tests passed!'));
    } else {
      final failureText = isReportMode ? '${failures.length} of $testsRunCount' : "Some";
      print(penError('❌ $failureText tests failed.'));
    }
  }

  exit(exitCode);
}
