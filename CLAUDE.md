# WealthTracker — Claude Code Guide

## Quick-start commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after changing Drift tables
flutter run -d chrome                                       # web dev
flutter analyze                                            # static analysis
```

---

## Architecture

Feature-first clean architecture. Every feature lives under `lib/features/<name>/`:

```
features/<name>/
  domain/
    entities/<name>_entity.dart     # plain Dart class, no Flutter imports
    <name>_repository.dart          # abstract interface
  data/
    <name>_repository_impl.dart     # Drift DAO calls + optional API calls
  presentation/
    <name>_signals.dart             # all reactive state (signals_flutter)
    <name>_screen.dart              # Scaffold + Watch wrapper
    widgets/                        # small, reusable sub-widgets
```

Shared infra lives in `lib/core/`:
- `database/app_database.dart` — single Drift database, all tables
- `services/` — GoldApiService, StockApiService, ExchangeRateService, PriceUpdateService
- `di/service_locator.dart` — get_it registrations
- `constants/` — AppConstants, ApiConstants
- `utils/` — CurrencyFormatter, DateFormatter

### Rules
- **Domain layer:** pure Dart only. No Flutter, no Drift, no package imports except `dart:core`.
- **Data layer:** implements domain repository. Uses Drift DAOs + core services.
- **Presentation layer:** calls repository through signals. Never imports Drift or API services directly.
- New API calls go in `core/services/`. Screens never call APIs directly.
- Register every new repository/service in `core/di/service_locator.dart`.

---

## State management (Signals)

Use `signals_flutter`. Every screen has a `<name>_signals.dart` with:

```dart
// Reactive state
final itemsSignal   = signal<List<FooEntity>>([]);
final loadingSignal = signal<bool>(false);
final errorSignal   = signal<String?>( null);

// Actions (plain async functions — NOT methods on a class)
Future<void> loadItems() async {
  loadingSignal.value = true;
  errorSignal.value   = null;
  try {
    itemsSignal.value = await sl<FooRepository>().getAll();
  } catch (e) {
    errorSignal.value = e.toString();
  } finally {
    loadingSignal.value = false;
  }
}
```

Widgets consume signals with `Watch`:
```dart
Watch((context) {
  final items = itemsSignal.value;   // reactive rebuild on change
  return ...;
})
```

---

## Design system

### Theme
Material 3, seed colour `Color(0xFF1565C0)` (deep blue), light + dark modes.
Access via `Theme.of(context).colorScheme` and `Theme.of(context).textTheme`.
Never hard-code colours except the four category accent colours below.

### Category accent colours
| Category    | Colour              | Hex         |
|-------------|---------------------|-------------|
| Gold        | Amber/Gold          | `0xFFFFD700` |
| Stocks      | Green               | `0xFF4CAF50` |
| Liquidity   | Blue                | `0xFF2196F3` |
| Real Estate | Deep Orange         | `0xFFFF5722` |

Use these consistently across tiles, chart slices, and icon containers.

### Spacing scale
`4 · 8 · 12 · 16 · 20 · 24` dp. Prefer multiples of 4. Default screen padding: `16` on all sides.

---

## Component patterns

### Screen Scaffold
```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Screen Name'),
    actions: [ /* refresh icon, settings icon */ ],
  ),
  body: Watch((context) {
    if (loadingSignal.value) return const Center(child: CircularProgressIndicator());
    if (errorSignal.value != null) return Center(child: Text('Error: ...'));
    return /* main content */;
  }),
  floatingActionButton: FloatingActionButton(
    onPressed: () => _showAddDialog(context, null),
    child: const Icon(Icons.add),
  ),
  bottomNavigationBar: _BottomNav(),   // shared across all main screens
)
```

### List screen body
```dart
items.isEmpty
  ? const Center(child: Text('No items yet.\nTap + to add one.', textAlign: TextAlign.center))
  : ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => FooItemTile(
        item: items[i],
        onEdit: () => _showAddDialog(context, items[i]),
        onDelete: () => _confirmDelete(context, items[i]),
      ),
    )
```

### Item tile
```dart
Card(
  clipBehavior: Clip.antiAlias,
  child: ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kCategoryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.someIcon, color: kCategoryColor, size: 20),
    ),
    title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitleText),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(CurrencyFormatter.formatEgp(value),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        PopupMenuButton(itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit',   child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ], onSelected: (v) { if (v == 'edit') onEdit(); else onDelete(); }),
      ],
    ),
  ),
)
```

### Add/Edit dialog
```dart
showDialog(context: context, builder: (_) => AddFooDialog(existing: item));

