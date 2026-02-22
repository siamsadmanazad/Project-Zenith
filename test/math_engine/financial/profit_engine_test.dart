import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/financial/profit_engine.dart';

void main() {
  // Margin = (selling - cost) / selling * 100
  // Markup = (selling - cost) / cost * 100

  group('ProfitEngine.solve — margin', () {
    test('margin = (100 - 75) / 100 * 100 = 25%', () {
      final m = ProfitEngine.solve(
        ProfitVariable.margin,
        cost: 75,
        selling: 100,
      );
      expect(m, closeTo(25.0, 1e-9));
    });

    test('margin = 0% when cost = selling', () {
      final m = ProfitEngine.solve(
        ProfitVariable.margin,
        cost: 100,
        selling: 100,
      );
      expect(m, closeTo(0, 1e-9));
    });

    test('selling=0 throws error', () {
      expect(
        () => ProfitEngine.solve(
          ProfitVariable.margin,
          cost: 50,
          selling: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ProfitEngine.solve — selling', () {
    test('selling = cost / (1 - margin/100)', () {
      // cost=75, margin=25% → selling = 75 / 0.75 = 100
      final s = ProfitEngine.solve(
        ProfitVariable.selling,
        cost: 75,
        margin: 25,
      );
      expect(s, closeTo(100.0, 1e-9));
    });

    test('margin=100% throws error (would require infinite selling price)', () {
      expect(
        () => ProfitEngine.solve(
          ProfitVariable.selling,
          cost: 50,
          margin: 100,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ProfitEngine.solve — cost', () {
    test('cost = selling * (1 - margin/100)', () {
      // selling=100, margin=25% → cost = 100 * 0.75 = 75
      final c = ProfitEngine.solve(
        ProfitVariable.cost,
        selling: 100,
        margin: 25,
      );
      expect(c, closeTo(75.0, 1e-9));
    });

    test('cost = selling at 0% margin', () {
      final c = ProfitEngine.solve(
        ProfitVariable.cost,
        selling: 150,
        margin: 0,
      );
      expect(c, closeTo(150.0, 1e-9));
    });
  });

  group('ProfitEngine.markup', () {
    test('markup = (100 - 75) / 75 * 100 = 33.33%', () {
      final m = ProfitEngine.markup(75, 100);
      expect(m, closeTo(100.0 / 3.0, 1e-9));
    });

    test('markup = 0% when cost = selling', () {
      expect(ProfitEngine.markup(100, 100), closeTo(0, 1e-9));
    });

    test('cost=0 throws error', () {
      expect(() => ProfitEngine.markup(0, 100), throwsArgumentError);
    });
  });

  group('Round-trip consistency', () {
    test('solve cost then margin gives back original margin', () {
      const selling = 250.0;
      const margin = 30.0;
      final cost = ProfitEngine.solve(
        ProfitVariable.cost,
        selling: selling,
        margin: margin,
      );
      final verifiedMargin = ProfitEngine.solve(
        ProfitVariable.margin,
        cost: cost,
        selling: selling,
      );
      expect(verifiedMargin, closeTo(margin, 1e-9));
    });

    test('solve selling then cost gives round-trip', () {
      const cost = 120.0;
      const margin = 40.0;
      final selling = ProfitEngine.solve(
        ProfitVariable.selling,
        cost: cost,
        margin: margin,
      );
      final verifiedCost = ProfitEngine.solve(
        ProfitVariable.cost,
        selling: selling,
        margin: margin,
      );
      expect(verifiedCost, closeTo(cost, 1e-9));
    });
  });
}
