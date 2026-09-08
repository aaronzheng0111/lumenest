import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../providers.dart';
import 'local_data_upgrade_page.dart';

/// Waits for [databaseProvider] init before showing the real app.
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({
    super.key,
    this.navigatorObservers = const [],
    this.showLaunchNotice = true,
  });

  final List<NavigatorObserver> navigatorObservers;
  final bool showLaunchNotice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(databaseReadyProvider);
    return boot.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const LocalDataUpgradePage(),
      data: (_) => AiMomBabyApp(
        navigatorObservers: navigatorObservers,
        showLaunchNotice: showLaunchNotice,
      ),
    );
  }
}
