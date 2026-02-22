import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/financial/depreciation_engine.dart';

void main() {
  group('DepreciationEngine — Straight Line (SL)', () {
    // cost=10000, salvage=1000, life=5, startMonth=1
    // depreciable=9000, annualDep=1800

    test('year 1: dep=1800, rbv=8200, rdv=7200', () {
      final r = DepreciationEngine.compute(
        cost: 10000,
        salvage: 1000,
        life: 5,
        year: 1,
        method: DepreciationMethod.sl,
      );
      expect(r.dep, closeTo(1800, 0.01));
      expect(r.rbv, closeTo(8200, 0.01));
      expect(r.rdv, closeTo(7200, 0.01));
    });

    test('year 5: dep=1800, rbv=1000 (salvage), rdv=0', () {
      final r = DepreciationEngine.compute(
        cost: 10000,
        salvage: 1000,
        life: 5,
        year: 5,
        method: DepreciationMethod.sl,
      );
      expect(r.dep, closeTo(1800, 0.01));
      expect(r.rbv, closeTo(1000, 0.01));
      expect(r.rdv, closeTo(0, 0.01));
    });

    test('total SL depreciation over life = cost - salvage', () {
      double totalDep = 0;
      for (int y = 1; y <= 5; y++) {
        final r = DepreciationEngine.compute(
          cost: 10000,
          salvage: 1000,
          life: 5,
          year: y,
          method: DepreciationMethod.sl,
        );
        totalDep += r.dep;
      }
      expect(totalDep, closeTo(9000, 0.01));
    });

    test('year 6 and beyond: dep=0', () {
      final r = DepreciationEngine.compute(
        cost: 10000,
        salvage: 1000,
        life: 5,
        year: 6,
        method: DepreciationMethod.sl,
      );
      expect(r.dep, closeTo(0, 0.01));
    });
  });

  group('DepreciationEngine — Sum of Years Digits (SYD)', () {
    // cost=10000, salvage=1000, life=5, startMonth=1
    // depreciable=9000, sumOfYears=15
    // year 1: 5/15 * 9000 = 3000
    // year 2: 4/15 * 9000 = 2400
    // year 3: 3/15 * 9000 = 1800
    // year 4: 2/15 * 9000 = 1200
    // year 5: 1/15 * 9000 = 600

    test('year 1 SYD dep = 3000', () {
      final r = DepreciationEngine.compute(
        cost: 10000,
        salvage: 1000,
        life: 5,
        year: 1,
        method: DepreciationMethod.syd,
      );
      expect(r.dep, closeTo(3000, 0.01));
    });

    test('year 5 SYD dep = 600', () {
      final r = DepreciationEngine.compute(
        cost: 10000,
        salvage: 1000,
        life: 5,
        year: 5,
        method: DepreciationMethod.syd,
      );
      expect(r.dep, closeTo(600, 0.01));
    });

    test('total SYD depreciation = cost - salvage', () {
      double total = 0;
      for (int y = 1; y <= 5; y++) {
        final r = DepreciationEngine.compute(
          cost: 10000,
          salvage: 1000,
          life: 5,
          year: y,
          method: DepreciationMethod.syd,
        );
        total += r.dep;
      }
      expect(total, closeTo(9000, 0.01));
    });

    test('SYD year 1 > SL year 1 (front-loaded)', () {
      final syd = DepreciationEngine.compute(
        cost: 10000, salvage: 1000, life: 5, year: 1,
        method: DepreciationMethod.syd,
      );
      final sl = DepreciationEngine.compute(
        cost: 10000, salvage: 1000, life: 5, year: 1,
        method: DepreciationMethod.sl,
      );
      expect(syd.dep, greaterThan(sl.dep));
    });
  });

  group('DepreciationEngine — Declining Balance (DB)', () {
    test('DB year 1 > SL year 1 (200% DB)', () {
      final db = DepreciationEngine.compute(
        cost: 10000, salvage: 1000, life: 5, year: 1,
        method: DepreciationMethod.db,
      );
      expect(db.dep, greaterThan(1800)); // SL dep = 1800
    });

    test('DB total depreciation = cost - salvage', () {
      double total = 0;
      for (int y = 1; y <= 5; y++) {
        final r = DepreciationEngine.compute(
          cost: 10000,
          salvage: 1000,
          life: 5,
          year: y,
          method: DepreciationMethod.db,
        );
        total += r.dep;
      }
      expect(total, closeTo(9000, 1.0)); // 200% DB with SL switch
    });

    test('DB rbv after final year equals salvage', () {
      final r = DepreciationEngine.compute(
        cost: 10000,
        salvage: 1000,
        life: 5,
        year: 5,
        method: DepreciationMethod.db,
      );
      expect(r.rbv, closeTo(1000, 1.0));
    });
  });
}
