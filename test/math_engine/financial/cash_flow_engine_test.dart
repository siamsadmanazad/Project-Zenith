import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/financial/cash_flow_engine.dart';

void main() {
  group('CashFlowEngine.npv', () {
    test('NPV=0 when IRR equals discount rate', () {
      // CF0=-100, CF1=110, rate=10% → NPV = -100 + 110/1.1 = 0
      final cfs = [CashFlowEntry(-100), CashFlowEntry(110)];
      expect(CashFlowEngine.npv(cfs, 10.0), closeTo(0.0, 1e-9));
    });

    test('positive NPV when rate below IRR', () {
      final cfs = [CashFlowEntry(-100), CashFlowEntry(110)];
      expect(CashFlowEngine.npv(cfs, 5.0), greaterThan(0));
    });

    test('negative NPV when rate above IRR', () {
      final cfs = [CashFlowEntry(-100), CashFlowEntry(110)];
      expect(CashFlowEngine.npv(cfs, 15.0), lessThan(0));
    });

    test('multi-period NPV at 10%', () {
      // CF0=-1000, CF1=500, CF2=400, CF3=300, rate=10%
      final cfs = [
        CashFlowEntry(-1000),
        CashFlowEntry(500),
        CashFlowEntry(400),
        CashFlowEntry(300),
      ];
      // NPV = -1000 + 500/1.1 + 400/1.21 + 300/1.331 ≈ 10.518
      expect(CashFlowEngine.npv(cfs, 10.0), closeTo(10.518, 0.001));
    });

    test('NPV accounts for cash flow frequency', () {
      // CF0=-100, CF1=50 (frequency=2) at rate=0%
      // → NPV = -100 + 50 + 50 = 0
      final cfs = [CashFlowEntry(-100), CashFlowEntry(50, 2)];
      expect(CashFlowEngine.npv(cfs, 0.0), closeTo(0.0, 1e-9));
    });

    test('zero rate: NPV = simple sum', () {
      final cfs = [CashFlowEntry(-200), CashFlowEntry(80), CashFlowEntry(80), CashFlowEntry(80)];
      expect(CashFlowEngine.npv(cfs, 0.0), closeTo(40.0, 1e-9));
    });
  });

  group('CashFlowEngine.irr', () {
    test('IRR = 10% for CF0=-100, CF1=110', () {
      final cfs = [CashFlowEntry(-100), CashFlowEntry(110)];
      expect(CashFlowEngine.irr(cfs), closeTo(10.0, 1e-6));
    });

    test('IRR makes NPV equal zero', () {
      final cfs = [
        CashFlowEntry(-1000),
        CashFlowEntry(500),
        CashFlowEntry(400),
        CashFlowEntry(300),
      ];
      final irr = CashFlowEngine.irr(cfs);
      // Verify NPV at IRR ≈ 0
      expect(CashFlowEngine.npv(cfs, irr), closeTo(0.0, 0.001));
    });

    test('IRR = 50% for CF0=-100, CF1=150', () {
      final cfs = [CashFlowEntry(-100), CashFlowEntry(150)];
      expect(CashFlowEngine.irr(cfs), closeTo(50.0, 1e-6));
    });

    test('IRR = 0% for break-even cash flows', () {
      final cfs = [CashFlowEntry(-100), CashFlowEntry(100)];
      expect(CashFlowEngine.irr(cfs), closeTo(0.0, 0.1));
    });
  });
}
