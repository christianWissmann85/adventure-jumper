import 'package:flutter_test/flutter_test.dart';

void main() {
  test('simple passing test', () {
    print('--- SIMPLE PASSING TEST RUNNING ---');
    expect(1, 1);
    print('--- SIMPLE PASSING TEST COMPLETE ---');
  });

  test('simple failing test', () {
    print('--- SIMPLE FAILING TEST RUNNING ---');
    expect(false, isTrue, reason: 'This is a forced failure in simple_test.dart');
    // This print below won't be reached due to the expect failing
    print('--- SIMPLE FAILING TEST COMPLETE ---'); 
  });
}
