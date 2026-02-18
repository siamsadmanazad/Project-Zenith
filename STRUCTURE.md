# Zenith Project Structure

This document describes the complete file structure created for Project Zenith, organized according to the master plan in PROJECT_ZENITH.md §5.

## 📁 Directory Overview

```
Project-ZENITH/
│
├── 📄 PROJECT_ZENITH.md          # Master build plan (complete roadmap)
├── 📄 README.md                  # Public-facing README (links to master plan)
├── 📄 STRUCTURE.md               # This file - structure documentation
├── 📄 pubspec.yaml               # Flutter dependencies
├── 📄 analysis_options.yaml      # Lint rules
│
├── 📁 lib/                       # Flutter application code
│   ├── 📄 main.dart              # App entry point
│   │
│   ├── 📁 core/                  # Core infrastructure
│   │   ├── 📁 constants/
│   │   │   ├── app_colors.dart          # Nordic color palette
│   │   │   ├── app_typography.dart      # Inter + SF Pro typography
│   │   │   ├── app_dimensions.dart      # Spacing & sizing constants
│   │   │   └── app_strings.dart         # Localized strings
│   │   │
│   │   ├── 📁 theme/
│   │   │   ├── zenith_theme.dart        # Master theme configuration
│   │   │   ├── nordic_theme.dart        # Nordic Minimalism (free)
│   │   │   ├── glassmorphism_theme.dart # Premium theme ($4.99)
│   │   │   ├── retro_ti_theme.dart      # TI-84 nostalgia theme ($4.99)
│   │   │   └── theme_provider.dart      # Riverpod theme state
│   │   │
│   │   ├── 📁 utils/
│   │   │   ├── haptic_engine.dart       # Premium haptic feedback
│   │   │   ├── number_formatter.dart    # Currency/percentage formatting
│   │   │   ├── pdf_generator.dart       # PDF export (Phase 2)
│   │   │   └── social_export.dart       # Social media graphics (Phase 2)
│   │   │
│   │   └── 📁 errors/
│   │       ├── calculation_error.dart   # Math error handling
│   │       └── network_error.dart       # API error handling
│   │
│   ├── 📁 math_engine/           # ★ THE CORE - Financial calculations
│   │   ├── 📁 tvm/
│   │   │   ├── tvm_solver.dart          # ★ THE BIG FIVE solver
│   │   │   ├── tvm_validator.dart       # Input validation
│   │   │   └── tvm_models.dart          # Data models
│   │   │
│   │   ├── 📁 worksheets/
│   │   │   ├── amortization.dart        # Loan amortization (Phase 2)
│   │   │   ├── cash_flow.dart           # NPV/IRR (Phase 2)
│   │   │   ├── depreciation.dart        # Asset depreciation (Phase 2)
│   │   │   ├── bond_pricing.dart        # Bond calculations (Phase 2)
│   │   │   └── breakeven.dart           # Break-even analysis (Phase 2)
│   │   │
│   │   └── 📁 precision/
│   │       ├── decimal_handler.dart     # Decimal package wrapper
│   │       └── rounding_rules.dart      # TI-BA II Plus AOS logic
│   │
│   ├── 📁 features/              # UI Features
│   │   ├── 📁 calculator/
│   │   │   ├── 📁 presentation/
│   │   │   │   └── calculator_screen.dart
│   │   │   ├── 📁 providers/
│   │   │   │   └── calculator_provider.dart
│   │   │   └── 📁 widgets/
│   │   │       └── glass_button.dart    # Glassmorphic button component
│   │   │
│   │   ├── 📁 worksheets/        # Phase 2
│   │   │   ├── 📁 presentation/
│   │   │   └── 📁 widgets/
│   │   │
│   │   ├── 📁 themes_store/      # Phase 3
│   │   ├── 📁 rates/             # Phase 3
│   │   ├── 📁 export/            # Phase 2
│   │   ├── 📁 voice/             # Phase 4
│   │   └── 📁 ai_insights/       # Phase 4
│   │
│   ├── 📁 services/              # External services
│   │   ├── storage_service.dart         # Isar DB operations (Phase 2)
│   │   ├── affiliate_service.dart       # Affiliate API (Phase 3)
│   │   ├── rate_service.dart            # Market rates API (Phase 3)
│   │   └── analytics_service.dart       # Anonymous analytics (Phase 3)
│   │
│   └── 📁 routing/
│       └── app_router.dart              # GoRouter configuration
│
├── 📁 backend/                   # FastAPI server (Phase 3)
│   ├── 📄 main.py                       # Server entry point
│   ├── 📄 requirements.txt              # Python dependencies
│   ├── 📄 Dockerfile                    # Container config
│   │
│   ├── 📁 routers/
│   │   ├── offers.py                    # GET /v1/offers
│   │   ├── rates.py                     # GET /v1/rates
│   │   └── analytics.py                 # POST /v1/analytics
│   │
│   ├── 📁 services/              # TODO: Phase 3
│   └── 📁 models/                # TODO: Phase 3
│
├── 📁 test/                      # Unit & integration tests
│   ├── 📁 math_engine/
│   │   └── tvm_test.dart                # ★ TVM vs TI-BA II Plus tests
│   ├── 📁 widgets/
│   └── 📁 integration/
│
├── 📁 android/                   # Android platform config
├── 📁 ios/                       # iOS platform config
├── 📁 web/                       # PWA config
├── 📁 linux/                     # Linux platform config
├── 📁 macos/                     # macOS platform config
└── 📁 windows/                   # Windows platform config
```

