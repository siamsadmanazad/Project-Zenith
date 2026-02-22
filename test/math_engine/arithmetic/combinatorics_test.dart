import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/arithmetic/combinatorics.dart';

void main() {
  group('Factorial', () {
    test('0! = 1', () => expect(Combinatorics.factorial(0), 1));
    test('1! = 1', () => expect(Combinatorics.factorial(1), 1));
    test('5! = 120', () => expect(Combinatorics.factorial(5), 120));
    test('10! = 3628800', () => expect(Combinatorics.factorial(10), 3628800));
    test('negative throws', () {
      expect(() => Combinatorics.factorial(-1), throwsArgumentError);
    });
  });

  group('Permutation', () {
    test('5P3 = 60', () => expect(Combinatorics.permutation(5, 3), 60));
    test('5P0 = 1', () => expect(Combinatorics.permutation(5, 0), 1));
    test('5P5 = 120', () => expect(Combinatorics.permutation(5, 5), 120));
    test('invalid throws', () {
      expect(() => Combinatorics.permutation(3, 5), throwsArgumentError);
    });
  });

  group('Combination', () {
    test('5C3 = 10', () => expect(Combinatorics.combination(5, 3), 10));
    test('5C0 = 1', () => expect(Combinatorics.combination(5, 0), 1));
    test('5C5 = 1', () => expect(Combinatorics.combination(5, 5), 1));
    test('10C4 = 210', () => expect(Combinatorics.combination(10, 4), 210));
  });
}
