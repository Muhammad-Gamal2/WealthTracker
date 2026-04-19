# WealthTracker UI Design — Screen Layouts

Refer to `01_foundations.md` for colours/typography and `02_components.md` for component specs.

---

## Screen 1 — Lock Screen (`/lock`)

**Purpose:** PIN entry gate on every app launch. Optional biometric shortcut.

### Layout
```
┌──────────────────────────────────────┐
│                                      │
│                                      │
│              🔒                      │  ← lock_outline icon, 48dp, primary colour
│          WealthTracker               │  ← headlineSmall bold
│          Enter your PIN              │  ← bodyMedium, 60% opacity
│                                      │
│    ┌────┐  ┌────┐  ┌────┐  ┌────┐   │
│    │    │  │    │  │    │  │    │   │  ← PIN dots (flutter_screen_lock widget)
│    └────┘  └────┘  └────┘  └────┘   │
│                                      │
│    [ 1 ]   [ 2 ]   [ 3 ]            │
│    [ 4 ]   [ 5 ]   [ 6 ]            │  ← digit pad
│    [ 7 ]   [ 8 ]   [ 9 ]            │
│            [ 0 ]   [⌫]              │
│                                      │
│      [ 👆 Use Biometrics ]           │  ← TextButton.icon (hidden on web or if disabled)
│                                      │
└──────────────────────────────────────┘
```

### States
| State              | UI                                                  |
|--------------------|-----------------------------------------------------|
| Normal             | Title + PIN pad shown                               |
| Trying biometric   | Full-screen `CircularProgressIndicator` (centred)   |
| Wrong PIN          | flutter_screen_lock handles shake animation         |

### Rules
- Background: `colorScheme.surface` (set via `ScreenLockConfig`)
- Biometric button hidden when: `kIsWeb` OR `biometricAvailableSignal = false` OR `useBiometricSignal = false`
- On successful unlock: `Navigator.pushReplacementNamed → /`

---

## Screen 2 — Dashboard (`/`)

**Purpose:** Single-glance total wealth overview with breakdown and history.

### Layout (Mobile)
```
┌──────────────────────────────────────┐
│  WealthTracker              [⟳] [⚙] │  ← AppBar
├──────────────────────────────────────┤
│  Total Wealth                        │
│  EGP 12,450,000                      │  ← Hero gradient header
│  USD 258,000                         │
├──────────────────────────────────────┤
│  Breakdown                           │  ← titleMedium bold, 16dp left pad
│                                      │
│  ┌────────────────────────────────┐  │
│  │  [Pie Chart — 200dp tall]      │  │  ← WealthPieChart widget
│  │  ● Gold  ● Stocks  ● Liq  ● RE │  │  ← legend wrap
│  └────────────────────────────────┘  │
│                                      │
│  ┌─────────────┐  ┌─────────────┐   │
│  │ [■] Gold    │  │             │   │  ← CategorySummaryCard (1 col on mobile)
│  │  EGP 3.0M  │  │             │   │
│  │  USD 62K   │  │             │   │
│  └─────────────┘  └─────────────┘   │
│  (Stocks / Liquidity / RealEstate)   │
│                                      │
│  History         [30D][90D][1Y][All] │  ← titleMedium + SegmentedButton
│                                      │
│  ┌────────────────────────────────┐  │
│  │  [Line Chart — 180dp tall]     │  │  ← WealthLineChart
│  └────────────────────────────────┘  │
├──────────────────────────────────────┤
│  [Dashboard] [Gold] [Stocks] [Liq] [Estate] │  ← NavigationBar
└──────────────────────────────────────┘
```

### Layout (Wide > 800dp)
Category cards change to 2-column grid. Everything else stays single column.

### States
| Area             | Loading                    | Error                            | Empty                           |
|------------------|----------------------------|----------------------------------|---------------------------------|
| Wealth header    | `CircularProgressIndicator`| Values show as 0                 | Values show as 0                |
| Pie chart        | —                          | —                                | "Add items to see breakdown"    |
| Category cards   | Show 0 values              | Show 0 values                    | Show 0 values                   |
| Line chart       | —                          | —                                | "Chart will appear after 2+ days"|
| AppBar action    | Spinner replaces ⟳          | ⟳ icon, error card shows below  | ⟳ icon                          |

---

## Screen 3 — Gold (`/gold`)

**Purpose:** Manage gold holdings. View live karat prices.

