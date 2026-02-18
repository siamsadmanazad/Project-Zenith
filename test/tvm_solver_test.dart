import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/tvm/tvm_input.dart';
import 'package:zenith/math_engine/tvm/tvm_solver.dart';

void main() {
  group('BA II Plus Test Cases', () {
    test('Test 1: Solve PMT — \$500k mortgage at 6.5% for 30 years', () {
      final input = TVMInput(
        n: 360,
        iy: 6.5,
        pv: 500000,
        fv: 0,
        cpy: 12,
      );

      final pmt = TVMSolver.solve(input);
      expect(pmt, closeTo(-3160.34, 0.01));
    });

    test('Test 2: Solve FV — \$10k lump sum + \$200/mo for 10 years at 5%', () {
      final input = TVMInput(
        n: 120,
        iy: 5,
        pv: -10000,
        pmt: -200,
        cpy: 12,
      );

      final fv = TVMSolver.solve(input);
      expect(fv, closeTo(47526.55, 0.01));
    });

    test('Test 3: Solve N — \$200/mo to reach \$100k at 7%', () {
      final input = TVMInput(
        iy: 7,
        pv: 0,
        pmt: -200,
        fv: 100000,
        cpy: 12,
      );

      final n = TVMSolver.solve(input);
      expect(n, closeTo(234.72, 0.01));
    });

    test('Test 4: Solve I/Y — negative rate scenario', () {
      final input = TVMInput(
        n: 60,
        pv: -15000,
        pmt: -200,
        fv: 20000,
        cpy: 12,
      );

      final iy = TVMSolver.solve(input);
      expect(iy, closeTo(-7.94, 0.01));
    });

    test('Test 5: Solve PV — \$1500/mo for 20 years at 4%', () {
      final input = TVMInput(
        n: 240,
        iy: 4,
        pmt: -1500,
        fv: 0,
        cpy: 12,
      );

      final pv = TVMSolver.solve(input);
      expect(pv, closeTo(247532.79, 0.01));
    });
  });

  group('Edge Cases', () {
    test('0% interest: PMT is simple division', () {
      final input = TVMInput(
        n: 12,
        iy: 0,
        pv: 12000,
        fv: 0,
      );

      final pmt = TVMSolver.solve(input);
      expect(pmt, closeTo(-1000, 0.01));
    });

    test('Validation: rejects if not exactly 4 variables', () {
      final input = TVMInput(
        n: 360,
        iy: 6.5,
        pv: 500000,
      );

      expect(input.isValid(), false);
      expect(() => TVMSolver.solve(input), throwsArgumentError);
    });

    test('I/Y solver: 0% rate detected', () {
      final input = TVMInput(
        n: 10,
        pv: -1000,
        pmt: 0,
        fv: 1000,
        cpy: 1,
      );

      final iy = TVMSolver.solve(input);
      expect(iy, closeTo(0.0, 0.01));
    });
  });

  group('P/Y ≠ C/Y scenarios', () {
    test('P/Y == C/Y matches original results (monthly/monthly)', () {
      // Same as Test 1 but with explicit ppy == cpy
      final input = TVMInput(
        n: 360,
        iy: 6.5,
        pv: 500000,
        fv: 0,
        ppy: 12,
        cpy: 12,
      );

      final pmt = TVMSolver.solve(input);
      expect(pmt, closeTo(-3160.34, 0.01));
    });

    test('Monthly payments with daily compounding — \$100k at 5% for 30 years', () {
      // P/Y=12, C/Y=365
      // BA II Plus: PMT ≈ -537.07
      final input = TVMInput(
        n: 360,
        iy: 5,
        pv: 100000,
        fv: 0,
        ppy: 12,
        cpy: 365,
      );

      final pmt = TVMSolver.solve(input);
      expect(pmt, closeTo(-537.44, 0.01));
    });

    test('Annual payments with monthly compounding — \$10k at 6% for 5 years', () {
      // P/Y=1, C/Y=12
      final input = TVMInput(
        n: 5,
        iy: 6,
        pv: 10000,
        fv: 0,
        ppy: 1,
        cpy: 12,
      );

      final pmt = TVMSolver.solve(input);
      // With monthly compounding, effective rate per year is higher
      // so payment should be slightly higher than simple annual
      expect(pmt, closeTo(-2384.81, 0.01));
    });

    test('Solve FV with P/Y=12, C/Y=1 (monthly payments, annual compounding)', () {
      final input = TVMInput(
        n: 120, // 10 years of monthly payments
        iy: 5,
        pv: 0,
        pmt: -100,
        ppy: 12,
        cpy: 1,
      );

      final fv = TVMSolver.solve(input);
      // With annual compounding but monthly payments, FV should be close
      // but slightly different from monthly compounding
      expect(fv, greaterThan(15000));
      expect(fv, lessThan(16000));
    });

    test('P/Y=1, C/Y=1 (annual everything) — simple case', () {
      final input = TVMInput(
        n: 10,
        iy: 5,
        pv: 10000,
        fv: 0,
        ppy: 1,
        cpy: 1,
      );

      final pmt = TVMSolver.solve(input);
      // Standard annual annuity PMT
      expect(pmt, closeTo(-1295.05, 0.01));
    });

    test('I/Y solver with P/Y ≠ C/Y', () {
      // Set up: monthly payments, daily compounding
      // We know the PMT for 100k at 5% for 30 years with P/Y=12,C/Y=365 is ~-537.44
      // Now solve for I/Y given PMT
      final input = TVMInput(
        n: 360,
        pv: 100000,
        pmt: -537.44,
        fv: 0,
        ppy: 12,
        cpy: 365,
      );

      final iy = TVMSolver.solve(input);
      expect(iy, closeTo(5.0, 0.05));
    });
  });
}
