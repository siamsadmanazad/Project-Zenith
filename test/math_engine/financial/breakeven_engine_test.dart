import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/financial/breakeven_engine.dart';

void main() {
  // PFT = Q * (P - VC) - FC

  group('BreakevenEngine.solve — quantity', () {
    test('Q = (PFT + FC) / (P - VC)', () {
      // PFT=0, FC=5000, VC=10, P=25 → Q = 5000/15 = 333.33
      final q = BreakevenEngine.solve(
        BreakevenVariable.quantity,
        p: 25, fc: 5000, vc: 10, pft: 0,
      );
      expect(q, closeTo(5000.0 / 15.0, 1e-9));
    });

    test('Q with profit target', () {
      // PFT=1500, FC=5000, VC=10, P=25 → Q = 6500/15
      final q = BreakevenEngine.solve(
        BreakevenVariable.quantity,
        p: 25, fc: 5000, vc: 10, pft: 1500,
      );
      expect(q, closeTo(6500.0 / 15.0, 1e-9));
    });

    test('P = VC throws error', () {
      expect(
        () => BreakevenEngine.solve(
          BreakevenVariable.quantity,
          p: 10, fc: 5000, vc: 10, pft: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('BreakevenEngine.solve — price', () {
    test('P = (PFT + FC) / Q + VC', () {
      // PFT=0, FC=5000, Q=500, VC=10 → P = 5000/500 + 10 = 20
      final p = BreakevenEngine.solve(
        BreakevenVariable.price,
        q: 500, fc: 5000, vc: 10, pft: 0,
      );
      expect(p, closeTo(20.0, 1e-9));
    });

    test('Q=0 throws error', () {
      expect(
        () => BreakevenEngine.solve(
          BreakevenVariable.price,
          q: 0, fc: 5000, vc: 10, pft: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('BreakevenEngine.solve — fixed cost', () {
    test('FC = Q*(P-VC) - PFT', () {
      // Q=400, P=25, VC=10, PFT=1000 → FC = 400*15 - 1000 = 5000
      final fc = BreakevenEngine.solve(
        BreakevenVariable.fixedCost,
        q: 400, p: 25, vc: 10, pft: 1000,
      );
      expect(fc, closeTo(5000.0, 1e-9));
    });
  });

  group('BreakevenEngine.solve — variable cost', () {
    test('VC = P - (PFT + FC) / Q', () {
      // P=25, PFT=1000, FC=5000, Q=400 → VC = 25 - 6000/400 = 25 - 15 = 10
      final vc = BreakevenEngine.solve(
        BreakevenVariable.variableCost,
        q: 400, p: 25, fc: 5000, pft: 1000,
      );
      expect(vc, closeTo(10.0, 1e-9));
    });
  });

  group('BreakevenEngine.solve — profit', () {
    test('PFT = Q*(P-VC) - FC', () {
      // Q=400, P=25, VC=10, FC=5000 → PFT = 400*15 - 5000 = 1000
      final pft = BreakevenEngine.solve(
        BreakevenVariable.profit,
        q: 400, p: 25, fc: 5000, vc: 10,
      );
      expect(pft, closeTo(1000.0, 1e-9));
    });

    test('profit = 0 at break-even quantity', () {
      final pft = BreakevenEngine.solve(
        BreakevenVariable.profit,
        q: 5000.0 / 15.0, p: 25, fc: 5000, vc: 10,
      );
      expect(pft, closeTo(0, 1e-9));
    });
  });

  group('BreakevenEngine.breakevenQuantity', () {
    test('Q_be = FC / (P - VC)', () {
      final qBe = BreakevenEngine.breakevenQuantity(p: 25, fc: 5000, vc: 10);
      expect(qBe, closeTo(5000.0 / 15.0, 1e-9));
    });

    test('P = VC throws error', () {
      expect(
        () => BreakevenEngine.breakevenQuantity(p: 10, fc: 5000, vc: 10),
        throwsArgumentError,
      );
    });
  });

  group('Round-trip consistency', () {
    test('solve Q then verify PFT', () {
      const fc = 8000.0, vc = 15.0, p = 35.0, pft = 2000.0;
      final q = BreakevenEngine.solve(
        BreakevenVariable.quantity,
        p: p, fc: fc, vc: vc, pft: pft,
      );
      final verifiedPft = BreakevenEngine.solve(
        BreakevenVariable.profit,
        q: q, p: p, fc: fc, vc: vc,
      );
      expect(verifiedPft, closeTo(pft, 1e-9));
    });
  });
}