### Layout
```
┌──────────────────────────────────────┐
│  ← Gold                     [⟳]     │  ← AppBar
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │  Current Gold Prices (EGP/g)   │  │  ← Price header card
│  │  24K        22K        21K  18K│  │
│  │  4,800      4,400      4,200...│  │
│  │  ⚠ Prices may be outdated     │  │  ← conditional
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ [🥇] Wedding Ring    EGP 210K [⋮]│  ← GoldItemTile
│  │      21K · 50g               │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │ [🥇] Bullion Bar     EGP 480K [⋮]│
│  │      24K · 100g              │  │
│  └────────────────────────────────┘  │
│                                      │
│                              [  +  ] │  ← FAB
├──────────────────────────────────────┤
│  [Dashboard] [Gold] [Stocks]...      │
└──────────────────────────────────────┘
```

### Add Gold Dialog Fields
| Field          | Type          | Hint                     | Validation         |
|----------------|---------------|--------------------------|--------------------|
| Label          | Text          | "e.g. Wedding Ring"      | Required           |
| Weight (grams) | Number        | suffix: "g"              | Required, > 0      |
| Karat          | Dropdown      | Options: 24K 22K 21K 18K | Required           |

### Gold Item Tile Detail
- Leading icon: `Icons.savings`, colour `#FFD700`
- Title: item label
- Subtitle: `"{karat}K · {weight}g"`
- Trailing: `CurrencyFormatter.formatEgp(weight × pricePerGram)`

---

## Screen 4 — Stocks (`/stocks`)

**Purpose:** Manage stock holdings for EGX and US markets.

### Layout
```
┌──────────────────────────────────────┐
│  ← Stocks                   [⟳]     │
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │  Market Prices                 │  │  ← Rate info card (USD/EGP rate)
│  │  USD/EGP: 48.5                 │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ (EGX) COMI  Comm. Intl  120K  +8.3%│  ← StockItemTile
│  │       1,200 shares · EGP 100  │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │ (US)  AAPL  Apple Inc.  580K  +2.1%│
│  │       10 shares · USD 198     │  │
│  └────────────────────────────────┘  │
│                                      │
│                              [  +  ] │
├──────────────────────────────────────┤
│  [Dashboard] [Gold] [Stocks]...      │
└──────────────────────────────────────┘
```

### Add Stock Dialog Fields
| Field          | Type          | Hint                         | Validation           |
|----------------|---------------|------------------------------|----------------------|
| Market         | SegmentedButton | EGX / US                   | Required             |
| Symbol         | Text          | "e.g. COMI or AAPL"          | Required, uppercase  |
| Name           | Text          | "Company name (optional)"    | Optional             |
| Quantity       | Number        | "Number of shares"           | Required, > 0        |
| Purchase Price | Number        | "Price per share (EGP / USD)"| Required, > 0        |

- Market selector toggles the purchase price currency label (EGP / USD)
- Symbol is sent to Twelve Data with `:XCAI` suffix appended for EGX automatically

---

## Screen 5 — Liquidity (`/liquidity`)

**Purpose:** Track USD cash holdings and see EGP equivalent.

### Layout
```
┌──────────────────────────────────────┐
│  ← Liquidity                [⟳]     │
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │  Exchange Rate                 │  │  ← Rate card
│  │  1 USD = EGP 48.50             │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ [💧] Savings Account  EGP 97K [⋮]│  ← LiquidityItemTile
│  │      USD 2,000                 │  │
│  └────────────────────────────────┘  │
│                                      │
│                              [  +  ] │
├──────────────────────────────────────┤
│  [Dashboard] [Gold] [Stocks]...      │
└──────────────────────────────────────┘
```

### Add Liquidity Dialog Fields
| Field      | Type   | Hint                     | Validation    |
|------------|--------|--------------------------|---------------|
| Label      | Text   | "e.g. Savings Account"   | Required      |
| Amount USD | Number | "Amount in US dollars"   | Required, > 0 |

### Liquidity Item Tile Detail
- Leading icon: `Icons.water_drop`, colour `#2196F3`
- Title: item label
- Subtitle: `CurrencyFormatter.formatUsd(amountUsd)`
- Trailing: `CurrencyFormatter.formatEgp(amountUsd × usdToEgpRate)`

---

## Screen 6 — Real Estate (`/real-estate`)

**Purpose:** Track properties with compound appreciation.

### Layout
```
┌──────────────────────────────────────┐
│  ← Real Estate              [⟳]     │
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │ [🏠] Maadi Apt.    EGP 2.6M [⋮]│  ← RealEstateItemTile
│  │      Bought: EGP 2M · 10%/yr  │  │
│  │      3.2 years · +33%         │  │
│  └────────────────────────────────┘  │
│                                      │
│                              [  +  ] │
├──────────────────────────────────────┤
│  [Dashboard] [Gold] [Stocks]...      │
└──────────────────────────────────────┘
```

