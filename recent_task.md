# Project ZENITH — Recent Tasks

## Master Plan: Implement All Calculator Buttons + Haptic + UI Polish

All 15+ "coming soon" buttons → fully functional financial calculator with differentiated haptic feedback and polished mode-switching UX.

---

## Phase 1: Foundation (Haptic Service + State Prep) — `DONE`

### Task 1A: Create HapticService utility — `DONE`
**New file:** `lib/core/utils/haptic_service.dart`
- Wrap `HapticFeedback` with semantic methods
- `digit()` → lightImpact
- `operator()` / `tvm()` / `function()` → mediumImpact
- `error()` / `clear()` → heavyImpact
- `mode()` → selectionClick

### Task 1B: Wire haptic into keypad — `DONE`
**Modify:** `lib/features/calculator/widgets/full_keypad.dart`
- Replace single `HapticFeedback.lightImpact()` (line 282) with category-aware dispatch
- Add error haptic after actions that set `errorMessage`

### Task 1C: Wire haptic into mode toggle — `DONE`
**Modify:** `lib/features/calculator/widgets/mode_toggle_button.dart`
- Replace `HapticFeedback.lightImpact()` with `HapticService.mode()`

### Task 1D: Add `activeWorksheet` field to state — `DONE`
**Modify:** `lib/features/calculator/providers/calculator_state.dart`
- Add `activeWorksheet: String?` field to `CalculatorState`
- Update `copyWith` with sentinel pattern
- Add `setActiveWorksheet(String?)` method to notifier

---

## Phase 2: Math Engines (8 new pure-Dart files) — `DONE`

All follow the pattern of `interest_conversion.dart` — static methods, no Flutter deps.

### Task 2A: Cash Flow Engine — `PENDING`
**New file:** `lib/math_engine/financial/cash_flow_engine.dart`
- `CashFlowEntry` model (amount + frequency)
- `npv(cashFlows, annualRate)` — NPV = CF0 + Σ(CFj / (1+r)^j)
- `irr(cashFlows)` — Newton-Raphson with bisection fallback

### Task 2B: Amortization Engine — `PENDING`
**New file:** `lib/math_engine/financial/amortization_engine.dart`
- `AmortizationResult` model (periodStart, periodEnd, principalPaid, interestPaid, remainingBalance)
- `amortize(pv, pmt, periodicRate, p1, p2, pmtMode)` — compute BAL/PRN/INT for period range

### Task 2C: Bond Engine — `PENDING`
**New file:** `lib/math_engine/financial/bond_engine.dart`
- `price(couponRate, yield, redemption, frequency, periodsRemaining, accruedInterest)`
- `yield_(price, couponRate, ...)` — Newton-Raphson solver

### Task 2D: Depreciation Engine — `PENDING`
**New file:** `lib/math_engine/financial/depreciation_engine.dart`
- `DepreciationMethod` enum: SL, SYD, DB
- `DepreciationResult` model (year, depreciation, remainingBook, remainingDep)
- `compute(cost, salvage, life, year, method, dbRate, startMonth)`

### Task 2E: Statistics Engine — `PENDING`
**New file:** `lib/math_engine/statistics/statistics_engine.dart`
- `StatModel` enum: LIN, LN, EXP, PWR
- `StatResult` model (n, meanX/Y, sumX/Y, sX/sY, a, b, r)
- `compute(data, model)` — linear regression on transformed data
- `predict(x, a, b, model)` — predict Y from X

### Task 2F: Date Engine — `PENDING`
**New file:** `lib/math_engine/financial/date_engine.dart`
- `DayCountMethod` enum: actual, day360
- `daysBetween(d1, d2, method)` — ACT or US 30/360
- `addDays(date, days)`, `dayOfWeek(date)`

### Task 2G: Break-Even Engine — `PENDING`
**New file:** `lib/math_engine/financial/breakeven_engine.dart`
- Fields: FC (fixed cost), VC (variable cost), P (price), PFT (profit), Q (quantity)
- `solveForQuantity`, `solveForPrice`, `solveForProfit`, `solveForFC`, `solveForVC`

