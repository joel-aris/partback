import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Generic "coming soon" screen for nav entries required by the spec (e.g.
/// "Deposer une candidature", cahier des charges 4.1) whose full flow is
/// scheduled for a later phase.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('placeholder.title'.tr())),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
