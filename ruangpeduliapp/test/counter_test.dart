import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/counter.dart';

void main() {
  test('Counter value should be incremented', () {
    final counter = Counter();

    expect(counter.value, 0);

    counter.increment();

    expect(counter.value, 1);
  });
}