### Task 2H: Profit Engine — `PENDING`
**New file:** `lib/math_engine/financial/profit_engine.dart`
- Margin: `(sell - cost) / sell * 100`
- Markup: `(sell - cost) / cost * 100`
- Solve for CST, SEL, or MAR given the other two

---

## Phase 3: Worksheet State Providers (8 new files) — `DONE`

**New directory:** `lib/features/calculator/providers/worksheets/`

### Task 3A: CF Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/cf_worksheet_provider.dart`
- State: `cashFlows`, `currentIndex`, `iRate`, `npvResult`, `irrResult`, `errorMessage`
- Methods: addCF, deleteCF, setCF, setFrequency, setRate, computeNPV, computeIRR, navigateUp/Down, clear

### Task 3B: Amort Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/amort_worksheet_provider.dart`
- State: `p1`, `p2`, `balResult`, `prnResult`, `intResult`
- Reads TVM values from main `calculatorProvider`

### Task 3C: Bond Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/bond_worksheet_provider.dart`
- State: `sdt`, `cpn`, `rdt`, `rv`, `freq`, `dayCount`, `yld`, `pri`, `ai`

### Task 3D: Depreciation Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/depr_worksheet_provider.dart`
- State: `cost`, `salvage`, `life`, `startMonth`, `year`, `method`, `dep`, `rbv`, `rdv`

### Task 3E: Statistics Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/stat_worksheet_provider.dart`
- State: `dataPoints`, `currentIndex`, `model`, computed stats (n, meanX/Y, sX/Y, a, b, r)

### Task 3F: Date Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/date_worksheet_provider.dart`
- State: `date1`, `date2`, `daysBetween`, `dayCount`, `resultDate`

### Task 3G: Break-Even Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/brkevn_worksheet_provider.dart`
- State: `fc`, `vc`, `price`, `profit`, `quantity`

### Task 3H: Profit Worksheet Provider — `PENDING`
**New file:** `providers/worksheets/profit_worksheet_provider.dart`
- State: `cost`, `selling`, `margin`, `markup`

---

## Phase 4: Worksheet Modal UIs (8 new widget files) — `DONE`

**New directory:** `lib/features/calculator/widgets/worksheets/`

All follow the `_IConvModal` pattern: ConsumerStatefulWidget, glassmorphic styling, AppColors.surface background.

### Task 4A: CF Worksheet Modal — `PENDING`
**New file:** `widgets/worksheets/cf_worksheet_modal.dart`
- Scrollable CF list (CF0, CF1/F1, CF2/F2...) + [Add CF] + I field + [NPV] [IRR] buttons

### Task 4B: Amort Worksheet Modal — `PENDING`
**New file:** `widgets/worksheets/amort_worksheet_modal.dart`
- P1/P2 input fields → [CPT] button → BAL/PRN/INT results

### Task 4C: Bond Worksheet Modal — `PENDING`
**New file:** `widgets/worksheets/bond_worksheet_modal.dart`
- SDT, CPN, RDT, RV, ACT/360 toggle, freq, YLD, PRI fields + [Price] [Yield] buttons

### Task 4D: Depreciation Worksheet Modal — `PENDING`
**New file:** `widgets/worksheets/depr_worksheet_modal.dart`
- CST, SAL, LIF, MON, YR fields + SL/SYD/DB selector + DEP/RBV/RDV results

### Task 4E: Statistics Data Modal — `PENDING`
**New file:** `widgets/worksheets/stat_data_modal.dart`
- Scrollable X/Y pairs + [Add] [Del] + model picker + computed stats display

### Task 4F: Date Worksheet Modal — `PENDING`
**New file:** `widgets/worksheets/date_worksheet_modal.dart`
- DT1/DT2 date pickers + ACT/360 toggle + DBD result + Date±Days section

### Task 4G: Break-Even Worksheet Modal — `PENDING`
**New file:** `widgets/worksheets/brkevn_worksheet_modal.dart`
- FC, VC, P, PFT, Q fields — fill 4, compute 5th

