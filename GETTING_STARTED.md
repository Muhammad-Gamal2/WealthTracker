# WealthTracker - Getting Started

## First-time Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Generate Drift database code
```bash
dart run build_runner build --delete-conflicting-outputs
```
This generates `lib/core/database/app_database.g.dart` (the Drift SQLite adapter).

### 3. Run the app
```bash
# Web
flutter run -d chrome

# macOS
flutter run -d macos

# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## API Key Setup

On first launch, go to **Settings** and enter your API keys:

| Service | Where to get it | Free tier |
|---------|----------------|-----------|
| **GoldAPI.io** | https://www.goldapi.io | 300 calls/month |
| **Twelve Data** | https://twelvedata.com | 800 calls/day |
| **Exchange Rate** | No key needed | Free |

---

## Architecture

```
Feature-first Clean Architecture:
  features/<name>/
    domain/       # Entities + abstract repository contracts (pure Dart)
    data/         # Repository implementations + Drift DAOs
    presentation/ # Signals state + Flutter screens/widgets
```

**State management:** Signals (`signals_flutter`) — reactive, zero boilerplate  
**Database:** Drift (SQLite) — type-safe, reactive queries  
**DI:** get_it — simple singleton service locator

---

## Adding a New Stock

1. Open the **Stocks** screen
2. Tap **+**
3. Select market: **EGX** (Egypt) or **US**
4. Enter the symbol (e.g. `COMI` for EGX or `AAPL` for US)
5. Enter quantity and purchase price

EGX stocks use the `:XCAI` suffix automatically. Prices update once per day or when you tap **Refresh**.

---

## Real Estate Appreciation

The app uses **compound appreciation**:

```
currentValue = purchaseAmount × (1 + rate/100)^yearsElapsed
```

For example, a property bought for 2,000,000 EGP with 10%/year appreciation in 3 years:
```
2,000,000 × (1.10)^3 = 2,662,000 EGP
```
