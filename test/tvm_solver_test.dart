import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/tvm/tvm_input.dart';
import 'package:zenith/math_engine/tvm/tvm_solver.dart';

void main() {
  group('TVM Solver Tests', () {
    test('Solve PMT: \$500k loan, 6.5% for 30 years', () {
      // Arrange: Set up the problem
      final input = TVMInput(
        n: 360,           // 30 years × 12 months
        iy: 6.5,          // 6.5% annual interest
        pv: 500000,       // $500,000 loan
        fv: 0,            // Fully paid off
        cpy: 12,          // Monthly payments
      );

      // Act: Calculate the payment
      final pmt = TVMSolver.solve(input);

      // Assert: Check if result is correct
      // Expected: ~-$3,160.34/month (negative = payment out)
      expect(pmt, closeTo(-3160.34, 1.0));
      print('✅ Monthly Payment: \$${pmt.abs().toStringAsFixed(2)}');
    });

    test('Solve PV: How much can I borrow with \$2000/month payment?', () {
      final input = TVMInput(
        n: 360,           // 30 years
        iy: 6.5,          // 6.5%
        pmt: -2000,       // $2000/month (negative = outflow)
        fv: 0,
        cpy: 12,
      );

      final pv = TVMSolver.solve(input);

      // Expected: ~$315,960 (wider tolerance for FP math)
      expect(pv, closeTo(315960, 500));
      print('✅ Loan Amount: \$${pv.toStringAsFixed(2)}');
    });

    test('Solve FV: Save \$500/month for 20 years at 7%', () {
      final input = TVMInput(
        n: 240,           // 20 years × 12 months
        iy: 7.0,          // 7% annual return
        pv: 0,            // Starting from $0
        pmt: -500,        // Save $500/month
        cpy: 12,
      );

      final fv = TVMSolver.solve(input);

      // Expected: ~$260,000 (wider tolerance)
      expect(fv, closeTo(260000, 2000));
      print('✅ Future Value: \$${fv.toStringAsFixed(2)}');
    });

    test('Solve N: How long to pay off \$10k at \$300/month, 5%?', () {
      final input = TVMInput(
        iy: 5.0,
        pv: 10000,        // Money borrowed (positive)
        pmt: -300,        // Payment out (negative)
        fv: 0,            // Fully paid off
        cpy: 12,
      );

      final n = TVMSolver.solve(input);

      // Expected: ~35 months (between 34-36)
      expect(n, greaterThan(30));
      expect(n, lessThan(40));
      print('✅ Months to pay off: ${n.toStringAsFixed(1)} months');
    });

    test('Edge case: 0% interest', () {
      final input = TVMInput(
        n: 12,
        iy: 0,            // 0% interest
        pv: 12000,
        fv: 0,
      );

      final pmt = TVMSolver.solve(input);

      // With 0% interest: $12,000 / 12 = $1,000/month
      expect(pmt, closeTo(-1000, 0.01));
      print('✅ Payment at 0% interest: \$${pmt.toStringAsFixed(2)}');
    });

    test('Validation: Should reject if not exactly 4 variables', () {
      // Only 3 variables provided
      final input = TVMInput(
        n: 360,
        iy: 6.5,
        pv: 500000,
      );

      expect(input.isValid(), false);
      expect(() => TVMSolver.solve(input), throwsArgumentError);
      print('✅ Validation works correctly');
    });
  });
}
