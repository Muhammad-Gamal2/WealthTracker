# WealthTracker — Screen Inventory

A description of every screen and dialog in the app, covering what content is shown and what the user can do. Use this as the source of truth when recreating screens under a new design system.

---

## Navigation Shell

The app uses a persistent 5-tab navigation shell that is always visible:

- **Tab 0 — Dashboard** (home icon)
- **Tab 1 — Gold** (savings icon)
- **Tab 2 — Stocks** (trending-up icon)
- **Tab 3 — Liquidity** (water-drop icon)
- **Tab 4 — Real Estate** (home icon)

On mobile (< 768px) this is a bottom navigation bar. On tablet/desktop it becomes a left sidebar (icon-only when narrow, icon + label when wide). The Settings screen is accessed from within the Dashboard on mobile, or via a separate entry on desktop.

---

## 1. Lock Screen

**When shown:** On app launch if the user has set a PIN.

**Content:**
- App icon (lock outline) centered near top
- App name "WealthTracker" as a title below the icon
- Subtitle text "Enter your PIN"
- A numeric PIN pad (4-digit entry) — provided by the `flutter_screen_lock` package, displays dot indicators for entered digits
- A "Use Biometrics" button at the bottom (fingerprint icon + label), shown only if biometric is enabled in settings

**User actions:**
- Enter 4-digit PIN to unlock and proceed to Dashboard
- Tap "Use Biometrics" to authenticate with fingerprint or Face ID instead
- On launch, biometric authentication is attempted automatically if enabled

---

## 2. Dashboard Screen

**Purpose:** Overview of total wealth across all asset categories.

### Mobile layout (single column, scrollable)

**Header row:** "Dashboard" title on the left, settings gear icon button on the right (navigates to Settings screen).

**Total Wealth Card:** A large gradient card spanning full width. Shows:
- Label "TOTAL WEALTH"
- Total portfolio value in EGP (large number)
- Total portfolio value in USD (smaller, below)
- While data is loading, shows a loading indicator inside the card

**BREAKDOWN section:** A pie/donut chart showing each category's share of the total as a colored segment. Tapping a segment navigates to that category's screen. The chart shows 4 segments: Gold (yellow), Stocks (green), Liquidity (cyan), Real Estate (orange). Each segment shows its percentage label.

**CATEGORIES section:** A 2×2 grid of category summary cards. Each card shows:
- Category icon with colored background
- Category name (e.g. "Gold", "Stocks")
- Category percentage of total portfolio
- Value in EGP
- Value in USD
- Tapping navigates to that category's screen

**HISTORY section:** A line chart of total wealth over time. Above the chart, a row of period selector chips: **30D / 90D / 1Y / All** — tapping a chip filters the chart to that time range.

**Error state:** If data loading fails, an error card appears below the total wealth card showing a warning icon, "Update error" label, and the error message.

### Desktop layout (two-column)

Same content, but the Breakdown (pie chart) moves to a right column (fixed width ~320px) and the Categories grid + History chart fill the left column. The total wealth card spans the full top.

---

## 3. Gold Screen

**Purpose:** Track physical gold holdings and see live karat prices.

**Header bar:** "Gold" title on the left, refresh icon button on the right (re-fetches live gold prices from the API).

### Price Header Card

A card at the top showing live gold prices per gram for each karat. Laid out as a horizontal row of 4 columns:
- **24K** — price per gram in EGP
- **22K** — price per gram in EGP
- **21K** — price per gram in EGP
- **18K** — price per gram in EGP

If prices are stale (cached from a previous session), a warning row appears inside the card: warning icon + "Prices may be outdated".

### Holdings Section

Section title "HOLDINGS" with the count of gold items on the right.

**Empty state:** Centered text "No gold items yet. Tap + to add one."

**List of Gold Item Tiles** (one per holding):
- Square icon container with a savings icon
- **Title:** user-defined label (e.g. "Wedding Ring") or defaults to "Xk Gold" if no label
- **Subtitle:** karat (e.g. "21K") · weight in grams (e.g. "10.5 g")
- **Optional third line:** "Cost: EGP X,XXX" if purchase price was provided
- **Right side — value:** Current value in EGP (calculated as weight × live price for that karat)
- **Right side — gain%:** Percentage gain/loss vs. purchase price, colored green (gain) or red (loss); hidden if no purchase price
- **Three-dot menu:** Edit / Delete options

**Floating action button (FAB):** "+" button fixed to bottom-right corner; opens the Add Gold dialog.

### Loading / Error states
- Loading: centered spinner
- Error: centered red error text

---

## 4. Add / Edit Gold Dialog

**Trigger:** FAB on Gold screen (Add), or "Edit" from tile menu (Edit).
**Presentation:** Bottom sheet that slides up from the bottom of the screen.

**Title:** "Add Gold" or "Edit Gold Item" depending on mode. Close (×) button on the right.

