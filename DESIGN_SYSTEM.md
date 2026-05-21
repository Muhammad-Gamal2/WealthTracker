# WealthTracker Design System

A guide for designing new screens that match the existing app.

---

## Color System

### Adaptive Colors (change with dark/light mode)

| Token       | Dark Mode      | Light Mode     | Usage                          |
|-------------|----------------|----------------|--------------------------------|
| `bg`        | `#07090F`      | `#F5F6FA`      | Page background                |
| `surface`   | `#0D1119`      | `#FFFFFF`      | Sidebar, panels                |
| `surface2`  | `#141B28`      | `#F0F1F5`      | Dialogs, bottom sheets, popups |
| `card`      | white @ 3.5%   | black @ 3%     | Card fill                      |
| `border`    | white @ 7.5%   | black @ 12%    | All borders and dividers       |
| `text1`     | `#EEF2FF`      | `#1A1D26`      | Primary text                   |
| `text2`     | `#EEF2FF` 62%  | `#1A1D26` 60%  | Secondary/supporting text      |
| `text3`     | `#EEF2FF` 34%  | `#1A1D26` 34%  | Hints, labels, tertiary text   |
| `headerBg`  | `#07090F` 72%  | `#F5F6FA` 87%  | Sticky header bar background   |
| `navBg`     | `#07090F` 94%  | `#F5F6FA` 94%  | Bottom navigation background   |
| `inputFill` | white @ 5%     | black @ 4%     | Text field fill, chip bg       |

### Fixed Brand Colors (same in both modes)

| Token       | Hex         | Usage                              |
|-------------|-------------|------------------------------------|
| `accent`    | `#5B9BFF`   | Primary action, links, active nav  |
| `gold`      | `#FFCA28`   | Gold category                      |
| `green`     | `#34D399`   | Stocks category, gain indicator    |
| `cyan`      | `#38BDF8`   | Liquidity category                 |
| `orange`    | `#FB923C`   | Real estate category               |
| `lossRed`   | `#F87171`   | Loss indicator, destructive action |
| `gainGreen` | `#34D399`   | Gain indicator                     |

Each category color has a `Bg` variant at 12% opacity (e.g. `goldBg = #FFCA28` @ 12%) used for icon backgrounds, badges, and tinted containers.

---

## Typography

Three font families, each with a specific role:

| Role        | Font            | Sizes Used       | Weights    | Usage                                |
|-------------|-----------------|------------------|------------|--------------------------------------|
| **Display** | Space Grotesk   | 18, 20, 24       | 500–700    | Screen titles, dialog titles, headers |
| **Body**    | DM Sans         | 11, 12, 13, 14   | 400–700    | Body text, labels, buttons, captions  |
| **Mono**    | DM Mono         | 11, 12, 13, 14, 15, 34 | 400–700 | Currency values, percentages, numbers |

### Common Text Patterns

- **Screen title**: Space Grotesk / 18 / w700 / `text1`
- **Section label**: DM Sans / 11 / w700 / `text3` / uppercase / letter-spacing 0.07em
- **Card primary value**: DM Mono / 14–15 / w700 / `text1`
- **Card secondary value**: DM Mono / 11–12 / w400–500 / `text3`
- **List item title**: DM Sans / 14 / w600 / `text1`
- **List item subtitle**: DM Sans / 12 / w400 / `text3`
- **Button label**: DM Sans / 14 / w600–700
- **Gain/loss percent**: DM Mono / 11–12 / w600–700 / `gainGreen` or `lossRed`

---

## Shape & Spacing

- **Corner radius**: 14px everywhere (cards, buttons, dialogs, inputs, popups)
- **Small radius**: 8–10px for badges, chips, icon containers, karat toggle buttons
- **Bottom sheet top radius**: 22px

### Standard Spacing Values

| Context                    | Value            |
|----------------------------|------------------|
| Screen horizontal padding  | 16px mobile, 24px desktop |
| Header bar padding         | horizontal 20, vertical 16 |
| Card internal padding      | 14–16px all sides |
| List item internal padding | horizontal 16, vertical 14 |
| Between list items         | 8px gap          |
| Section title bottom gap   | 12px             |
| Bottom padding (for FAB)   | 100px            |

---

## Layout Patterns

### Breakpoints

