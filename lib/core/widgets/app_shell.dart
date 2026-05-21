import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/features/dashboard/presentation/dashboard_screen.dart';
import 'package:wealth_tracker/features/gold/presentation/gold_screen.dart';
import 'package:wealth_tracker/features/stocks/presentation/stocks_screen.dart';
import 'package:wealth_tracker/features/liquidity/presentation/liquidity_screen.dart';
import 'package:wealth_tracker/features/real_estate/presentation/real_estate_screen.dart';
import 'package:wealth_tracker/features/dashboard/presentation/dashboard_signals.dart';
import 'package:wealth_tracker/routing/app_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Dashboard', labelAr: 'الرئيسية'),
    _NavItem(icon: Icons.savings_outlined, activeIcon: Icons.savings, label: 'Gold', labelAr: 'الذهب'),
    _NavItem(icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up, label: 'Stocks', labelAr: 'الأسهم'),
    _NavItem(icon: Icons.water_drop_outlined, activeIcon: Icons.water_drop, label: 'Liquidity', labelAr: 'السيولة'),
    _NavItem(icon: Icons.home_work_outlined, activeIcon: Icons.home_work, label: 'Real Estate', labelAr: 'العقارات'),
  ];

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(onNavigateToTab: _onItemSelected);
      case 1:
        return const GoldScreen();
      case 2:
        return const StocksScreen();
      case 3:
        return const LiquidityScreen();
      case 4:
        return const RealEstateScreen();
      default:
        return DashboardScreen(onNavigateToTab: _onItemSelected);
    }
  }

  void _onItemSelected(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
    if (index == 0) {
      refreshDashboardFromCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) {
      return _buildMobileLayout();
    } else if (width < 1100) {
      return _buildSidebarLayout(collapsed: true);
    } else {
      return _buildSidebarLayout(collapsed: false);
    }
  }

  // ─── Mobile layout: screen + bottom nav ──────────────────────────

  Widget _buildMobileLayout() {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: List.generate(5, _buildScreen),
        ),
      ),
      bottomNavigationBar: _MobileBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
        items: _navItems,
      ),
    );
  }

  // ─── Sidebar layout: sidebar + content ──────────────────────────

  Widget _buildSidebarLayout({required bool collapsed}) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            collapsed: collapsed,
            currentIndex: _currentIndex,
            onItemSelected: _onItemSelected,
            items: _navItems,
          ),
          Expanded(
            child: SafeArea(
              left: false,
              child: ClipRect(
                child: IndexedStack(
                  index: _currentIndex,
                  children: List.generate(5, _buildScreen),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav item data ─────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String labelAr;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.labelAr,
  });
}

// ─── Sidebar ───────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final bool collapsed;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<_NavItem> items;

  const _Sidebar({
    required this.collapsed,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: collapsed ? 68 : 220,
      decoration: BoxDecoration(
        color: ObsidianTheme.surface,
        border: Border(
          right: BorderSide(
            color: ObsidianTheme.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 8 : 12,
                vertical: 4,
              ),
              children: List.generate(items.length, (i) {
                return _SidebarItem(
                  item: items[i],
                  isActive: i == currentIndex,
                  collapsed: collapsed,
                  onTap: () => onItemSelected(i),
                );
              }),
            ),
          ),
          _buildSettingsButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 16),
      child: Row(
        mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ObsidianTheme.accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Text(
              'ثَرِيّ',
              style: GoogleFonts.amiri(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ObsidianTheme.text1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12),
      child: _SidebarItem(
        item: const _NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
          labelAr: 'الإعدادات',
        ),
        isActive: false,
        collapsed: collapsed,
        onTap: () => Navigator.pushNamed(context, AppRouter.settings),
      ),
    );
  }
}

// ─── Sidebar item ──────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? ObsidianTheme.accent : ObsidianTheme.text3;
    final textColor = isActive ? ObsidianTheme.accent : ObsidianTheme.text3;
    final bgColor = isActive ? ObsidianTheme.accentBg : Colors.transparent;
    final icon = isActive ? item.activeIcon : item.icon;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: ObsidianTheme.accent.withValues(alpha: 0.08),
          highlightColor: ObsidianTheme.accent.withValues(alpha: 0.04),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12,
            ),
            child: collapsed
                ? Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  )
                : Row(
                    children: [
                      Icon(icon, color: iconColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.labelAr,
                          style: ObsidianTheme.bodyStyle(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Mobile bottom navigation ──────────────────────────────────────

class _MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<_NavItem> items;

  const _MobileBottomNav({
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.bg,
        border: Border(
          top: BorderSide(
            color: ObsidianTheme.border,
            width: 1,
          ),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 28,
            left: 12,
            right: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              final item = items[i];
              final color = isActive ? ObsidianTheme.accent : ObsidianTheme.text3;
              final icon = isActive ? item.activeIcon : item.icon;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onItemSelected(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        item.labelAr,
                        style: GoogleFonts.reemKufi(
                          fontSize: 10,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (isActive)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ObsidianTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(width: 4, height: 4),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