**Fields:**
1. **LABEL** — text field; optional, e.g. "Wedding Ring". If empty, the item displays as "XK Gold".
2. **WEIGHT (GRAMS)** — numeric field with "g" suffix
3. **KARAT** — segmented picker with 4 options: **24K / 22K / 21K / 18K**. Only one can be selected at a time.
4. **PURCHASE PRICE PER GRAM** — numeric field with "EGP" suffix; optional (used only for gain/loss display)

**Live preview card:** Appears once weight and karat are filled. Shows:
- "Current Value" label
- Calculated EGP value (weight × live karat price)
- Gain/loss badge (percentage vs. purchase price) if purchase price is also filled

**Action buttons (row):**
- **Cancel** (outlined, 1/3 width) — dismisses the sheet
- **Add / Save** (filled, 2/3 width, gold-colored) — saves and closes

---

## 5. Stocks Screen

**Purpose:** Track stock holdings on EGX (Egypt) and US markets.

**Header bar:** "Stocks" title on the left, refresh icon button on the right (re-fetches live stock prices from API).

### Info Header Card

A card showing:
- **Left side:** "Exchange Rate" label + "1 USD = EGP X.XX" (cyan/green number)
- **Right side:** "Portfolio Total" label + total EGP value (large) + total USD value (small, below)
- If prices are stale: warning row inside the card

### Holdings Section

Section title "HOLDINGS" with item count on the right.

**Empty state:** "No stocks yet. Tap + to add one."

**List of Stock Item Tiles** (one per holding):
- **Leading:** Circular badge showing the market label ("EGX" or "US"), colored with the market's accent color (cyan for EGX, green for US)
- **Symbol** (bold) + **Company name** (dimmed, truncated)
- **Subtitle:** "X shares · CURRENCY X.XX" (current price per share)
- **Right side — value:** Total holding value in EGP
- **Right side — gain badge:** Percentage gain/loss vs. purchase price (colored pill)
- **Three-dot menu:** Edit / Delete

**FAB:** "+" button, opens Add Stock dialog.

---

## 6. Add / Edit Stock Dialog

**Presentation:** Bottom sheet.

**Title:** "Add Stock" or "Edit Stock". Close button on right.

**Fields:**
1. **MARKET** — segmented picker: **EGX (Egypt)** / **US Market**. Controls which currency is used throughout the form.
2. **SYMBOL** — text field; uppercase, e.g. "COMI" (EGX) or "AAPL" (US)
3. **COMPANY NAME (OPTIONAL)** — text field for the full company name
4. **QUANTITY** (left, half-width) — number of shares
5. **BUY PRICE** (right, half-width) — purchase price per share in EGP or USD depending on market
6. **CURRENT PRICE** — current price per share (optional; used only to populate the live preview, since prices are normally fetched from the API)

**Live preview card:** Appears when quantity and current price are both filled. Shows:
- "Total Value" label + calculated total in EGP or USD
- Gain/loss badge if buy price is also filled

**Actions:** Cancel (outlined) + Add/Save (filled, green)

---

## 7. Liquidity Screen

**Purpose:** Track USD cash holdings and see EGP equivalent using live exchange rate.

**Header bar:** "Liquidity" title on the left, refresh icon button on the right.

### Info Header Card

- **Left side:** "Exchange Rate" label + "1 USD = EGP X.XX" (cyan number); stale warning if outdated
- **Right side:** "Total" label + total USD amount + total EGP equivalent below it

### Cash Accounts Section

Section title "CASH ACCOUNTS" with total EGP value on the right.

**Empty state:** "No cash accounts yet. Tap + to add one."

**List of Liquidity Item Tiles** (one per account):
- **Leading:** Square icon container with water-drop icon (cyan)
- **Title:** Account label (e.g. "Savings", "Emergency Fund"); defaults to "Cash" if empty
- **Subtitle:** Amount in USD (e.g. "$5,000.00")
- **Right side:** EGP equivalent value
- **Three-dot menu:** Edit / Delete

**FAB:** "+" button, opens Add Cash dialog.

---

## 8. Add / Edit Cash Account Dialog

**Presentation:** Bottom sheet.

**Title:** "Add Cash" or "Edit Cash Account". Close button on right.

**Fields:**
1. **LABEL** — text field; name for this cash pool, e.g. "Savings", "Emergency Fund"
2. **AMOUNT (USD)** — numeric field with "USD" suffix

**Live preview card:** Appears once both fields are filled. Shows:
- "EGP Equivalent" label on the left
- Calculated EGP amount on the right (using cached exchange rate)

**Actions:** Cancel (outlined) + Add/Save (filled, cyan)

---

## 9. Real Estate Screen

**Purpose:** Track real estate investments using compound appreciation over time.

**Header bar:** "Real Estate" title on the left, refresh icon button on the right.

### Properties Section

Section title "PROPERTIES" with total current value in EGP on the right.

