import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../data/fixture_store.dart';
import '../../domain/privacy_notice.dart';
import '../../providers.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';
import 'launch_privacy_notice_page.dart';

Future<void> showPrivacySheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => PrivacySheet(storeRef: ref),
  );
}

class PrivacySheet extends StatefulWidget {
  const PrivacySheet({super.key, required this.storeRef});

  final WidgetRef storeRef;

  @override
  State<PrivacySheet> createState() => _PrivacySheetState();
}

class _PrivacySheetState extends State<PrivacySheet> {
  late final Future<PrivacyNotice> _future = loadPrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrivacyNotice>(
      future: _future,
      builder: (context, snap) {
        final notice = snap.data ?? PrivacyNotice.fallback;
        return Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: GlassContainer(
            fill: GlassFill.heavy,
            borderRadius: RadiusTokens.sheetTop,
            blurSigma: GlassTokens.blurSigmaSheet,
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.xl,
              SpacingTokens.xl,
              SpacingTokens.xl,
              SpacingTokens.xxl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NoticeCopyBlock(
                    notice: notice,
                    headingOverride: AppCopy.privacyTitle,
                    titleKey: const Key('privacy_sheet_title'),
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                  FilledButton(
                    key: const Key('privacy_sheet_agree'),
                    style: const ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                    ),
                    onPressed: () {
                      unawaited(
                        widget.storeRef
                            .read(privacyStoreProvider)
                            .setAccepted(true),
                      );
                      widget.storeRef.invalidate(privacyAcceptedProvider);
                      Navigator.pop(context);
                    },
                    child: Text(notice.agreeAction),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(AppCopy.privacyClose),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
