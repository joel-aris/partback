import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/language_menu.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    // Use go(), not push(): '/pharmacists' is a bottom-nav shell branch, so
    // go() switches to that tab in place instead of stacking a duplicate
    // page (which would show a redundant back button over the nav bar).
    context.go(Uri(path: '/pharmacists', queryParameters: query.isNotEmpty ? {'q': query} : null).toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider).value;
    final isAuthenticated = authState?.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/validika_logo.png', height: 30, width: 30, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Text('app.name'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          ],
        ),
        actions: [
          const LanguageMenuButton(),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            tooltip: isDark ? 'common.lightMode'.tr() : 'common.darkMode'.tr(),
            onPressed: () => ref.read(themeControllerProvider.notifier).toggle(),
          ),
          IconButton(
            icon: Icon(isAuthenticated ? Icons.person_rounded : Icons.login_rounded),
            tooltip: isAuthenticated ? 'nav.account'.tr() : 'nav.login'.tr(),
            onPressed: () => isAuthenticated ? context.go('/account') : context.push('/login'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            _HeroBanner(isDark: isDark),
            const SizedBox(height: 24),
            Text(
              'home.welcomeTitle'.tr(),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'home.welcomeSubtitle'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 20),
            _SearchCard(controller: _searchController, onSubmit: _search),
            const SizedBox(height: 24),
            _ActionCard(
              icon: Icons.qr_code_scanner_rounded,
              label: 'home.verifyCta'.tr(),
              onTap: () => context.go('/verify'),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.local_pharmacy_rounded,
              label: 'home.pharmacistsCta'.tr(),
              onTap: () => context.go('/pharmacists'),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.assignment_outlined,
              label: 'home.candidacyCta'.tr(),
              onTap: () => context.push('/candidacy'),
            ),
            const SizedBox(height: 32),
            _BenefitsRow(),
          ],
        ),
      ),
    );
  }
}

const _heroImages = [
  'assets/images/pharmacists/pharma1.jpg',
  'assets/images/pharmacists/pharma3.jpg',
  'assets/images/pharmacists/pharma5.jpg',
];

class _HeroBanner extends StatefulWidget {
  const _HeroBanner({required this.isDark});

  final bool isDark;

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final _pageController = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final next = (_page + 1) % _heroImages.length;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _heroImages.length,
              onPageChanged: (index) => setState(() => _page = index),
              itemBuilder: (context, index) => Image.asset(_heroImages[index], fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.72)],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'app.tagline'.tr(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_heroImages.length, (index) {
                      final active = index == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: active ? 0.95 : 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            hintText: 'home.searchHint'.tr(),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward_rounded), onPressed: onSubmit),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkAccent.withValues(alpha: 0.14) : const Color(0xFFE8F1FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitsRow extends StatelessWidget {
  static const _items = [
    (Icons.search_rounded, 'home.benefitSearch'),
    (Icons.verified_user_rounded, 'home.benefitAuthenticity'),
    (Icons.shield_rounded, 'home.benefitSecurity'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        for (final (icon, key) in _items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkAccent.withValues(alpha: 0.14) : const Color(0xFFE8F1FB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    key.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
