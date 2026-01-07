// favfeedr_flutter/lib/ui/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About FavFeedr'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/favfeedr_icon.png',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'FavFeedr',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'FavFeedr is a clean and intuitive desktop application built with Flutter to help you stay updated with your favorite YouTube channels. '
                'It fetches video updates directly from YouTube\'s RSS feeds, offering a focused and efficient way to consume content without distractions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 16),
              Text(
                'Developed with ❤️ using Flutter',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '© 2025 FavFeedr. All rights reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