**Empty state:** "No properties yet. Tap + to add one."

**List of Real Estate Item Tiles** (one per property). Each tile is an expanded card (not a compact row):

**Top row:**
- Square icon container with house icon (orange)
- Property name (e.g. "Cairo Heights Apt 3B")
- Three-dot menu (Edit / Delete) aligned to top-right

**Stat chips row** (three labeled values):
- **PURCHASED** — original purchase amount in EGP (compact format: e.g. "EGP 1.5M")
- **ANNUAL RATE** — annual appreciation rate as a percentage (e.g. "10.0%")
- **HELD** — how long the property has been held (e.g. "2y 3m", "5y", "8m", "14d")

**Divider line**

**Bottom row:**
- Left: "Current Value" label + current value in EGP (large number, calculated using compound interest)
- Right: Gain badge showing total percentage gain since purchase (green if positive)

**FAB:** "+" button, opens Add Real Estate dialog.

---

## 10. Add / Edit Real Estate Dialog

**Presentation:** Bottom sheet.

**Title:** "Add Real Estate" or "Edit Property". Close button on right.

**Fields:**
1. **PROJECT NAME** — text field; name of the property, e.g. "Cairo Heights Apt 3B"
2. **PURCHASE PRICE** — numeric field with "EGP" suffix
3. **PURCHASE DATE** (left, half-width) — date picker showing "YYYY-MM-DD"; opens calendar picker on tap; calendar icon inside field
4. **ANNUAL GROWTH** (right, half-width) — numeric field with "%" suffix; expected annual appreciation rate

**Live preview card:** Appears once purchase price, date, and annual rate are all filled. Shows:
- "Current Value" label + calculated current value in EGP (using compound appreciation formula from purchase date to today)
- Gain badge showing total percentage gain

**Actions:** Cancel (outlined) + Add/Save (filled, orange). If date is not selected when saving, a snackbar error appears.

---

## 11. Settings Screen

**Purpose:** Configure API keys, security/PIN, and appearance.

**Access:** Settings gear icon on the Dashboard header (mobile), or sidebar item (desktop/tablet). Has a back arrow in its own header.

**Header:** "Settings" title + back arrow on left.

The screen is a scrollable list with three sections:

### API KEYS section

A card containing two API key rows, separated by a divider:

**GoldAPI.io Key:**
- Label "GoldAPI.io Key"
- Masked text field (shows dots by default) for pasting/editing the key
- Eye icon button to toggle key visibility
- Save icon button to persist the key
- Shows a snackbar "GoldAPI.io Key saved" on save

**EODHD API Key:**
- Same layout as above but for the EODHD stock data API key

### SECURITY section

A card with rows:

**Set PIN / Change PIN:**
- Label changes to "Change PIN" if a PIN is already configured, otherwise "Set PIN"
- Subtitle: "Lock the app with a PIN code"
- Right chevron arrow (tappable)
- Tapping opens a full-screen PIN creation flow (enter PIN, then confirm it)

**Biometric Unlock** (hidden on web):
- Icon: fingerprint
- Subtitle: "Use fingerprint or Face ID"
- Right: toggle switch (on/off)
- Toggling enables/disables biometric unlock

**Remove PIN** (only shown if a PIN is configured):
- Colored red/destructive
- Subtitle: "App will no longer be locked"
- Tapping shows a confirmation dialog: "Remove PIN — Are you sure you want to remove your PIN? The app will no longer be locked." with Cancel / Remove actions

### APPEARANCE section

A card with one row:

**Dark Mode:**
- Icon: moon/dark-mode icon
- Subtitle: "Toggle dark theme"
- Right: toggle switch (on/off)
- Toggling instantly switches the entire app between dark and light themes

---

## 12. Delete Confirmation Dialog

Used by every asset screen (Gold, Stocks, Liquidity, Real Estate) when the user selects "Delete" from a tile's popup menu.

**Presentation:** Standard modal alert dialog.

**Content:**
- Title: "Delete [Asset Type]" (e.g. "Delete Stock", "Delete Property")
- Body: 'Remove "[item name]"?' (shows the item's name/symbol)
- **Cancel** button (text, neutral color) — dismisses without action
- **Delete** button (text, red color) — deletes the item and closes the dialog

---

## Data Notes for Each Screen

| Screen | Data source | Refresh behavior |
|---|---|---|
| Dashboard | Aggregated from all local asset stores + cached prices | Fetches fresh API prices on first load; on tab return, uses cache only |
| Gold | Local gold items DB + GoldAPI.io price feed | Manual refresh via header button |
| Stocks | Local stock items DB + EODHD price feed | Manual refresh via header button |
| Liquidity | Local liquidity items DB + exchange rate feed | Manual refresh via header button |
| Real Estate | Local real estate DB; no external price feed | Current value calculated locally via compound interest |
| Settings | Local key-value store (shared preferences) | Persists immediately on save |
