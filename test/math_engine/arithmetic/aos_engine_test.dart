import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/arithmetic/aos_engine.dart';

void main() {
  late AOSEngine engine;

  setUp(() {
    engine = AOSEngine();
  });

  group('Basic arithmetic', () {
    test('2 + 3 = 5', () {
      engine.pushOperand(2);
      engine.pushOperator('+');
      engine.pushOperand(3);
      expect(engine.evaluate(), 5.0);
    });

    test('10 - 4 = 6', () {
      engine.pushOperand(10);
      engine.pushOperator('-');
      engine.pushOperand(4);
      expect(engine.evaluate(), 6.0);
    });

    test('6 * 7 = 42', () {
      engine.pushOperand(6);
      engine.pushOperator('*');
      engine.pushOperand(7);
      expect(engine.evaluate(), 42.0);
    });

    test('15 / 3 = 5', () {
      engine.pushOperand(15);
      engine.pushOperator('/');
      engine.pushOperand(3);
      expect(engine.evaluate(), 5.0);
    });

    test('division by zero throws', () {
      engine.pushOperand(10);
      engine.pushOperator('/');
      engine.pushOperand(0);
      expect(() => engine.evaluate(), throwsArgumentError);
    });
  });

  group('Operator precedence (AOS)', () {
    test('2 + 3 * 4 = 14 (not 20)', () {
      engine.pushOperand(2);
      engine.pushOperator('+');
      engine.pushOperand(3);
      engine.pushOperator('*');
      engine.pushOperand(4);
      expect(engine.evaluate(), 14.0);
    });

    test('10 - 6 / 2 = 7', () {
      engine.pushOperand(10);
      engine.pushOperator('-');
      engine.pushOperand(6);
      engine.pushOperator('/');
      engine.pushOperand(2);
      expect(engine.evaluate(), 7.0);
    });

    test('2 * 3 + 4 * 5 = 26', () {
      engine.pushOperand(2);
      engine.pushOperator('*');
      engine.pushOperand(3);
      engine.pushOperator('+');
      engine.pushOperand(4);
      engine.pushOperator('*');
      engine.pushOperand(5);
      expect(engine.evaluate(), 26.0);
    });
  });

  group('Parentheses', () {
    test('(2 + 3) * 4 = 20', () {
      engine.openParen();
      engine.pushOperand(2);
      engine.pushOperator('+');
      engine.pushOperand(3);
      engine.closeParen();
      engine.pushOperator('*');
      engine.pushOperand(4);
      expect(engine.evaluate(), 20.0);
    });

    test('nested: ((2 + 3) * (4 - 1)) = 15', () {
      engine.openParen();
      engine.openParen();
      engine.pushOperand(2);
      engine.pushOperator('+');
      engine.pushOperand(3);
      engine.closeParen();
      engine.pushOperator('*');
      engine.openParen();
      engine.pushOperand(4);
      engine.pushOperator('-');
      engine.pushOperand(1);
      engine.closeParen();
      engine.closeParen();
      expect(engine.evaluate(), 15.0);
    });
  });

  group('Power operator', () {
    test('2 ^ 10 = 1024', () {
      engine.pushOperand(2);
      engine.pushOperator('^');
      engine.pushOperand(10);
      expect(engine.evaluate(), 1024.0);
    });
  });

  group('Clear', () {
    test('clear resets engine', () {
      engine.pushOperand(5);
      engine.pushOperator('+');
      engine.pushOperand(3);
      engine.evaluate();
      engine.clear();
      expect(engine.hasOperands, false);
      expect(engine.lastResult, null);
      expect(engine.resultDisplayed, false);
    });
  });

  group('Intermediate results', () {
    test('pushOperator returns intermediate for same-precedence ops', () {
      engine.pushOperand(2);
      engine.pushOperator('+');
      engine.pushOperand(3);
      // Pushing another + should flush 2+3=5
      final intermediate = engine.pushOperator('+');
      expect(intermediate, 5.0);
    });
  });

  group('nPr and nCr', () {
    test('5 P 3 = 60', () {
      engine.pushOperand(5);
      engine.pushOperator('P');
      engine.pushOperand(3);
      expect(engine.evaluate(), 60.0);
    });

    test('5 C 3 = 10', () {
      engine.pushOperand(5);
      engine.pushOperator('C');
      engine.pushOperand(3);
      expect(engine.evaluate(), 10.0);
    });
  });
}
