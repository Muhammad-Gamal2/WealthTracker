# WealthTracker UI Design — Component Library

All components are built with Material 3 widgets. Refer to `01_foundations.md` for colours, spacing, and typography tokens.

---

## 1. Bottom Navigation Bar

**Widget:** `NavigationBar`
**Placement:** Bottom of every main screen (Dashboard, Gold, Stocks, Liquidity, Real Estate).
Settings is NOT in the bar — accessed via AppBar icon.

```
┌─────────────────────────────────────────────────────────┐
│  [Dashboard]  [Gold]  [Stocks]  [Liquidity]  [Estate]  │
│       ●                                                  │  ← selected indicator pill
└─────────────────────────────────────────────────────────┘
```

- Background: `colorScheme.surfaceVariant`
- Selected item: pill indicator in `colorScheme.secondaryContainer`, icon + label in `colorScheme.onSecondaryContainer`
- Unselected item: icon only visible, label hidden (M3 default)
- Active screen is derived from `ModalRoute.of(context).settings.name`

---

## 2. AppBar

**Widget:** `AppBar` (flat, no elevation)

**Standard AppBar (feature screens):**
```
┌──────────────────────────────────────────────┐
│  ← (back)    Screen Title          [Refresh] │
└──────────────────────────────────────────────┘
```

**Dashboard AppBar:**
```
┌──────────────────────────────────────────────┐
│       WealthTracker         [⟳]  [Settings] │
└──────────────────────────────────────────────┘
```
- While refreshing: spinner (20×20 dp, strokeWidth 2) replaces ⟳ icon
- Settings icon navigates to `/settings` via `pushNamed`

---

## 3. Hero Wealth Header (Dashboard only)

**Widget:** `Container` with `LinearGradient`

```
┌──────────────────────────────────────────────┐
│  Total Wealth                                │  ← labelLarge, 70% opacity
│  EGP 12,450,000                              │  ← headlineMedium, bold
│  USD 258,000                                 │  ← titleMedium, 80% opacity
└──────────────────────────────────────────────┘
```

- Full width, horizontal padding 20 dp, vertical padding 24 dp
- Gradient: `primaryContainer` (top-left) → `secondaryContainer` (bottom-right)
- All text colours: `onPrimaryContainer`
- Loading state: `CircularProgressIndicator` replaces the EGP amount

---

## 4. Category Summary Card (Dashboard)

**Widget:** `Card` > `InkWell` > `Padding(14)`
Tappable — navigates to the corresponding feature screen.

```
┌────────────────────────────────────────┐
│  [■] Gold                    24.3%    │  ← icon badge + labelLarge + percent badge
│                                        │
│  EGP 3,021,450                        │  ← titleMedium bold
│  USD 62,900                           │  ← bodySmall, 60% opacity
└────────────────────────────────────────┘
```

**Icon badge:** 6dp padding, `borderRadius 8`, background `categoryColor @ 15%`, icon size 18
**Percent badge:** horizontal 8dp, vertical 3dp padding, `borderRadius 12`, background `categoryColor @ 15%`, text 11sp bold `categoryColor`

Layout on mobile: full-width column, `SizedBox(height: 10)` between sections.
Layout on wide (>800dp): 2-column grid, `childAspectRatio: 2.2`.

---

## 5. Item Tile (Gold / Liquidity / Real Estate)

**Widget:** `Card` > `ListTile`

```
┌──────────────────────────────────────────────────────┐
│  [■]  Label name              EGP 450,000   [⋮]     │
│       21K · 50g               (popup menu)           │
└──────────────────────────────────────────────────────┘
```

- **Leading:** Icon container — 8dp padding, `borderRadius 8`, `categoryColor @ 15%` bg, icon size 20, icon colour `categoryColor`
- **Title:** `fontWeight: w600`
- **Subtitle:** secondary info (karat + grams / USD amount / property details)
- **Trailing:** Row with `Text(value, bold)` + `PopupMenuButton`
  - Popup items: "Edit" and "Delete"
  - Tap on tile = open edit dialog; no long-press dependency (popup menu handles both)

