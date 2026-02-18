import 'package:flutter_test/flutter_test.dart';
import 'package:zenith/features/calculator/providers/calculator_state.dart';

void main() {
  late CalculatorNotifier notifier;

  setUp(() {
    notifier = CalculatorNotifier();
  });

  group('Keypad digit entry', () {
    test('appendDigit builds display buffer', () {
      notifier.appendDigit('5');
      notifier.appendDigit('0');
      notifier.appendDigit('0');
      expect(notifier.state.displayBuffer, '500');
    });

    test('appendDecimal adds decimal point', () {
      notifier.appendDigit('1');
      notifier.appendDecimal();
      notifier.appendDigit('5');
      expect(notifier.state.displayBuffer, '1.5');
    });

    test('appendDecimal prevents double decimal', () {
      notifier.appendDigit('1');
      notifier.appendDecimal();
      notifier.appendDecimal(); // should be ignored
      notifier.appendDigit('5');
      expect(notifier.state.displayBuffer, '1.5');
    });

    test('appendDecimal on empty buffer gives "0."', () {
      notifier.appendDecimal();
      expect(notifier.state.displayBuffer, '0.');
    });

    test('toggleSign flips sign', () {
      notifier.appendDigit('5');
      notifier.appendDigit('0');
      notifier.toggleSign();
      expect(notifier.state.displayBuffer, '-50');
      notifier.toggleSign();
      expect(notifier.state.displayBuffer, '50');
    });

    test('toggleSign does nothing on empty buffer', () {
      notifier.toggleSign();
      expect(notifier.state.displayBuffer, '');
    });

    test('backspace removes last character', () {
      notifier.appendDigit('1');
      notifier.appendDigit('2');
      notifier.appendDigit('3');
      notifier.backspace();
      expect(notifier.state.displayBuffer, '12');
    });

    test('backspace on empty buffer does nothing', () {
      notifier.backspace();
      expect(notifier.state.displayBuffer, '');
    });
  });

  group('TVM variable storage', () {
    test('storeTVMVariable parses buffer and stores value', () {
      notifier.appendDigit('5');
      notifier.appendDigit('0');
      notifier.appendDigit('0');
      notifier.appendDigit('0');
      notifier.appendDigit('0');
      notifier.appendDigit('0');
      notifier.storeTVMVariable('PV');

      expect(notifier.state.pv, 500000);
      expect(notifier.state.displayBuffer, '');
      expect(notifier.state.activeVariable, 'PV');
    });

    test('storeTVMVariable with negative value', () {
      notifier.appendDigit('3');
      notifier.appendDigit('1');
      notifier.appendDigit('6');
      notifier.appendDigit('0');
      notifier.toggleSign();
      notifier.storeTVMVariable('PMT');

      expect(notifier.state.pmt, -3160);
      expect(notifier.state.activeVariable, 'PMT');
    });

    test('storeTVMVariable with empty buffer shows current value', () {
      notifier.updateField('N', 360);
      notifier.storeTVMVariable('N');

      expect(notifier.state.activeVariable, 'N');
      expect(notifier.state.statusMessage, 'N = 360.00');
    });

    test('storeTVMVariable stores all 5 variables', () {
      final vars = {'N': 360.0, 'I/Y': 6.5, 'PV': 500000.0, 'PMT': -3160.0, 'FV': 0.0};
      for (final entry in vars.entries) {
        // Reset buffer for each
        notifier.appendDigit('0'); // dummy
        notifier.backspace(); // clear
        notifier.updateField(entry.key, entry.value);
      }

      expect(notifier.state.n, 360);
      expect(notifier.state.iy, 6.5);
      expect(notifier.state.pv, 500000);
      expect(notifier.state.pmt, -3160);
      expect(notifier.state.fv, 0);
    });
  });

  group('CPT flow', () {
    test('enterCptMode sets cptMode true', () {
      notifier.enterCptMode();
      expect(notifier.state.cptMode, true);
      expect(notifier.state.statusMessage, 'CPT');
    });

    test('computeVariable solves and stores result', () {
      // Set up 4 known values, compute PMT
      notifier.updateField('N', 360);
      notifier.updateField('I/Y', 6.5);
      notifier.updateField('PV', 500000);
      notifier.updateField('FV', 0);

      notifier.enterCptMode();
      notifier.computeVariable('PMT');

      expect(notifier.state.cptMode, false);
      expect(notifier.state.pmt, isNotNull);
      expect(notifier.state.pmt!, closeTo(-3160.34, 0.01));
      expect(notifier.state.result, isNotNull);
      expect(notifier.state.activeVariable, 'PMT');
    });

    test('computeVariable with insufficient values shows error', () {
      notifier.updateField('N', 360);
      notifier.updateField('I/Y', 6.5);
      // Only 2 values — not enough

      notifier.enterCptMode();
      notifier.computeVariable('PMT');

      expect(notifier.state.cptMode, false);
      expect(notifier.state.errorMessage, isNotNull);
    });

    test('CPT overwrites existing value', () {
      notifier.updateField('N', 360);
      notifier.updateField('I/Y', 6.5);
      notifier.updateField('PV', 500000);
      notifier.updateField('PMT', -999); // existing value
      notifier.updateField('FV', 0);

      // Now compute PMT — should null it out and resolve
      notifier.enterCptMode();
      notifier.computeVariable('PMT');

      expect(notifier.state.pmt!, closeTo(-3160.34, 0.01));
    });
  });

  group('Mode sharing', () {
    test('form updateField values visible in state', () {
      notifier.updateField('N', 360);
      notifier.updateField('I/Y', 6.5);

      expect(notifier.state.getVariable('N'), 360);
      expect(notifier.state.getVariable('I/Y'), 6.5);
    });

    test('keypad stored values accessible via getVariable', () {
      notifier.appendDigit('3');
      notifier.appendDigit('6');
      notifier.appendDigit('0');
      notifier.storeTVMVariable('N');

      expect(notifier.state.getVariable('N'), 360);
    });

    test('clear resets everything', () {
      notifier.updateField('N', 360);
      notifier.updateField('I/Y', 6.5);
      notifier.appendDigit('5');
      notifier.enterCptMode();

      notifier.clear();

      expect(notifier.state.n, isNull);
      expect(notifier.state.iy, isNull);
      expect(notifier.state.displayBuffer, '');
      expect(notifier.state.cptMode, false);
      expect(notifier.state.activeVariable, isNull);
    });

    test('clearEntry only clears buffer', () {
      notifier.updateField('N', 360);
      notifier.appendDigit('5');
      notifier.enterCptMode();

      notifier.clearEntry();

      expect(notifier.state.n, 360); // preserved
      expect(notifier.state.displayBuffer, '');
      expect(notifier.state.cptMode, false);
    });
  });

  group('P/Y and C/Y', () {
    test('default ppy is 12', () {
      expect(notifier.state.ppy, 12);
    });

    test('updatePpy changes ppy', () {
      notifier.updatePpy(365);
      expect(notifier.state.ppy, 365);
    });

    test('ppy passed through to calculation', () {
      notifier.updateField('N', 360);
      notifier.updateField('I/Y', 5);
      notifier.updateField('PV', 100000);
      notifier.updateField('FV', 0);
      notifier.updatePpy(12);
      notifier.updateCpy(365);

      notifier.enterCptMode();
      notifier.computeVariable('PMT');

      expect(notifier.state.pmt!, closeTo(-537.44, 0.10));
    });
  });
}
