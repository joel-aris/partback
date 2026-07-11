import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell shared by the four Phase 1 top-level destinations
/// (cahier des charges 7, "navigation principale").
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        elevation: 3,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: 'nav.home'.tr()),
          NavigationDestination(icon: const Icon(Icons.qr_code_scanner_outlined), selectedIcon: const Icon(Icons.qr_code_scanner_rounded), label: 'nav.verify'.tr()),
          NavigationDestination(icon: const Icon(Icons.local_pharmacy_outlined), selectedIcon: const Icon(Icons.local_pharmacy_rounded), label: 'nav.pharmacists'.tr()),
          NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: 'nav.account'.tr()),
        ],
      ),
    );
  }
}
