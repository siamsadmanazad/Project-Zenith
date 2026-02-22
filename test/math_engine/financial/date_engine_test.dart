import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/math_engine/financial/date_engine.dart';

void main() {
  group('DateEngine.daysBetween — ACT', () {
    test('same day → 0 days', () {
      final d = DateTime(2024, 6, 15);
      expect(DateEngine.daysBetween(d, d, DayCountMethod.actual), 0);
    });

    test('1 day apart', () {
      final d1 = DateTime(2024, 1, 1);
      final d2 = DateTime(2024, 1, 2);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.actual), 1);
    });

    test('full non-leap year (2023): Jan 1 → Dec 31 = 364 days', () {
      final d1 = DateTime(2023, 1, 1);
      final d2 = DateTime(2023, 12, 31);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.actual), 364);
    });

    test('full leap year (2024): Jan 1 → Dec 31 = 365 days', () {
      final d1 = DateTime(2024, 1, 1);
      final d2 = DateTime(2024, 12, 31);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.actual), 365);
    });

    test('year boundary: Dec 31, 2023 → Jan 1, 2024 = 1 day', () {
      final d1 = DateTime(2023, 12, 31);
      final d2 = DateTime(2024, 1, 1);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.actual), 1);
    });

    test('negative: d2 before d1', () {
      final d1 = DateTime(2024, 6, 15);
      final d2 = DateTime(2024, 6, 10);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.actual), -5);
    });
  });

  group('DateEngine.daysBetween — 30/360', () {
    test('same date → 0', () {
      final d = DateTime(2024, 1, 15);
      expect(DateEngine.daysBetween(d, d, DayCountMethod.days360), 0);
    });

    test('exactly 1 month apart = 30 days', () {
      final d1 = DateTime(2024, 1, 15);
      final d2 = DateTime(2024, 2, 15);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.days360), 30);
    });

    test('exactly 1 year apart = 360 days', () {
      final d1 = DateTime(2024, 1, 15);
      final d2 = DateTime(2025, 1, 15);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.days360), 360);
    });

    test('Jan 1 to Dec 31: dd1=1 < 30 so dd2=31 stays, result = 330+30 = 360', () {
      // 30/360 rule: dd2=31 capped to 30 ONLY when dd1 >= 30.
      // dd1=1, so dd2=31 is NOT capped → (12-1)*30 + (31-1) = 330+30 = 360.
      final d1 = DateTime(2024, 1, 1);
      final d2 = DateTime(2024, 12, 31);
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.days360), 360);
    });

    test('31st treated as 30th in denominator when d1 day >= 30', () {
      // d1=Jan 30, d2=Feb 31 (March 3, but 30/360 rules: d2=30 since d1>=30)
      final d1 = DateTime(2024, 1, 30);
      final d2 = DateTime(2024, 2, 28);
      // d1=30, d2=28, same year, 1 month apart: (2-1)*30 + (28-30) = 30-2 = 28
      expect(DateEngine.daysBetween(d1, d2, DayCountMethod.days360), 28);
    });
  });

  group('DateEngine.addDays', () {
    test('add 0 days', () {
      final d = DateTime(2024, 6, 15);
      final result = DateEngine.addDays(d, 0);
      expect(result.day, 15);
      expect(result.month, 6);
    });

    test('add positive days', () {
      final d = DateTime(2024, 1, 29);
      final result = DateEngine.addDays(d, 3);
      // Jan 29 + 3 = Feb 1 (2024 is leap year)
      expect(result.month, 2);
      expect(result.day, 1);
    });

    test('add negative days (subtract)', () {
      final d = DateTime(2024, 3, 1);
      final result = DateEngine.addDays(d, -1);
      // Feb has 29 days in 2024
      expect(result.month, 2);
      expect(result.day, 29);
    });

    test('round-trip: add then subtract', () {
      final d = DateTime(2024, 6, 15);
      final result = DateEngine.addDays(DateEngine.addDays(d, 100), -100);
      expect(result.year, d.year);
      expect(result.month, d.month);
      expect(result.day, d.day);
    });
  });
}