---

## 6. Stock Item Tile (Stocks screen)

```
┌────────────────────────────────────────────────────────────┐
│  (EGX)  COMI  Commercial Intl Bank    EGP 120,000  +8.3%  │
│         1,200 shares · Current: EGP 100              [⋮]  │
└────────────────────────────────────────────────────────────┘
```

- **Leading:** `CircleAvatar` — EGX = `secondaryContainer` bg; US = `tertiaryContainer` bg. Text inside = market label, 10sp bold.
- **Title:** `symbol` bold + `name` in `bodySmall`, ellipsis overflow
- **Subtitle:** quantity + current price (EGP for EGX, USD for US)
- **Trailing:** Column — EGP total value (bold) + gain/loss percent
  - Positive: `Colors.green`, Negative: `Colors.red`
- Tap opens edit dialog; long-press opens delete confirm (note: also has popup menu)

---

## 7. Price / Info Header Card (Gold & Stocks screens)

**Widget:** `Card(margin: 12)` > `Padding(12)` > `Column`

```
┌──────────────────────────────────────────────────────┐
│  Current Gold Prices (EGP/gram)                      │  ← labelLarge
│                                                      │
│  24K          22K          21K          18K          │  ← Wrap row
│  EGP 4,800    EGP 4,400    EGP 4,200    EGP 3,600    │
│                                                      │
│  ⚠ Prices may be outdated                           │  ← conditional stale badge
└──────────────────────────────────────────────────────┘
```

Karat chip layout:
```
  24K          ← labelSmall, bold
  EGP 4,800    ← bodySmall
```

**Stale data badge:**
```
  [⚠] Prices may be outdated   ← icon 14dp + labelSmall, both colorScheme.error
```

---

## 8. Add / Edit Dialog

**Widget:** `AlertDialog`

```
┌──────────────────────────────────────────────┐
│  Add Gold                                    │  ← title
│  ──────────────────────────────────────────  │
│  Label *                                     │
│  ┌──────────────────────────────────────┐    │
│  │ e.g. Wedding Ring                    │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  Weight (grams) *                            │
│  ┌────────────────────────────────── g ─┐    │
│  │ 50                                   │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  Karat                                       │
│  ┌──────────────────────────────────────┐    │
│  │ 21K                               ▼  │    │
│  └──────────────────────────────────────┘    │
│  ──────────────────────────────────────────  │
│                        [Cancel]  [Add]        │
└──────────────────────────────────────────────┘
```

- Content scrollable via `SingleChildScrollView`
- `mainAxisSize: MainAxisSize.min` on inner `Column`
- 12dp spacing between fields
- `TextButton` for Cancel, `FilledButton` for Save/Add
- Edit mode: title = "Edit {Type}", button = "Save"
- All fields have validation; error shown inline under field

---

## 9. Delete Confirmation Dialog

```
┌──────────────────────────────────────────────┐
│  Delete Item                                 │
│  ──────────────────────────────────────────  │
│  Remove "Wedding Ring"?                      │
│  ──────────────────────────────────────────  │
│                       [Cancel]  [Delete]      │  ← Delete in colorScheme.error
└──────────────────────────────────────────────┘
```

---

## 10. Floating Action Button (FAB)

Standard `FloatingActionButton` with `Icons.add`.
Positioned bottom-right (default Flutter placement).
Present on: Gold, Stocks, Liquidity, Real Estate screens.
NOT present on: Dashboard, Settings, Lock screen.

---

## 11. Wealth Pie Chart

**Widget:** `PieChart` (fl_chart), height 200dp

```
                  Gold 24.3%
         ┌────────────────────────┐
         │       ┌──────┐        │
         │  Real │      │ Stocks │
         │Estate │      │        │
         │       └──────┘        │
         │     Liquidity         │
         └────────────────────────┘

   ● Gold  EGP 3M    ● Stocks  EGP 2.5M
   ● Liquidity EGP 1M    ● Real Estate EGP 4M
```