| Width     | Layout           |
|-----------|------------------|
| < 768     | Mobile: bottom nav, full-width content |
| 768–1100  | Tablet: collapsed sidebar (68px icons only) + content |
| > 1100    | Desktop: expanded sidebar (220px) + content capped at 720px max |

### Screen Structure (every asset screen follows this)

```
Column
├── Sticky Header Bar
│   ├── Background: headerBg with bottom border
│   ├── Left: Screen title (Space Grotesk 18 w700)
│   └── Right: Refresh IconButton (22px, text2 color)
│
└── Expanded content (wrapped in Watch signal listener)
    └── LayoutBuilder (checks isDesktop)
        └── Stack
            ├── CustomScrollView
            │   ├── SliverToBoxAdapter: Info/price header card (GlassCard)
            │   ├── SliverToBoxAdapter: Section title ("Holdings", "Cash Accounts")
            │   ├── [if empty] SliverFillRemaining: Empty state text
            │   └── [if items] SliverPadding > SliverList.separated
            │       └── ItemTile widgets (8px gap between)
            │
            └── Positioned FAB (right 16/24, bottom 24)
```

### Dashboard Layout

```
Column
├── Mobile: Settings gear icon row (only < 768px)
└── Expanded content
    └── CustomScrollView
        ├── TotalWealthHeader (gradient card with radial glows)
        ├── SectionTitle: "ALLOCATION"
        ├── 2x2 Grid of CategorySummaryCards
        ├── SectionTitle: "TREND"
        ├── Period selector chips (30D / 90D / 1Y / ALL)
        └── WealthLineChart
```

---

## Component Library

### GlassCard
The primary card component. Wraps content in a semi-transparent container with a tinted top border.

- **Background**: `card` (semi-transparent)
- **Borders**: If `accent` color provided, top border at 33% opacity, sides/bottom at 20%. Otherwise `border` color.
- **Radius**: 14px
- **Tap effect**: accent splash at 8% + highlight at 4%

### SectionTitle
Uppercase label row with optional right-side widget.

- **Padding**: horizontal 20px
- **Text**: DM Sans / 11 / w700 / `text3` / uppercase / letter-spacing 0.07em
- **Right widget**: typically a total value in DM Mono / 13 / w700 / category color

### GainBadge
Pill-shaped percentage badge.

- **Padding**: horizontal 9, vertical 3
- **Radius**: 8px
- **Background**: `gainGreenBg` or `lossRedBg`
- **Text**: DM Mono / 12 / w700 / `gainGreen` or `lossRed`
- **Format**: "+X.X%" or "-X.X%"

### CategorySummaryCard
Dashboard card showing one asset category's total.

- **Background**: `card`
- **Border**: category color at 20%
- **Radius**: 14px
- **Inner padding**: 14px
- **Layout**:
  - Row: 34x34 icon container (category color bg, 10px radius) + percent badge
  - 12px gap
  - Category label: DM Sans / 11 / w500 / `text3` / uppercase / 0.5 letter-spacing
  - Value EGP: DM Mono / 15 / w700 / `text1`
  - Value USD: DM Mono / 11 / w400 / `text3`

### Item Tile (list item)
Each asset type has a tile following this pattern:

- **Wrapper**: GlassCard with category accent color
- **Internal padding**: horizontal 16, vertical 14
- **Layout**: Row
  - 42x42 icon container (category `Bg` color, 12px radius, category icon 21px)
  - 12px gap
  - Expanded column: title (DM Sans 14 w600 text1), subtitle (DM Sans 12 text3)
  - Right column: value (DM Mono 14 w700 text1), gain% (DM Mono 11 w600 green/red)
  - 4px gap
  - PopupMenuButton (more_vert icon, 20px, text3) with Edit/Delete options

---

## Bottom Sheet Dialog Pattern

Used for Add/Edit forms. Shown via `showModalBottomSheet`.

