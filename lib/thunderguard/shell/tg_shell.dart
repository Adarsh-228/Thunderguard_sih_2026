import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/tg_colors.dart';
import '../screens/home_screen.dart';
import '../screens/risk_map_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/settings_screen.dart';

class ThunderGuardShell extends StatefulWidget {
  const ThunderGuardShell({super.key});

  @override
  State<ThunderGuardShell> createState() => _ThunderGuardShellState();
}

class _ThunderGuardShellState extends State<ThunderGuardShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    _NavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map_rounded,
        label: 'Risk Map'),
    _NavItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics_rounded,
        label: 'Analytics'),
    _NavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: 'Alerts'),
    _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Settings'),
  ];

  final List<Widget> _screens = [
    const HomeScreen(),
    const RiskMapScreen(),
    const AnalyticsScreen(),
    const AlertsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TGColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: TGColors.surface,
          border: Border(
            top: BorderSide(color: TGColors.divider, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = i == _currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _currentIndex = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Alert dot on Alerts tab
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? TGColors.lightning.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  selected ? item.activeIcon : item.icon,
                                  color: selected
                                      ? TGColors.lightning
                                      : TGColors.textMuted,
                                  size: 22,
                                ),
                              ),
                              // Badge for alerts tab
                              if (i == 3)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: TGColors.severityEmergency,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('3',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: selected
                                  ? TGColors.lightning
                                  : TGColors.textMuted,
                              fontSize: 9,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label});
}
