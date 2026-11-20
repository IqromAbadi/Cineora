import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/movie_detail.dart';
import '../../../../shared/widgets/loading_shimmer.dart';

class DetailSections extends StatelessWidget {
  const DetailSections({super.key, required this.detail, required this.wide});

  final MovieDetail detail;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final credits = _InfoPanel(
      title: 'Credits',
      rows: [
        ('Director', detail.director),
        ('Writer', detail.writer),
        ('Cast', detail.actors),
      ],
    );
    final facts = _InfoPanel(
      title: 'Release & details',
      rows: [
        ('Released', detail.released),
        ('Runtime', detail.runtime),
        ('Language', detail.language),
        ('Country', detail.country),
        ('Awards', detail.awards),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Synopsis(plot: detail.plot),
        const SizedBox(height: 28),
        if (wide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: credits),
                const SizedBox(width: 16),
                Expanded(child: facts),
              ],
            ),
          )
        else ...[
          credits,
          const SizedBox(height: 16),
          facts,
        ],
      ],
    );
  }
}

class _Synopsis extends StatelessWidget {
  const _Synopsis({required this.plot});

  final String? plot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text('Synopsis', style: text.titleLarge),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            plot ?? 'OMDb has no plot summary for this title yet.',
            style: text.bodyLarge?.copyWith(
              color: plot == null ? AppColors.textSecondary : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.rows});

  final String title;
  final List<(String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final visible = rows.where((r) => r.$2 != null).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: text.titleMedium)),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            Text('Not listed on OMDb.', style: text.labelMedium)
          else
            for (final (label, value) in visible) ...[
              Text(label, style: text.labelMedium),
              const SizedBox(height: 2),
              Text(value!, style: text.bodyMedium),
              if (label != visible.last.$1) const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }
}

class DetailSectionsSkeleton extends StatelessWidget {
  const DetailSectionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 22),
          SizedBox(height: 14),
          SkeletonBox(height: 14),
          SizedBox(height: 8),
          SkeletonBox(height: 14),
          SizedBox(height: 8),
          SkeletonBox(width: 220, height: 14),
          SizedBox(height: 28),
          SkeletonBox(height: 180, radius: 16),
        ],
      ),
    );
  }
}