### Task 4H: Profit Worksheet Modal — `PENDING`
**New file:** `widgets/worksheets/profit_worksheet_modal.dart`
- CST, SEL, MAR fields — fill 2, compute 3rd + markup display

---

## Phase 5: Wire All Buttons in Keypad Dispatch — `DONE`

**Modify:** `lib/features/calculator/widgets/full_keypad.dart`

### Task 5A: Update `_KeyAction` enum — `PENDING`
- Add: `arrowUp`, `arrowDown`, `cf`, `npv`, `irr`

### Task 5B: Update row definitions — `PENDING`
- Row 1: `↑` → arrowUp, `↓` → arrowDown
- Row 2: `CF` → cf, `NPV` → npv, `IRR` → irr

### Task 5C: Replace ALL 2ND "coming soon" dispatches — `PENDING`
| Button | 2ND Function | New Action |
|--------|-------------|------------|
| 2ND+ENTER | SET | Cycle option in active worksheet |
| 2ND+↑ | DEL | Delete entry in CF/DATA worksheet |
| 2ND+↓ | INS | Insert entry in CF/DATA worksheet |
| 2ND+NPV | AMORT | Open amort modal |
| 2ND+( | DATA | Open stat data modal |
| 2ND+) | STAT | Compute stats, show results |
| 2ND+yˣ | BOND | Open bond modal |
| 2ND+7 | DEPR | Open depreciation modal |
| 2ND+9 | BRKEVN | Open break-even modal |
| 2ND+4 | DATE | Open date modal |
| 2ND+6 | PROFIT | Open profit modal |
| 2ND+RCL | CLR WORK | Clear active worksheet |

### Task 5D: Update primary dispatch — `PENDING`
- CF → open CF modal
- NPV → compute from CF data (or prompt to enter CFs)
- IRR → compute from CF data (or prompt to enter CFs)
- ↑/↓ → status message if no worksheet active

### Task 5E: Add modal launcher methods — `PENDING`
- 8 new `_showXxxModal()` methods following `_showIConvModal` pattern

---

## Phase 6: Mode Toggle Button Redesign — `DONE`

### Task 6A: Replace floating circle with segmented pill — `PENDING`
**Modify:** `lib/features/calculator/presentation/calculator_shell.dart`
- Remove `Positioned` overlay of `ModeToggleButton`
- Add slim segmented control pill between DisplayPanel and FullKeypad
- ~180px wide, 32px tall, glassmorphic styling
- Two halves: "Keypad" | "Form" with sliding highlight

### Task 6B: Redesign ModeToggleButton → ModeSegmentedControl — `PENDING`
**Modify:** `lib/features/calculator/widgets/mode_toggle_button.dart`
- Glassmorphic pill with two labeled halves
- Sliding highlight animation (300ms ease)
- Replace rotation with smooth slide + crossfade

### Task 6C: Smoother page transition — `PENDING`
**Modify:** `lib/features/calculator/presentation/calculator_shell.dart`
- Curve: `Curves.easeInOutCubicEmphasized`
- Duration: 350ms (down from 500ms)
- Optional: `viewportFraction: 0.95` for peek effect during swipe

---

## Phase 7: Tests — `DONE`

New test files under `test/math_engine/`:
- `financial/cash_flow_engine_test.dart`
- `financial/amortization_engine_test.dart`
- `financial/bond_engine_test.dart`
- `financial/depreciation_engine_test.dart`
- `financial/date_engine_test.dart`
- `financial/breakeven_engine_test.dart`
- `financial/profit_engine_test.dart`
- `statistics/statistics_engine_test.dart`

Each validated against known TI BA II Plus results.

---

## Verification Checklist
- [ ] `flutter build ios --debug` — no compile errors
- [ ] `flutter build apk --debug` — no compile errors
- [ ] Haptic: digits light, operators medium, errors heavy (physical device)
- [ ] Each worksheet: open modal, enter values, compute, verify results
- [ ] Mode switch: no display overlap, smooth segmented pill animation
- [ ] `flutter test` — all math engine tests pass
- [ ] Regression: existing TVM, arithmetic, trig, memory features still work
