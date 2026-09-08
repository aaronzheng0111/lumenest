import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fixture_store.dart';
import '../../domain/privacy_notice.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_container.dart';

class LaunchPrivacyNoticePage extends ConsumerStatefulWidget {
  const LaunchPrivacyNoticePage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  ConsumerState<LaunchPrivacyNoticePage> createState() =>
      _LaunchPrivacyNoticePageState();
}

class _LaunchPrivacyNoticePageState
    extends ConsumerState<LaunchPrivacyNoticePage> {
  late final Future<PrivacyNotice> _future = loadPrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrivacyNotice>(
      future: _future,
      builder: (context, snap) {
        final notice = snap.data ?? PrivacyNotice.fallback;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AtmosphereBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.pageMargin),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: GlassContainer(
                          fill: GlassFill.heavy,
                          borderRadius: RadiusTokens.borderXl,
                          blurSigma: GlassTokens.blurSigmaSheet,
                          padding: const EdgeInsets.all(SpacingTokens.xl),
                          child: _NoticeBody(notice: notice),
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('launch_privacy_agree'),
                        onPressed: () async {
                          await ref.read(privacyStoreProvider).setAccepted(true);
                          ref.invalidate(privacyAcceptedProvider);
                          widget.onFinished();
                        },
                        child: Text(notice.agreeAction),
                      ),
                    ),
                    TextButton(
                      key: const Key('launch_privacy_dismiss'),
                      onPressed: widget.onFinished,
                      child: Text(
                        notice.primaryAction,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NoticeCopyBlock extends StatelessWidget {
  const NoticeCopyBlock({
    super.key,
    required this.notice,
    this.headingOverride,
    this.titleKey,
  });

  final PrivacyNotice notice;
  final String? headingOverride;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    return _NoticeBody(
      notice: notice,
      headingOverride: headingOverride,
      titleKey: titleKey,
    );
  }
}

class _NoticeBody extends StatelessWidget {
  const _NoticeBody({
    required this.notice,
    this.headingOverride,
    this.titleKey,
  });

  final PrivacyNotice notice;
  final String? headingOverride;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headingOverride ?? notice.title,
          key: titleKey ?? const Key('launch_privacy_title'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: SpacingTokens.md),
        if (notice.statusLabel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.glassRoseSoft,
              borderRadius: RadiusTokens.borderPill,
            ),
            child: Text(
              notice.statusLabel,
              key: const Key('launch_privacy_status'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        const SizedBox(height: SpacingTokens.lg),
        Text(
          notice.combinedBody,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (notice.bullets.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.lg),
          for (final b in notice.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('·  '),
                  Expanded(child: Text(b)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
