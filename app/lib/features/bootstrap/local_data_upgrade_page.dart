import 'package:flutter/material.dart';

import '../../app_copy.dart';
import '../../theme/app_colors.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';

/// Shown when Drift migration fails (AC-02-B04).
class LocalDataUpgradePage extends StatelessWidget {
  const LocalDataUpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: AtmosphereBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Text(
                AppCopy.localDataNeedsUpgrade,
                key: const Key('local_data_upgrade_message'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