- Donut chart, `centerSpaceRadius: 45`, `sectionsSpace: 3`
- Default section radius: 55dp → 65dp on tap (with tooltip badge)
- Slice colours = category accent colours
- Label inside slice: percentage (hidden if < 5%)
- On tap: badge floats above slice showing category name + EGP value, navigates to that screen on `FlTapUpEvent`
- Legend below chart: `Wrap`, 16dp horizontal spacing, 6dp run spacing, centered
- Empty state: plain centered text "Add items to see your wealth breakdown"

---

## 12. Wealth Line Chart

**Widget:** `LineChart` (fl_chart), height 180dp

```
  5.2M │                              ╭──
  4.8M │                         ╭───╯
  4.4M │              ╭─────────╯
  4.0M │   ╭──────────╯
       └──────────────────────────────────
         Jan    Feb    Mar    Apr
```

- Line colour: `colorScheme.primary`, width 2.5dp, curved
- Fill below line: `colorScheme.primary @ 10%`
- Dots shown only when ≤ 30 data points (radius 3, white stroke)
- Left axis: abbreviated amounts (K / M suffix), 9sp
- Bottom axis: short date labels, 9sp, shown every ~N/4 points when dense
- Grid: horizontal lines only, `Colors.grey @ 20%`
- No border
- Touch tooltip: white bold text, date + EGP value
- Empty state (< 2 days data): centred text, height 160dp

---

## 13. Period Selector (Dashboard)

**Widget:** `SegmentedButton<int>`

```
  [ 30D ]  [ 90D ]  [  1Y  ]  [ All ]
```

- `visualDensity: compact`, `tapTargetSize: shrinkWrap`
- Placed in a `Row` with the "History" section title (`spaceBetween`)
- Selected segment uses `colorScheme.secondaryContainer`

---

## 14. Settings Row Patterns

**Section Header:**
```
  [icon]  Section Title   ← icon 18dp primary, titleSmall bold primary
```

**API Key Card:**
```
┌──────────────────────────────────────────────────┐
│  GoldAPI.io Key                 ← labelLarge     │
│  ┌────────────────────────── [👁] [💾] ─────┐    │
│  │ ••••••••••••••••••••••••                 │    │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
```
- `OutlineInputBorder`, `obscureText` toggleable
- Two suffix icons: visibility toggle + save button
- Save triggers SnackBar "Key saved", 2s duration

**Switch Row:**
```
  [icon]  Title                              [  ○  ]
          Subtitle
```
`SwitchListTile` — secondary icon, title, optional subtitle, trailing switch.

**Navigation Row:**
```
  [icon]  Set PIN                            [  >  ]
```
`ListTile` with `Icons.chevron_right` trailing.

**Destructive Row:**
```
  [icon]  Remove PIN     ← both icon and text in colorScheme.error
```

---

## 15. Snackbar

Bottom-anchored, 2-second auto-dismiss.
```
  ┌──────────────────────────────────────────────┐
  │  GoldAPI.io Key saved                        │
  └──────────────────────────────────────────────┘
```

---

## 16. Error Card (Dashboard)

Shown when the price refresh fails but partial data is available.

```
┌──────────────────────────────────────────────┐
│  [⚠]  Update error                          │  ← errorContainer background
│       Connection timeout: ...                │  ← small text, onErrorContainer
└──────────────────────────────────────────────┘
```

`Card(color: colorScheme.errorContainer)`, margin 12dp.

---

## 17. Empty State

Used consistently across all list screens when no items exist.

```
         (centred in available space)

         No gold items yet.
         Tap + to add one.
```

`Center` > `Text`, `textAlign: center`, default body text colour.

---

## 18. Loading State

`Center(child: CircularProgressIndicator())` — full screen height, centred.
Used when `loadingSignal.value == true` before any data is available.
Inline spinner in AppBar during refresh: `SizedBox(20×20)`, `strokeWidth: 2`.
