import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/financial/bond_engine.dart';

void main() {
  group('BondEngine.price', () {
    test('par bond: coupon = yield → price = 100', () {
      final p = BondEngine.price(
        coupon: 6,
        yield_: 6,
        redemption: 100,
        frequency: 2,
        periodsRemaining: 10,
      );
      expect(p, closeTo(100.0, 0.001));
    });

    test('discount bond: yield > coupon → price < 100', () {
      // 6% coupon, 8% yield, semi-annual, 10 periods
      // c=3/period, y=0.04/period, n=10
      // PV_coupons = 3*(1-1.04^-10)/0.04, PV_redemption = 100*1.04^-10
      // 1.04^10 = 1.480244, 1.04^-10 = 0.675564
      // PV_coupons = 3*8.1109 = 24.333, PV_redemption = 67.556 → price ≈ 91.889
      final p = BondEngine.price(
        coupon: 6,
        yield_: 8,
        redemption: 100,
        frequency: 2,
        periodsRemaining: 10,
      );
      expect(p, closeTo(91.889, 0.01));
    });

    test('premium bond: yield < coupon → price > 100', () {
      // 8% coupon, 6% yield
      final p = BondEngine.price(
        coupon: 8,
        yield_: 6,
        redemption: 100,
        frequency: 2,
        periodsRemaining: 10,
      );
      expect(p, greaterThan(100.0));
    });

    test('annual frequency, 1 period remaining', () {
      // Price = (coupon + redemption) / (1 + yield)
      // = (10 + 100) / 1.10 = 100 at 10% coupon, 10% yield
      final p = BondEngine.price(
        coupon: 10,
        yield_: 10,
        redemption: 100,
        frequency: 1,
        periodsRemaining: 1,
      );
      expect(p, closeTo(100.0, 0.001));
    });

    test('zero yield → price = coupons + redemption', () {
      // 6% annual coupon, 0% yield, 5 periods, redemption=100
      // price = 5*6 + 100 = 130
      final p = BondEngine.price(
        coupon: 6,
        yield_: 0,
        redemption: 100,
        frequency: 1,
        periodsRemaining: 5,
      );
      expect(p, closeTo(130.0, 0.001));
    });
  });

  group('BondEngine.yield_', () {
    test('par bond: price=100 → yield = coupon rate', () {
      final y = BondEngine.yield_(
        coupon: 6,
        price: 100,
        redemption: 100,
        frequency: 2,
        periodsRemaining: 10,
      );
      expect(y, closeTo(6.0, 0.001));
    });

    test('discount bond: price < 100 → yield > coupon', () {
      // 6% coupon, price=91.889 → yield ≈ 8%
      final y = BondEngine.yield_(
        coupon: 6,
        price: 91.889,
        redemption: 100,
        frequency: 2,
        periodsRemaining: 10,
      );
      expect(y, closeTo(8.0, 0.01));
    });

    test('price/yield round-trip', () {
      const coupon = 7.5;
      const yield0 = 6.25;
      final p = BondEngine.price(
        coupon: coupon,
        yield_: yield0,
        redemption: 100,
        frequency: 2,
        periodsRemaining: 20,
      );
      final y = BondEngine.yield_(
        coupon: coupon,
        price: p,
        redemption: 100,
        frequency: 2,
        periodsRemaining: 20,
      );
      expect(y, closeTo(yield0, 1e-6));
    });
  });
}