```
Container
├── decoration: surface2 background, top radius 22px, top border 2px in category color
├── SafeArea (top: false)
└── Padding (left/right 20, top 12, bottom keyboard-inset + 20)
    └── Form > SingleChildScrollView > Column
        ├── Drag handle: 36x4 container, white 12% opacity, 2px radius, centered
        ├── 16px gap
        ├── Title row: "Add X" or "Edit X" (Space Grotesk 18 w700) + close button (32x32 circle)
        ├── 20px gap
        ├── Form fields (each with label + 6px gap + TextFormField)
        │   ├── Field label: DM Sans / 11 / w700 / text3 / uppercase / 0.07em spacing
        │   └── TextFormField:
        │       ├── Fill: inputFill
        │       ├── Border: border color, 10px radius
        │       ├── Focus border: category color, 1.5px
        │       ├── Text: DM Mono / 14 / text1
        │       └── Hint: DM Mono / 14 / text3
        ├── 14px gaps between fields
        ├── [Optional] Live preview card (category Bg color, category border at 18%)
        ├── 6px + 14px gaps
        └── Action row:
            ├── Cancel: OutlinedButton flex 1, border color, 48px height
            └── Submit: FilledButton flex 2, category/accent color, 48px height, glow shadow
```

### Segmented Picker (Karat, Market)
Row of toggle buttons:

- **Height**: 42px
- **Radius**: 10px
- **Selected**: category `Bg` fill + category border at 50% + DM Sans 13 w700 in category color
- **Unselected**: `inputFill` + `border` + DM Sans 13 w700 in `text3`

---

## Delete Confirmation Dialog

Standard AlertDialog:

- **Background**: `surface2`
- **Border**: `border`, 14px radius
- **Title**: Space Grotesk / 18 / w700 / `text1` — e.g. "Delete Gold Item"
- **Content**: DM Sans / 14 / `text2` — e.g. 'Remove "Ring"?'
- **Cancel button**: DM Sans / 14 / w500 / `text2`
- **Delete button**: DM Sans / 14 / w600 / `lossRed`

---

## Navigation

### Mobile Bottom Nav
- **Height**: 68px
- **Background**: `navBg` with backdrop blur (24px sigma)
- **Top border**: 1px `border`
- **Active**: `accent` color icon + label, `accentBg` indicator
- **Inactive**: `text3` color, DM Sans 11 w500

### Sidebar (Tablet/Desktop)
- **Collapsed width**: 68px (icon only)
- **Expanded width**: 220px (icon + label)
- **Background**: `surface` with right `border`
- **Item height**: 44px
- **Active item**: `accentBg` background, `accent` icon + text
- **Inactive item**: transparent bg, `text3` icon + text
- **Item radius**: 10px

---

## Loading & Error States

- **Loading**: Centered `CircularProgressIndicator` in the category color
- **Error**: Centered text in DM Sans / 13 / `lossRed`, prefixed with "Error: "
- **Empty state**: Centered text in DM Sans / 13 / `text3`, e.g. "No gold items yet.\nTap + to add one."

---

## FAB (Floating Action Button)

- **Position**: Positioned bottom 24, right 16 (mobile) or 24 (desktop)
- **Background**: `accent`
- **Foreground**: `bg`
- **Elevation**: 0
- **Shape**: 14px rounded rectangle
- **Shadow**: accent @ 40% opacity, blur 20, offset (0, 4)
- **Icon**: Icons.add
- **Each screen has a unique heroTag**: `gold_fab`, `stocks_fab`, etc.

---

## Info/Price Header Card

Each asset screen has a GlassCard at the top showing live prices/rates:

- **Gold**: Shows 4 karat prices (24K, 22K, 21K, 18K) in a row. Accent: gold.
- **Stocks**: Shows exchange rate (1 USD = EGP X) + portfolio total EGP/USD. Accent: green.
- **Liquidity**: Shows exchange rate + total USD/EGP. Accent: cyan.
- **Stale warning**: Row with `warning_amber` icon 14px in `lossRed` + "Prices may be outdated" DM Sans 11 `lossRed`

---

## Design Checklist for New Screens

When designing a new screen, follow this checklist:

1. Use `bg` as the page background
2. Add a sticky header bar with `headerBg` + bottom `border`
3. Title in Space Grotesk 18 w700
4. Wrap scrollable content in CustomScrollView with SliverToBoxAdapter sections
5. Use GlassCard for info/summary cards at the top
6. Use SectionTitle for section labels
7. Use the item tile pattern for list items (42px icon, title/subtitle, right-aligned value)
8. Add a FAB with unique heroTag
9. Forms go in bottom sheets with the standard dialog pattern
10. Use DM Mono for all numeric values
11. Use category colors consistently (gold/green/cyan/orange + their Bg variants)
12. Always handle loading, error, and empty states
13. Apply LayoutBuilder for responsive padding (16 mobile, 24 desktop, 720px max width)