// Dialog widget:
AlertDialog(
  title: Text(existing == null ? 'Add Foo' : 'Edit Foo'),
  content: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(decoration: const InputDecoration(labelText: 'Label')),
        const SizedBox(height: 12),
        // ... more fields
      ],
    ),
  ),
  actions: [
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
    FilledButton(onPressed: _submit, child: const Text('Save')),
  ],
)
```

### Delete confirmation
```dart
AlertDialog(
  title: const Text('Delete Item'),
  content: Text('Remove "${item.label}"?'),
  actions: [
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
    TextButton(
      onPressed: () { deleteFoo(item.id); Navigator.pop(context); },
      child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ),
  ],
)
```

### Category summary card (dashboard)
```dart
Card(
  clipBehavior: Clip.antiAlias,
  child: InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _iconBadge(icon, color),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            _percentBadge(percent, color),
          ]),
          const SizedBox(height: 10),
          Text(CurrencyFormatter.formatEgp(valueEgp),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(CurrencyFormatter.formatUsd(valueUsd),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    ),
  ),
)
```

### Price/info header card
```dart
Card(
  margin: const EdgeInsets.all(12),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Section Title', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 16, runSpacing: 4, children: [...]),
      ],
    ),
  ),
)
```

### Warning / stale data badge
```dart
Row(children: [
  Icon(Icons.warning_amber, size: 14, color: Theme.of(context).colorScheme.error),
  const SizedBox(width: 4),
  Text('Prices may be outdated',
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: Theme.of(context).colorScheme.error)),
])
```

---

## Navigation

Routes are declared in `routing/app_router.dart`:
```
/lock         → LockScreen
/             → DashboardScreen
/gold         → GoldScreen
/stocks       → StocksScreen
/liquidity    → LiquidityScreen
/real-estate  → RealEstateScreen
/settings     → SettingsScreen
```

Push: `Navigator.pushNamed(context, AppRouter.gold)`  
Replace: `Navigator.pushReplacementNamed(context, AppRouter.dashboard)`

### Bottom navigation bar
All main screens (dashboard, gold, stocks, liquidity, real estate) share `_BottomNav`:
```dart
NavigationBar(
  destinations: [ /* dashboard, gold, stocks, liquidity, estate */ ],
  selectedIndex: _currentIndex(context),  // derived from ModalRoute.settings.name
  onDestinationSelected: (i) => Navigator.pushReplacementNamed(context, routes[i]),
)
```
Settings is opened via an AppBar icon, NOT from the bottom nav.

---

## Currency formatting

Always use `CurrencyFormatter` in `core/utils/currency_formatter.dart`:
```dart
CurrencyFormatter.formatEgp(value)   // e.g. "EGP 1,234,567"
CurrencyFormatter.formatUsd(value)   // e.g. "USD 25,432"
```
Never format currency inline with string interpolation.

---

## Data / Drift

Tables are defined in `core/database/app_database.dart`. After any table change:
```bash
dart run build_runner build --delete-conflicting-outputs
```

The generated file `app_database.g.dart` must never be edited manually.

Repository implementations access the database via `sl<AppDatabase>()`.

---

## Adding a new feature checklist

1. `lib/features/<name>/domain/entities/<name>_entity.dart` — plain Dart entity
2. `lib/features/<name>/domain/<name>_repository.dart` — abstract interface
3. Add Drift table to `core/database/app_database.dart`; run build_runner
4. `lib/features/<name>/data/<name>_repository_impl.dart` — Drift impl
5. Register in `core/di/service_locator.dart`
6. `lib/features/<name>/presentation/<name>_signals.dart` — signals + actions
7. `lib/features/<name>/presentation/widgets/` — tile + dialog widgets
8. `lib/features/<name>/presentation/<name>_screen.dart` — full screen
9. Add route to `routing/app_router.dart`
10. Add destination to `_BottomNav` if it's a top-level screen

---

## Platform notes

- **Web:** no biometrics — hide biometric toggle in Settings and biometric button in LockScreen (`kIsWeb` guard).
- **macOS:** network entitlement already set in `macos/Runner/*.entitlements`.
- **Android:** `FlutterFragmentActivity` required for `local_auth`; `USE_BIOMETRIC` permission needed.
- **iOS:** `NSFaceIDUsageDescription` required in Info.plist.
