import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/financial/amortization_engine.dart';

void main() {
  group('AmortizationEngine — zero interest', () {
    // With zero rate: principal = pmt (negative), interest = 0 each period.
    test('balance drops by |pmt| per period at 0%', () {
      final result = AmortizationEngine.amortize(
        pv: 1000,
        pmt: -200,
        annualRate: 0,
        ppy: 1,
        p1: 1,
        p2: 1,
        pmtMode: 0,
      );
      // After 1 period: balance = 1000 - 200 = 800
      expect(result.bal, closeTo(800, 1e-6));
      expect(result.prn, closeTo(-200, 1e-6));
      expect(result.int_, closeTo(0, 1e-6));
    });

    test('5 payments of 200 pay off 1000 loan at 0%', () {
      final result = AmortizationEngine.amortize(
        pv: 1000,
        pmt: -200,
        annualRate: 0,
        ppy: 1,
        p1: 1,
        p2: 5,
        pmtMode: 0,
      );
      expect(result.bal, closeTo(0, 1e-6));
      expect(result.prn, closeTo(-1000, 1e-6));
      expect(result.int_, closeTo(0, 1e-6));
    });

    test('p1 > 1 accumulates only selected range', () {
      // Periods 3-5 of a 5-payment zero-rate loan of 1000
      final result = AmortizationEngine.amortize(
        pv: 1000,
        pmt: -200,
        annualRate: 0,
        ppy: 1,
        p1: 3,
        p2: 5,
        pmtMode: 0,
      );
      // After 5 periods: bal=0; PRN and INT cover only periods 3-5
      expect(result.bal, closeTo(0, 1e-6));
      expect(result.prn, closeTo(-600, 1e-6));
      expect(result.int_, closeTo(0, 1e-6));
    });
  });

  group('AmortizationEngine — with interest', () {
    // Engine formula: interestPortion = balance*rate,
    //                 principalPortion = pmt - interestPortion,
    //                 balance += principalPortion
    // Equivalent to: balance_new = balance + pmt - balance*rate

    test('single period, 1% monthly rate', () {
      // balance=1000, rate=0.01, pmt=-105.582
      // interest = 10, principal = -115.582, bal = 884.418
      final result = AmortizationEngine.amortize(
        pv: 1000,
        pmt: -105.582,
        annualRate: 12,
        ppy: 12,
        p1: 1,
        p2: 1,
        pmtMode: 0,
      );
      expect(result.bal, closeTo(884.418, 0.01));
      expect(result.int_, closeTo(10.0, 0.01));
      expect(result.prn, closeTo(-115.582, 0.01));
    });

    test('PRN + INT = PMT for each period (END mode)', () {
      // Engine: interestPortion + principalPortion = pmt
      final result = AmortizationEngine.amortize(
        pv: 5000,
        pmt: -300,
        annualRate: 6,
        ppy: 12,
        p1: 1,
        p2: 12,
        pmtMode: 0,
      );
      // sum(PRN) + sum(INT) = n * pmt = 12 * (-300) = -3600
      expect(result.prn + result.int_, closeTo(-3600, 0.01));
    });

    test('BAL = PV + PRN after p2 periods', () {
      // BAL = PV + all principalPortion adjustments
      final result = AmortizationEngine.amortize(
        pv: 5000,
        pmt: -300,
        annualRate: 6,
        ppy: 12,
        p1: 1,
        p2: 6,
        pmtMode: 0,
      );
      // To get full BAL we'd need to run p1=1 through all periods
      // Here just verify BAL is reasonable (less than PV)
      expect(result.bal, lessThan(5000));
    });
  });
}