### Add Real Estate Dialog Fields
| Field                     | Type      | Hint                          | Validation    |
|---------------------------|-----------|-------------------------------|---------------|
| Project Name              | Text      | "e.g. Maadi Apartment"        | Required      |
| Purchase Date             | Date picker| Tap to select                | Required      |
| Purchase Amount (EGP)     | Number    | "Original purchase price"     | Required, > 0 |
| Annual Appreciation (%)   | Number    | "Expected annual growth %"    | Required, ≥ 0 |

### Real Estate Item Tile Detail
- Leading icon: `Icons.home_work`, colour `#FF5722`
- Title: project name
- Subtitle: `"Bought: EGP {purchase} · {rate}%/yr · {years}y elapsed"`
- Trailing: `CurrencyFormatter.formatEgp(currentValue)` — compound formula:
  `purchase × (1 + rate/100)^yearsElapsed`

---

## Screen 7 — Settings (`/settings`)

**Purpose:** Configure API keys, PIN, biometrics, and appearance.

### Layout
```
┌──────────────────────────────────────┐
│  ← Settings                          │  ← AppBar (no extra actions)
├──────────────────────────────────────┤
│  [🔑] API Keys                       │  ← Section header
│                                      │
│  ┌────────────────────────────────┐  │
│  │  GoldAPI.io Key                │  │  ← API Key Card
│  │  [••••••••••••••]  [👁] [💾]  │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │  Twelve Data API Key           │  │
│  │  [••••••••••••••]  [👁] [💾]  │  │
│  └────────────────────────────────┘  │
│                                      │
│  [🔒] Security                       │  ← Section header
│                                      │
│  [📌] Set PIN                    [>] │  ← ListTile
│  [🔓] Remove PIN                     │  ← shown only if PIN is set, error colour
│  [👆] Biometric Unlock    [toggle]   │  ← SwitchListTile (hidden on web)
│       Use fingerprint or Face ID     │
│                                      │
│  [🎨] Appearance                     │  ← Section header
│                                      │
│  [🌙] Dark Mode           [toggle]   │  ← SwitchListTile
│                                      │
└──────────────────────────────────────┘
```

### Set PIN Flow
Tapping "Set PIN" triggers `screenLockCreate()` (flutter_screen_lock):
1. Full-screen PIN pad appears: "Enter new PIN"
2. User enters 4-digit PIN
3. PIN pad asks "Confirm PIN"
4. User re-enters — if match, PIN saved + SnackBar "PIN set successfully"
5. If no match, shake animation + retry

### Biometric toggle (platform visibility)
- Hidden entirely on `kIsWeb`
- Shown on iOS/Android/macOS when `biometricAvailableSignal = true`
- Toggle saves to `AppSettings` table via `useBiometric` key

---

## Dialogs Summary

| Dialog              | Trigger                  | Title              | Primary action  |
|---------------------|--------------------------|--------------------|-----------------|
| Add Gold            | FAB on Gold screen       | "Add Gold"         | FilledButton "Add" |
| Edit Gold           | Popup menu → Edit        | "Edit Gold Item"   | FilledButton "Save" |
| Delete Gold         | Popup menu → Delete      | "Delete Gold Item" | TextButton "Delete" (error) |
| Add Stock           | FAB on Stocks screen     | "Add Stock"        | FilledButton "Add" |
| Edit Stock          | Popup menu → Edit        | "Edit Stock"       | FilledButton "Save" |
| Delete Stock        | Popup menu → Delete      | "Delete Stock"     | TextButton "Delete" (error) |
| Add Liquidity       | FAB on Liquidity screen  | "Add Liquidity"    | FilledButton "Add" |
| Edit Liquidity      | Popup menu → Edit        | "Edit Liquidity"   | FilledButton "Save" |
| Delete Liquidity    | Popup menu → Delete      | "Delete Liquidity" | TextButton "Delete" (error) |
| Add Real Estate     | FAB on RE screen         | "Add Property"     | FilledButton "Add" |
| Edit Real Estate    | Popup menu → Edit        | "Edit Property"    | FilledButton "Save" |
| Delete Real Estate  | Popup menu → Delete      | "Delete Property"  | TextButton "Delete" (error) |
| Remove PIN          | Settings → Remove PIN    | "Remove PIN"       | TextButton "Remove" (error) |
