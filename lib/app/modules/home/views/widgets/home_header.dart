import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Cine'),
                  TextSpan(
                    text: 'ora',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          SizedBox(height: wide ? 28 : 20),
          Semantics(
            header: true,
            child: Text(
              'What are we\nwatching tonight?',
              style: (wide ? text.displaySmall : text.headlineMedium)?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: wide ? -1.2 : -0.8,
                height: 1.08,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search the OMDb catalogue of films and series, then save the ones you want to keep.',
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