## 🎯 Implementation Status by Phase

### ✅ Phase 0: Project Setup (COMPLETE)
- ✅ Directory structure created
- ✅ Core files with proper comments
- ✅ TODO markers for each phase
- 🔲 Dependencies need to be added to pubspec.yaml

### 🔲 Phase 1: Core Engine (v1.0) - NEXT STEPS
Priority files to implement:
1. **TVM Solver** (`lib/math_engine/tvm/tvm_solver.dart`) - Complete the Newton-Raphson solver for I/Y
2. **Calculator Screen** (`lib/features/calculator/presentation/calculator_screen.dart`)
3. **Calculator Provider** (`lib/features/calculator/providers/calculator_provider.dart`)
4. **Unit Tests** (`test/math_engine/tvm_test.dart`) - Test against TI-BA II Plus

### 🔲 Phase 2: Professional Suite (v1.5)
- Worksheets implementation
- PDF generation
- Social export
- Verification Suite

### 🔲 Phase 3: Monetization (v2.0)
- Theme Engine
- FastAPI backend deployment
- Affiliate integration
- In-app purchases

### 🔲 Phase 4: AI Layer (v3.0)
- Voice input
- AI insights
- Contextual intelligence

## 📦 Required Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9

  # Routing
  go_router: ^13.0.0

  # Math (High Precision)
  decimal: ^2.3.3
  # TODO: Add curo package when available

  # Local Storage
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.1

  # UI
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0

  # Utilities
  url_launcher: ^6.2.2
  intl: ^0.18.1

  # Network (Phase 3)
  http: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

  # Code Generation
  build_runner: ^2.4.6
  isar_generator: ^3.1.0+1
```

## 🚀 Next Steps

1. **Update pubspec.yaml** with dependencies
2. **Run `flutter pub get`**
3. **Implement TVM Solver completely** (finish Newton-Raphson for I/Y)
4. **Build Calculator UI** with glassmorphic design
5. **Write comprehensive tests** against TI-BA II Plus
6. **Set up PWA** (manifest.json + service worker)
7. **Deploy v1.0** (web + app stores)

## 📝 Notes

- All files include proper phase markers (Phase 1, Phase 2, etc.)
- TODO comments guide implementation
- Structure follows PROJECT_ZENITH.md §5 exactly
- Backend ready for Phase 3 deployment
- Tests structured for TDD approach

## 🔗 Key Files Reference

| Purpose | File Location |
|---------|---------------|
| App Entry | `lib/main.dart` |
| TVM Solver | `lib/math_engine/tvm/tvm_solver.dart` |
| Calculator Screen | `lib/features/calculator/presentation/calculator_screen.dart` |
| Theme Config | `lib/core/theme/zenith_theme.dart` |
| Backend API | `backend/main.py` |
| Tests | `test/math_engine/tvm_test.dart` |

---

**For complete project vision and roadmap, see [PROJECT_ZENITH.md](PROJECT_ZENITH.md)**
