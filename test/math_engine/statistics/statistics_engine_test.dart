import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/statistics/statistics_engine.dart';

void main() {
  group('StatisticsEngine.compute — Linear regression', () {
    test('perfect linear: y = 2x → a=0, b=2, r=1', () {
      final data = [(1.0, 2.0), (2.0, 4.0), (3.0, 6.0)];
      final result = StatisticsEngine.compute(data, RegressionModel.lin);
      expect(result.n, 3.0);
      expect(result.a, closeTo(0.0, 1e-9));
      expect(result.b, closeTo(2.0, 1e-9));
      expect(result.r, closeTo(1.0, 1e-9));
      expect(result.meanX, closeTo(2.0, 1e-9));
      expect(result.meanY, closeTo(4.0, 1e-9));
    });

    test('y = a + bx with offset: (1,3),(2,5),(3,7) → a=1, b=2, r=1', () {
      final data = [(1.0, 3.0), (2.0, 5.0), (3.0, 7.0)];
      final result = StatisticsEngine.compute(data, RegressionModel.lin);
      expect(result.a, closeTo(1.0, 1e-9));
      expect(result.b, closeTo(2.0, 1e-9));
      expect(result.r, closeTo(1.0, 1e-9));
    });

    test('perfect negative correlation: y = -x → b=-1, r=-1', () {
      final data = [(1.0, -1.0), (2.0, -2.0), (3.0, -3.0)];
      final result = StatisticsEngine.compute(data, RegressionModel.lin);
      expect(result.b, closeTo(-1.0, 1e-9));
      expect(result.r, closeTo(-1.0, 1e-9));
    });

    test('less than 2 points throws', () {
      expect(
        () => StatisticsEngine.compute([(1.0, 2.0)], RegressionModel.lin),
        throwsArgumentError,
      );
    });

    test('all x identical throws', () {
      final data = [(2.0, 1.0), (2.0, 3.0), (2.0, 5.0)];
      expect(
        () => StatisticsEngine.compute(data, RegressionModel.lin),
        throwsArgumentError,
      );
    });

    test('sample std dev is computed correctly', () {
      // data: x = [1,2,3], sX = 1.0 (sample std dev)
      final data = [(1.0, 2.0), (2.0, 4.0), (3.0, 6.0)];
      final result = StatisticsEngine.compute(data, RegressionModel.lin);
      // sX = sqrt(((1-2)^2 + (2-2)^2 + (3-2)^2) / (3-1)) = sqrt(2/2) = 1
      expect(result.sX, closeTo(1.0, 1e-9));
      expect(result.sY, closeTo(2.0, 1e-9)); // sY = 2 * sX
    });
  });

  group('StatisticsEngine.compute — Exponential regression', () {
    test('y = e^x → a=1, b=1', () {
      // Exp model: ln(y) = ln(a) + b*x, so b=1, reported a = e^ln(1) = 1
      final data = [
        (1.0, math.exp(1)),
        (2.0, math.exp(2)),
        (3.0, math.exp(3)),
      ];
      final result = StatisticsEngine.compute(data, RegressionModel.exp);
      expect(result.a, closeTo(1.0, 1e-9));
      expect(result.b, closeTo(1.0, 1e-9));
    });

    test('non-positive y throws for EXP model', () {
      expect(
        () => StatisticsEngine.compute(
          [(1.0, -1.0), (2.0, 3.0)],
          RegressionModel.exp,
        ),
        throwsArgumentError,
      );
    });
  });

  group('StatisticsEngine.compute — Power regression', () {
    test('y = x^2 → a=1, b=2', () {
      // PWR model: ln(y) = ln(a) + b*ln(x), so b=2, a = e^0 = 1
      final data = [(1.0, 1.0), (2.0, 4.0), (3.0, 9.0)];
      final result = StatisticsEngine.compute(data, RegressionModel.pwr);
      expect(result.a, closeTo(1.0, 1e-9));
      expect(result.b, closeTo(2.0, 1e-9));
    });

    test('non-positive x throws for PWR model', () {
      expect(
        () => StatisticsEngine.compute(
          [(-1.0, 1.0), (2.0, 4.0)],
          RegressionModel.pwr,
        ),
        throwsArgumentError,
      );
    });
  });

  group('StatisticsEngine.predict', () {
    test('linear: predict y from x', () {
      final data = [(1.0, 3.0), (2.0, 5.0), (3.0, 7.0)];
      final result = StatisticsEngine.compute(data, RegressionModel.lin);
      // y = 1 + 2x → predict(4) = 9
      expect(
        StatisticsEngine.predict(4.0, result, RegressionModel.lin),
        closeTo(9.0, 1e-9),
      );
    });

    test('exp: predict y from x', () {
      final data = [
        (1.0, math.exp(1)),
        (2.0, math.exp(2)),
        (3.0, math.exp(3)),
      ];
      final result = StatisticsEngine.compute(data, RegressionModel.exp);
      // y = e^x → predict(4) = e^4
      expect(
        StatisticsEngine.predict(4.0, result, RegressionModel.exp),
        closeTo(math.exp(4), 1e-6),
      );
    });
  });

  group('StatisticsEngine.predictX', () {
    test('linear: predict x from y', () {
      final data = [(1.0, 3.0), (2.0, 5.0), (3.0, 7.0)];
      final result = StatisticsEngine.compute(data, RegressionModel.lin);
      // y = 1 + 2x → x = (y - 1) / 2 → predictX(9) = 4
      expect(
        StatisticsEngine.predictX(9.0, result, RegressionModel.lin),
        closeTo(4.0, 1e-9),
      );
    });

    test('zero slope throws for linear predictX', () {
      // y = constant → b = 0 → cannot solve for x
      // This would require a degenerate dataset that produces b=0 but r != 0...
      // Instead, construct a result manually
      const result = StatResult(
        n: 3, meanX: 2, meanY: 5, sX: 1, sY: 0, a: 5, b: 0, r: 0,
      );
      expect(
        () => StatisticsEngine.predictX(5.0, result, RegressionModel.lin),
        throwsArgumentError,
      );
    });
  });
}
